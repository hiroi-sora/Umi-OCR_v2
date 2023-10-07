# 纯文本（无格式）txt文件

from .output import Output


class OutputTxtPlain(Output):
    def __init__(self, argd):
        self.dir = argd["outputDir"]  # 输出路径（文件夹）
        self.fileName = argd["outputFileName"]  # 文件名
        self.fileName = self.fileName.replace(
            "%name", argd["outputDirName"]
        )  # 文件名添加路径名
        self.outputPath = f"{self.dir}/{self.fileName}.p.txt"  # 输出路径
        # 创建输出文件
        try:
            open(self.outputPath, "w").close()  # 覆盖创建文件
        except Exception as e:
            raise Exception(f"Failed to create plain txt file. {e}\n创建纯文本txt文件失败。")

    def print(self, res):  # 输出图片结果
        if not res["code"] == 100:
            return  # 强制忽略空白图片
        textOut = ""
        for r in res["data"]:
            textOut += r["text"] + "\n"
        with open(self.outputPath, "a", encoding="utf-8") as f:  # 追加写入本地文件
            f.write(textOut)
