// ===========================================
// =============== 基础浅色样式 ===============
// ===========================================

import QtQuick 2.15

Theme {
    // 名称
    themeTitle: qsTr("明亮")

    // 背景颜色
    bgColor: "#FFF"
    
    // 主题颜色，不透明，由浅到深
    themeColor1: "#FCF9BE" // 背景
    themeColor2: "#FFDCA9" // 装饰性前景
    themeColor3: "#C58940" // 文字

    // 叠加层颜色，从浅到深
    coverColor1: "#11000000" // 大部分需要突出的背景
    coverColor2: "#22000000" // 按钮悬停
    coverColor3: "#33000000" // 阴影
    coverColor4: "#55000000" // 按钮按下

    // 标签栏颜色
    tabBarColor: "#F3F3F3"

    // 主要文字颜色
    textColor: "#000"
    // 次要文字颜色
    subTextColor: "#555"

    // 表示允许、成功的颜色
    yesColor: "#00CC00"
    // 表示禁止、失败的颜色
    noColor: "#FF0000"
}