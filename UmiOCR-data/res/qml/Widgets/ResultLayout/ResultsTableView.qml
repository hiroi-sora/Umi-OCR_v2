// ===========================================
// =============== 结果面板布局 ===============
// ===========================================

import QtQuick 2.15
import QtQuick.Controls 2.15
import "../"

Item {
    ListModel { id: resultsModel_ }
    property alias resultsModel: resultsModel_
    anchors.fill: parent
    clip: true // 溢出隐藏

    // 左边表格
    TableView {
        id: tableView
        anchors.fill: parent
        anchors.rightMargin: theme.smallSpacing
        rowSpacing: theme.spacing // 行间隔
        contentWidth: parent.width // 内容宽度
        model: resultsModel // 模型
        flickableDirection: Flickable.VerticalFlick // 只允许垂直滚动

        // 宽度设定函数
        columnWidthProvider: (column)=>{
            if(column == 0){ // 第一列宽度，变化值
                return tableView.width
            }
        }
        onWidthChanged: forceLayout()  // 组件宽度变化时重设列宽
        // 元素
        delegate: ResultTextContainer {
            textLeft: textLeft_
            textRight: textRight_
            textMain: textMain_
        } 
        ScrollBar.vertical: ScrollBar { }
    }
}