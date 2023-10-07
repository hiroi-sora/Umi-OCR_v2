# ==============================================
# =============== 任务管理器 基类 ===============
# ==============================================


from PySide2.QtCore import QMutex, QThreadPool, QRunnable
from uuid import uuid4  # 唯一ID
import time


class Mission:
    def __init__(self):
        self.__msnInfoDict = {}  # 任务信息的字典
        self.__msnListDict = {}  # 任务队列的字典
        self.__msnMutex = QMutex()  # 任务队列的锁
        self.__task = None  # 异步任务对象
        self.__taskMutex = QMutex()  # 任务对象的锁
        self.__threadPool = QThreadPool.globalInstance()  # 全局线程池

    # ========================= 【调用接口】 =========================

    """
    添加任务队列的格式
    mission = {
        "onStart": 任务队列开始回调函数 , (msnInfo)
        "onReady": 一项任务准备开始 , (msnInfo, msn)
        "onGet": 一项任务获取结果 , (msnInfo, msn, res)
        "onEnd": 任务队列结束 , (msnInfo, msg) // msg可选前缀： [Success] [Warning] [Error]
    }
    MissionOCR.addMissionList(mission, paths)
    """

    def addMissionList(self, msnInfo, msnList):  # 添加一条任务队列，返回任务ID
        msnID = str(uuid4())
        # 检查并补充回调函数
        # 队列开始，单个任务准备开始，单任务取得结果，队列结束
        cbKeys = ["onStart", "onReady", "onGet", "onEnd"]
        for k in cbKeys:
            if k not in msnInfo or not callable(msnInfo[k]):
                print(f"补充空回调函数{k}")
                msnInfo[k] = (lambda key: lambda *e: print(f"空回调 {key}"))(k)
        # 任务状态state:  waiting 等待开始， running 进行中， stop 要求停止
        msnInfo["state"] = "waiting"
        msnInfo["msnID"] = msnID
        # 添加到任务队列
        self.__msnMutex.lock()  # 上锁
        self.__msnInfoDict[msnID] = msnInfo  # 添加任务信息
        self.__msnListDict[msnID] = msnList  # 添加任务队列
        self.__msnMutex.unlock()  # 解锁
        # 启动任务
        self.__startMsns()
        # 返回任务id
        return msnID

    def stopMissionList(self, msnID):  # 停止一条任务队列
        self.__msnMutex.lock()  # 上锁
        if msnID in self.__msnListDict:
            self.__msnInfoDict[msnID]["state"] = "stop"  # 设为停止状态
        self.__msnMutex.unlock()  # 解锁

    def stopAllMissions(self):  # 停止全部任务
        self.__msnMutex.lock()  # 上锁
        for msnID in self.__msnListDict:
            self.__msnInfoDict[msnID]["state"] = "stop"
        self.__msnMutex.unlock()  # 解锁

    def getMissionListsLength(self):  # 获取每一条任务队列长度
        lenDict = {}
        self.__msnMutex.lock()
        for k in self.__msnListDict:
            lenDict[str(k)] = len(self.__msnListDict[k])
        self.__msnMutex.unlock()
        return lenDict

    # ========================= 【主线程 方法】 =========================

    def __startMsns(self):  # 启动异步任务，执行所有任务列表
        # 若当前异步任务对象为空，则创建工作线程
        self.__taskMutex.lock()  # 上锁
        if self.__task == None:
            self.__task = self.__Task(self.__taskRun)
            self.__threadPool.start(self.__task)
        self.__taskMutex.unlock()  # 解锁

    # ========================= 【子线程 方法】 =========================

    def __taskRun(self):  # 异步执行任务字典的流程
        # print(f"线程{threading.current_thread().ident}，__taskRun 任务正在运行~~")
        dictIndex = 0  # 当前取任务字典中的第几个任务队列
        # 循环，直到任务队列的列表为空
        while True:
            # 1. 检查api和任务字典是否为空
            self.__msnMutex.lock()  # 上锁
            dl = len(self.__msnInfoDict)  # 任务字典长度
            if dl == 0:  # 任务字典已空
                self.__msnMutex.unlock()  # 解锁
                break

            # 2. 取一个任务队列
            dictIndex = (dictIndex + 1) % dl
            dictKey = tuple(self.__msnInfoDict.keys())[dictIndex]
            msnInfo = self.__msnInfoDict[dictKey]
            msnList = self.__msnListDict[dictKey]
            self.__msnMutex.unlock()  # 解锁

            # 3. 检查任务是否要求停止
            if msnInfo["state"] == "stop":
                self.__msnDictDel(dictKey)
                msnInfo["onEnd"](msnInfo, "[Warning] Task stop.")
                continue

            # 4. 前处理，检查、更新参数
            preFlag = self.msnPreTask(msnInfo)
            if preFlag == "continue":  # 跳过本次
                print("任务管理器：跳过任务")
                continue
            elif preFlag.startswith("[Error]"):  # 异常，结束该队列
                msnInfo["onEnd"](msnInfo, preFlag)
                self.__msnDictDel(dictKey)
                dictIndex -= 1  # 字典下标回退1位，下次执行正确的下一项
                continue

            # 5. 首次任务
            if msnInfo["state"] == "waiting":
                msnInfo["state"] = "running"
                msnInfo["onStart"](msnInfo)

            # 6. 执行任务，并记录时间
            msn = msnList[0]
            msnInfo["onReady"](msnInfo, msn)
            t1 = time.time()
            res = self.msnTask(msnInfo, msn)
            t2 = time.time()
            if type(res) == dict:  # 补充耗时和时间戳
                res["time"] = t2 - t1
                res["timestamp"] = t2

            # 7. 再次检查任务是否要求停止
            if msnInfo["state"] == "stop":
                self.__msnDictDel(dictKey)
                msnInfo["onEnd"](msnInfo, "[Warning] Task stop.")
                continue

            # 8. 不停止，则上报该任务
            msnList.pop(0)  # 弹出该任务
            msnInfo["onGet"](msnInfo, msn, res)  # 回调

            # 9. 这条任务队列完成
            if len(msnList) == 0:
                msnInfo["onEnd"](msnInfo, "[Success]")
                self.__msnDictDel(dictKey)
                dictIndex -= 1  # 字典下标回退1位，下次执行正确的下一项

        # 完成
        self.__taskFinish()

    def __msnDictDel(self, dictKey):  # 停止一组任务队列
        print(f"停止任务字典{dictKey}")
        del self.__msnInfoDict[dictKey]
        del self.__msnListDict[dictKey]

    def __taskFinish(self):  # 任务结束
        self.__taskMutex.lock()  # 上锁
        self.__task = None
        self.__taskMutex.unlock()  # 解锁

    # ========================= 【继承重载】 =========================

    def msnPreTask(self, msnInfo):  # 任务前处理，用于更新api和参数。
        """返回值可选：
        "" ：空字符串表示正常继续。
        "continue" ：跳过本次任务
        "[Error] xxxx" ：终止这条任务队列，返回异常信息
        """
        return "[Error] No overloaded msnPreTask. \n【异常】未重载msnPreTask。"

    def msnTask(self, msnInfo, msn):  # 执行任务msn，返回结果字典。
        print("mission 父类 msnTask")
        return {"error": f"[Error] No overloaded msnTask. \n【异常】未重载msnTask。"}

    def getStatus(self):  # 返回当前状态
        return "Mission 基类 返回空状态"

    # ========================= 【异步类】 =========================

    class __Task(QRunnable):
        def __init__(self, taskFunc):
            super().__init__()
            self.__taskFunc = taskFunc

        def run(self):
            self.__taskFunc()
