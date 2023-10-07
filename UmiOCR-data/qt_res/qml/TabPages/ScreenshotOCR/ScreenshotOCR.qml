// ==============================================
// =============== 功能页：截图OCR ===============
// ==============================================

import QtQuick 2.15

import ".."
import "../../Widgets"
import "../../Widgets/ResultLayout"
import "../../Widgets/ImageViewer"

TabPage {
    id: tabPage
    // 配置
    ScreenshotOcrConfigs { id: screenshotOcrConfigs } 
    configsComp: screenshotOcrConfigs
    property string msnState: "none" // OCR任务状态， none run

    // TODO: 测试用
    // Timer {
    //     interval: 200
    //     running: true
    //     onTriggered: {
    //         imageViewer.setSource("file:///D:/Pictures/Screenshots/test/#1.png")
    //     }
    // }
    // ========================= 【逻辑】 =========================

    // 开始截图
    function screenshot() {
        const grabList = tabPage.callPy("screenshot")
        ssWindowManager.create(grabList)
    }

    // 截图完毕
    function screenshotEnd(argd) {
        const x = argd["clipX"], y = argd["clipY"], w = argd["clipW"], h = argd["clipH"]
        if(x < 0 || y < 0 || w <= 0 || h <= 0) // 裁切区域无实际像素
            return
        const configDict = screenshotOcrConfigs.getConfigValueDict()
        const clipID = tabPage.callPy("screenshotEnd", argd, configDict)
        if(clipID.startsWith("[Error]")) {
            qmlapp.popup.message(qsTr("截图裁切异常"), clipID, "error")
            return
        }
        qmlapp.tab.showTabPageObj(tabPage) // 切换标签页
        imageViewer.setSource("image://pixmapprovider/"+clipID)
    }

    // 开始粘贴
    function paste() {
        const configDict = screenshotOcrConfigs.getConfigValueDict()
        const res = tabPage.callPy("paste", configDict)
        const simpleType = configDict["other.simpleNotificationType"]
        if(res.error) {
            if(res.error.startsWith("[Error]")) {
                qmlapp.popup.message(qsTr("获取剪贴板异常"), res.err, "error")
            }
            else if(res.error === "[Warning] No image in clipboard.") {
                qmlapp.popup.simple(qsTr("剪贴板中未找到图片"), "", simpleType)
            }
            return
        }
        qmlapp.tab.showTabPageObj(tabPage) // 切换标签页
        if(res.imgID) { // 缓存图片类型
            imageViewer.setSource("image://pixmapprovider/"+res.imgID)
        }
        else if(res.paths) { // 地址类型
            qmlapp.popup.simple(qsTr("粘贴%1条图片路径").arg(res.paths.length), res.paths[0], simpleType)
            imageViewer.setSource("")
        }
    }

    // 停止所有任务
    function msnStop() {
        tabPage.callPy("msnStop")
    }

    // 关闭页面
    function closePage() {
        if(msnState !== "none") {
            const argd = {yesText: qsTr("依然关闭")}
            const callback = (flag)=>{
                if(flag) {
                    msnStop()
                    eventUnsub()
                    delPage()
                }
            }
            qmlapp.popup.dialog("", qsTr("任务正在进行中。\n要结束任务并关闭页面吗？"), callback, "warning", argd)
        }
        else {
            eventUnsub()
            delPage()
        }
    }

    // ========================= 【事件管理】 =========================

    Component.onCompleted: {
        eventSub() // 订阅事件
    }
    // 订阅事件
    function eventSub() {
        qmlapp.pubSub.subscribeGroup("<<screenshot>>", this, "screenshot", ctrlKey)
        qmlapp.pubSub.subscribeGroup("<<paste>>", this, "paste", ctrlKey)
        qmlapp.systemTray.addMenuItem("%screenshot%", qsTr("屏幕截图"), screenshot)
        qmlapp.systemTray.addMenuItem("%paste%", qsTr("粘贴图片"), paste)
    }
    // 取消订阅事件
    function eventUnsub() {
        qmlapp.pubSub.unsubscribeGroup(ctrlKey)
        qmlapp.systemTray.delMenuItem("%screenshot%")
        qmlapp.systemTray.delMenuItem("%paste%")
    }

    // ========================= 【python调用qml】 =========================
    
    // 设置任务状态
    function setMsnState(flag) {
        msnState = flag
    }

    // 获取一个OCR的返回值
    function onOcrGet(res, imgID="", imgPath="") {
        // 添加到结果
        const resText = resultsTableView.addOcrResult(res)
        let source = "" // 图片源
        if(imgID) // 图片类型
            source = "image://pixmapprovider/"+imgID
        else if(imgPath) // 地址类型
            source = "file:///"+imgPath
        imageViewer.setSourceResult(source, res) // 将图片源及结果传入图片组件
        // 若tabPanel面板的下标没有变化过，则切换到记录页
        if(tabPanel.indexChangeNum < 2)
            tabPanel.currentIndex = 1
        // 完成后的动作
        const popMainWindow = screenshotOcrConfigs.getValue("action.popMainWindow")
        const copy = screenshotOcrConfigs.getValue("action.copy")
        // 复制到剪贴板
        if(copy && resText!="") 
            qmlapp.utilsConnector.copyText(resText)
        // 弹出通知
        showSimple(res, resText, copy)
        // 升起主窗口
        if(popMainWindow) qmlapp.mainWin.setVisibility(true)
    }

    // ========================= 【后处理】 =========================

    // 任务完成后发送通知
    function showSimple(res, resText, isCopy) {
        const code = res.code
        const time = res.time.toFixed(2)
        let title = ""
        resText = resText.replace(/\n/g, " ") // 换行符替换空格
        if(code == 100) {
            if(isCopy) title = qsTr("已复制到剪贴板")
            else title = qsTr("识图完成")
        }
        else if(code == 101) {
            title = qsTr("无文字")
            resText = ""
        }
        else {
            title = qsTr("识别失败")
        }
        title += `  -  ${time}s`
        const simpleType = screenshotOcrConfigs.getValue("other.simpleNotificationType")
        qmlapp.popup.simple(title, resText, simpleType)
    }

    // ========================= 【布局】 =========================

    // 截图窗口管理器
    ScreenshotWindowManager{
        id: ssWindowManager
        screenshotEnd: tabPage.screenshotEnd
    }

    // 左控制栏
    Item {
        id: leftCtrlPanel
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: size_.spacing
        width: 32

        Column {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: size_.spacing

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: width
            }

            IconButton {
                anchors.left: parent.left
                anchors.right: parent.right
                height: width
                icon_: "screenshot"
                color: theme.textColor
                toolTip: qsTr("屏幕截图")
                onClicked: tabPage.screenshot()
            }
            IconButton {
                anchors.left: parent.left
                anchors.right: parent.right
                height: width
                icon_: "paste"
                color: theme.textColor
                toolTip: qsTr("粘贴图片")
                onClicked: tabPage.paste()
            }
            IconButton {
                visible: msnState==="run"
                anchors.left: parent.left
                anchors.right: parent.right
                height: width
                icon_: "stop"
                color: theme.noColor
                toolTip: qsTr("停止任务")
                onClicked: tabPage.msnStop()
            }
        }
    }
    // 主区域：双栏面板
    DoubleColumnLayout {
        anchors.left: leftCtrlPanel.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        initSplitterX: 0.5

        // 左面板
        leftItem: Panel {
            anchors.fill: parent

            ImageViewer {
                id: imageViewer
                anchors.fill: parent
            }
        }

        // 右面板
        rightItem: Panel {
            anchors.fill: parent

            TabPanel {
                id: tabPanel
                anchors.fill: parent
                anchors.margins: size_.spacing

                // 结果面板
                ResultsTableView {
                    id: resultsTableView
                    anchors.fill: parent
                    visible: false
                }

                tabsModel: [
                    {
                        "key": "configs",
                        "title": qsTr("设置"),
                        "component": screenshotOcrConfigs.panelComponent,
                    },
                    {
                        "key": "ocrResult",
                        "title": qsTr("记录"),
                        "component": resultsTableView,
                    },
                ]
            }
        }
    }
}