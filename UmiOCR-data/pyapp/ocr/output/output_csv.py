# 输出到csv表格文件

from .output import Output

import csv


class OutputCsv(Output):
    def __init__(self, argd):
        self.dir = argd["outputDir"]  # 输出路径（文件夹）
        self.fileName = argd["outputFileName"]  # 文件名
        self.fileName = self.fileName.replace(
            "%name", argd["outputDirName"]
        )  # 文件名添加路径名
        self.outputPath = f"{self.dir}/{self.fileName}.csv"  # 输出路径
        self.ingoreBlank = argd["ingoreBlank"]  # 忽略空白文件
        self.headers = ["Image Name", "OCR", "Image Path"]  # 表头
        self.lineBreak = "\n"  # 换行符
        # 创建输出文件
        try:
            with open(
                self.outputPath, "w", encoding="utf-8", newline=""
            ) as f:  # 覆盖创建文件
                writer = csv.writer(f)
                writer.writerow(self.headers)  # 写入CSV表头
        except Exception as e:
            raise Exception(f"Failed to create csv file. {e}\n创建csv文件失败。")

    def print(self, res):  # 输出图片结果
        if not res["code"] == 100 and self.ingoreBlank:
            return  # 忽略空白图片
        name = res["fileName"]
        path = res["path"]
        textOut = ""
        if res["code"] == 100:
            for tb in res["data"]:
                if tb["text"]:
                    textOut += tb["text"] + self.lineBreak
        elif res["code"] == 101:
            pass
        else:
            textOut += f'[Error] OCR failed. Code: {res["code"]}, Msg: {res["data"]}  \n【异常】OCR识别失败。'

        writeList = [name, textOut, path]
        with open(self.outputPath, "a", encoding="utf-8", newline="") as f:  # 追加写入本地文件
            writer = csv.writer(f)
            writer.writerow(writeList)
