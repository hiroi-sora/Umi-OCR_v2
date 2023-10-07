// ===========================================
// =============== 结果面板布局 ===============
// ===========================================

import QtQuick 2.15
import QtQuick.Controls 2.15
import "../"

Item {
    ListModel { id: resultsModel } // OCR结果模型

    // ========================= 【对外接口】 =========================

    property alias ctrlBar: ctrlBar // 控制栏的引用

    // 添加一条OCR结果。元素：
    // timestamp 时间戳，秒为单位
    // title 左边显示标题，可选
    // code 结果代码， data 结果内容
    // 返回结果字符串
    function addOcrResult(res) {
        // 提取并转换结果时间
        let date = new Date(res.timestamp * 1000)  // 时间戳转日期对象
        let year = date.getFullYear()
        let month = ('0' + (date.getMonth() + 1)).slice(-2)
        let day = ('0' + date.getDate()).slice(-2)
        let hours = ('0' + date.getHours()).slice(-2)
        let minutes = ('0' + date.getMinutes()).slice(-2)
        let seconds = ('0' + date.getSeconds()).slice(-2)
        let dateTimeString = `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
        // 提取结果文本和状态
        let status_ = ""
        let resText = ""
        switch(res.code){
            case 100: // 成功
                status_ = "text"
                const textArray = res.data.map(item => item.text);
                resText = textArray.join('\n');
                break
            case 101: // 无文字
                status_ = "noText"
                break
            default: // 失败
                status_ = "error"
                resText = qsTr("异常状态码：%1\n异常信息：%2").arg(res.code).arg(res.data)
                break
        }
        if(res.title === undefined)
            res.title = "" // 补充空白参数
        // 添加到列表模型
        resultsModel.append({
            "status__": status_,
            "title": res.title,
            "datetime": dateTimeString,
            "resText": resText,
            "timestamp": res.timestamp,
        })
        // 自动滚动
        if(autoToBottom) {
            tableView.toBottom()
        }
        return resText
    }

    // 搜索一个结果。可传入 title 或 timestamp
    function getResult(title="", timestamp=-1) {
        for (let i = 0, l=resultsModel.count; i < l; i++) {
            let item = resultsModel.get(i);
            if (item.title === title || item.timestamp === timestamp) {
                return item
            }
        }
        return undefined
    }
    
    // ========================= 【布局】 =========================

    anchors.fill: parent
    clip: true // 溢出隐藏
    property bool autoToBottom: true // 自动滚动到底部

    // 内容滚动组件
    TableView {
        id: tableView
        anchors.fill: parent
        anchors.rightMargin: size_.smallSpacing
        rowSpacing: size_.spacing // 行间隔
        contentWidth: parent.width // 内容宽度
        model: resultsModel // 模型
        flickableDirection: Flickable.VerticalFlick // 只允许垂直滚动
        boundsBehavior: Flickable.StopAtBounds // 禁止flick过冲。不影响滚轮滚动的过冲

        // 滚动到底部
        function toBottom() {
            bottomTimer.running = true
        }
        Timer {
            id: bottomTimer
            interval: 100
            running: false
            repeat: true // 重复执行
            onTriggered: {
                // 已滚动到底部
                if(scrollBar.position  >= (1 - scrollBar.size)) {
                    bottomTimer.running = false
                    tableView.returnToBounds() // 确保未越界
                }
                // 未滚动到底部，重复将滚动条拉到底
                else {
                    scrollBar.position = (1 - scrollBar.size)
                }
            }
        }
        // 宽度设定函数
        columnWidthProvider: (column)=>{
            if(column == 0){ // 第一列宽度，变化值
                return tableView.width
            }
        }
        onWidthChanged: {  // 组件宽度变化时重设列宽
            Qt.callLater(()=>{ // 延迟调用
                tableView.forceLayout() 
            })
        }
        // 元素
        delegate: ResultTextContainer {
            status_: status__
            textLeft: title
            textRight: datetime
            textMain: resText
            onTextHeightChanged: tableView.forceLayout // 文字高度改变时重设列宽
            onTextMainChanged: {
                resultsModel.setProperty(index, "resText", textMain) // 文字改变时写入列表
            }
        } 
        // 滚动条
        ScrollBar.vertical: ScrollBar { id:scrollBar }
    }

    // 外置控制栏
    Item {
        id: ctrlBar
        height: size_.text*1.5
        anchors.left: parent.left
        anchors.right: parent.right

        Button_ {
            id: ctrlBtn1
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            text_: qsTr("清空")
            textColor_: theme.noColor
            onClicked: {
                resultsModel.clear()
            }
        }
        CheckButton {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: ctrlBtn1.left
            text_: qsTr("滚动")
            toolTip: qsTr("自动滚动到底部")
            textColor_: autoToBottom ? theme.textColor : theme.subTextColor
            checked: autoToBottom
            enabledAnime: true
            onCheckedChanged: {
                autoToBottom = checked
                if(checked) {
                    tableView.toBottom()
                }
                else {
                    bottomTimer.running = false
                }
            }
        }
    }
}