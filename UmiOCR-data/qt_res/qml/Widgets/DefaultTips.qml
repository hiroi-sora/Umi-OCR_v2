// =======================================
// =============== 默认提示 ===============
// =======================================

import QtQuick 2.15

// 提示
Item {
    property string tips: "" // 提示文本
    property var visibleFlag // 只要该变量改变，就永久隐藏该组件

    onVisibleFlagChanged: if(visible) visible = false

    TextEdit_ {
        anchors.centerIn: parent
        readOnly: true
        selectByMouse: false
        selectByKeyboard: false
        font.family: theme.fontFamily
        text: tips
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.ArrowCursor
        }
    }
}