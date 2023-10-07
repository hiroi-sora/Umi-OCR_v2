// =============== 批量OCR页面的文件表格面板 ===============

import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.qmlmodels 1.0 // 表格
import QtGraphicalEffects 1.15 // 子元素圆角
import QtQuick.Dialogs 1.3 // 文件对话框

import "../../Widgets"

Item{
    id: filesTablePanel

    // ========================= 【逻辑】 =========================

    property string herderEleFile: qsTr("文件")
    property string msnState // 任务状态，父组件传入
    property alias tableView: tableView
    // 表头模型
    ListModel {
        id: headerModel
        ListElement { display: "" } // 动态变化
        ListElement { display: qsTr("耗时") }
        ListElement { display: qsTr("状态") }
    }
    // 表格模型
    TableModel {
        id: tableModel
        TableModelColumn { display: "filePath" }
        TableModelColumn { display: "time" }
        TableModelColumn { display: "state" }
        rows: [] // 初始为空行
        onRowCountChanged: {
            if(rowCount>0)
                headerModel.set(0, {display: `${herderEleFile} (${rowCount})`})
            else
                headerModel.set(0, {display: herderEleFile})
        }
    }
    // 记录文件路径到tableModel对应项的字典， [filePath]{index: tableModel序号}
    property var filesDict: {}
    property alias filesModel: tableModel
    // 列宽。第一列随总体宽度自动变化（[0]表示最小值），剩余列为固定值。
    property var columnsWidth: [size_.smallText*6, size_.smallText*4, size_.smallText*4]
    property int othersWidth: 0 // 除第一列以外的列宽，初始时固定下来。
    Component.onCompleted: {
        if(filesDict==undefined){
            filesDict = {}
        }
        // 计算剩余列的固定值。
        for(let i = 1;i < columnsWidth.length; i++)
            othersWidth += columnsWidth[i]
    }

    // 清空表格
    function clearTable() {
        if(msnState !== "none")
            return
        tableModel.clear()
        filesDict = {}
    }

    // 定义信号
    signal addImages(var paths) // 添加图片的信号
    signal clickImage(var path) // 点击图片条目的信号
    signal doubleClickImage(var path)

    // ========================= 【布局】 =========================

    // 文件选择对话框
    // QT-5.15.2 会报错：“Model size of -225 is less than 0”，不影响使用。
    // QT-5.15.5 修复了这个Bug，但是PySide2尚未更新到这个版本号。只能先忍忍了
    // https://bugreports.qt.io/browse/QTBUG-92444
    FileDialog_ {
        id: fileDialog
        title: qsTr("请选择图片")
        nameFilters: [qsTr("图片")+" (*.jpg *.jpe *.jpeg *.jfif *.png *.webp *.bmp *.tif *.tiff)"]
        folder: shortcuts.pictures
        selectMultiple: true // 多选
        onAccepted: {
            addImages(fileDialog.fileUrls_) // 发送信号
        }
    }

    // 表格区域
    Rectangle {
        id: tableArea
        anchors.fill: parent
        color: theme.bgColor

        Item {
            id: tableContainer
            anchors.fill: parent

            // 上方操控版
            Item {
                id: tableTopPanel
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: size_.text * 2

                // 左打开图片按钮
                IconTextButton {
                    visible: parent.width > width*1.6 // 容器宽度过小时隐藏
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: size_.smallSpacing * 0.5
                    icon_: "folder"
                    text_: qsTr("选择图片")

                    onClicked: {
                        if(msnState === "none")
                            fileDialog.open()
                    }
                    
                }

                // 右清空按钮
                IconTextButton {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: size_.smallSpacing * 0.5
                    icon_: "clear"
                    text_: qsTr("清空")

                    onClicked: {
                        clearTable()
                    }
                }
            }

            // 提示
            Rectangle {
                visible: tableModel.rowCount == 0
                anchors.top: tableTopPanel.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: tableArea.color
                Text_ {
                    anchors.centerIn: parent
                    text: qsTr("请拖入或选择图片")
                }
            }

            // 表头
            HorizontalHeaderView {
                id: tableViewHeader
                syncView: tableView
                anchors.top: tableTopPanel.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: size_.smallText * 2
                model: headerModel // 模型

                // 元素
                delegate: Rectangle {
                    implicitWidth: 0
                    implicitHeight: size_.smallText * 2
                    border.width: 1
                    color: "#00000000"
                    border.color: theme.coverColor1
                    clip: true
                    Text_ {
                        text: display
                        anchors.centerIn: parent
                        font.pixelSize: size_.smallText
                    }
                }
            }

            // 表格本体
            Item {
                anchors.top: tableViewHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true

                // 左边表格
                TableView {
                    id: tableView
                    anchors.fill: parent
                    contentWidth: parent.width // 内容宽度
                    model: tableModel // 模型
                    flickableDirection: Flickable.VerticalFlick // 只允许垂直滚动
                    property int hoveredRow: -1 // 鼠标悬停的列表序号
                    property var hoveredY: -1 // 鼠标悬停的组件的y值

                    ToolTip_ {
                        visible: tableView.hoveredRow>-1
                        text: tableView.hoveredRow>-1 ? tableModel.getRow(tableView.hoveredRow).filePath : ""
                        y: tableView.hoveredY-height
                    }

                    // 宽度设定函数
                    columnWidthProvider: (column)=>{
                        if(column == 0){ // 第一列宽度，变化值
                            let w = parent.width - filesTablePanel.othersWidth // 计算宽度
                            return Math.max(w, columnsWidth[0]) // 宽度不得小于最小值
                        }
                        else{ return columnsWidth[column] }
                    }
                    onWidthChanged: forceLayout()  // 组件宽度变化时重设列宽
                    
                    // 元素
                    delegate: Rectangle {
                        implicitWidth: 0
                        implicitHeight: size_.smallText * 1.5
                        border.width: 1
                        color: "#00000000"
                        border.color: theme.coverColor1
                        clip: true

                        Text_ {
                            text: column===0 ? getFileName(display) : display // 如果是地址，则转为文件名显示
                            color: row===tableView.hoveredRow ? theme.textColor : theme.subTextColor
                            // 文件名左对齐，其它项居中对齐
                            anchors.horizontalCenter: column===0 ? undefined : parent.horizontalCenter
                            anchors.left: column===0 ? parent.left : undefined
                            anchors.leftMargin: size_.smallText * 0.5
                            font.pixelSize: size_.smallText
                            font.family: theme.dataFontFamily
                        }

                        // 从路径中提取文件名
                        function getFileName(filePath) {
                            let parts = filePath.split("/")
                            let fileName = parts[parts.length - 1]
                            return fileName
                        }

                        MouseArea { // 鼠标悬停在一行上时，高亮一行
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                tableView.hoveredRow = row
                                tableView.hoveredY = parent.y
                            }
                            onExited: {
                                tableView.hoveredRow = -1
                                tableView.hoveredY = -1
                            }
                            onClicked: {
                                clickImage(tableModel.getRow(row).filePath)
                            }
                            onDoubleClicked: {
                                doubleClickImage(tableModel.getRow(row).filePath)
                            }
                        }
                    }
                    ScrollBar.vertical: ScrollBar { }
                }
            }
        }

        // 内圆角裁切
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: tableContainer.width
                height: tableContainer.height
                radius: size_.btnRadius
            }
        }
    }
}