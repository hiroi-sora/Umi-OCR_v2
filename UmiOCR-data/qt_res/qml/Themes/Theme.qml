// =========================================
// =============== 样式的基类 ===============
// =========================================

import QtQuick 2.15

Item {
    // 主题名称
    property string themeTitle: "Unknow theme"

    // ========================= 【颜色】 =========================

    property color tabBarColor // 标签栏
    property color bgColor // 背景
    property color textColor // 主要文字
    property color subTextColor // 次要文字
    property color yesColor // 允许、成功
    property color noColor // 禁止、失败
    property color specialBgColor // 特殊背景，弹窗确认按钮
    property color specialTextColor // 特殊前景，文字、图标
    // 叠加层颜色，半透明，从浅到深
    property color coverColor1 // 大部分需要突出的背景
    property color coverColor2 // 按钮悬停
    property color coverColor3 // 阴影
    property color coverColor4 // 按钮按下

    // 必要的键
    property var keys: [
        "themeTitle",
        "tabBarColor",
        "bgColor",
        "textColor",
        "subTextColor",
        "yesColor",
        "noColor",
        "specialBgColor",
        "specialTextColor",
        "coverColor1",
        "coverColor2",
        "coverColor3",
        "coverColor4",
    ]
    // 主题名称，允许翻译
    property var titles: {
        "Default Light": qsTr("珍珠白"),
        "Default Dark": qsTr("云墨黑"),
        "Cyberpunk": qsTr("赛博朋克"),
        "OceanBlue": qsTr("海洋蓝"),
        "Vintage Brown": qsTr("复古棕"),
        "Pastel Pink": qsTr("猛男粉"),
        "Nature Green": qsTr("自然绿"),
        "Midnight Purple": qsTr("午夜紫"),
    }
    // 默认主题 / 当前读入的主题配置
    property var all: {
        // 默认主题
        "Default Light": {
            "themeTitle": titles["Default Light"],
            "tabBarColor": "#F3F3F3",
            "bgColor": "#FFF",
            "textColor": "#000",
            "subTextColor": "#555",
            "yesColor": "#00CC00",
            "noColor": "#FF0000",
            "specialBgColor": "#FCF9BE",
            "specialTextColor": "#C58940",
            "coverColor1": "#11000000",
            "coverColor2": "#22000000",
            "coverColor3": "#33000000",
            "coverColor4": "#55000000",
        },
        "Default Dark": {
            "themeTitle": titles["Default Dark"],
            "tabBarColor": "#4A4A4A",
            "bgColor": "#444",
            "textColor": "#FFF",
            "subTextColor": "#AAA",
            "yesColor": "#6EFC39",
            "noColor": "#FF2E2E",
            "specialBgColor": "#005c99",
            "specialTextColor": "#00BFFF",
            "coverColor1": "#22FFFFFF",
            "coverColor2": "#33FFFFFF",
            "coverColor3": "#44FFFFFF",
            "coverColor4": "#55FFFFFF",
        },
        // 抄： https://github.com/altercation/solarized
        "Solarized Light": {
            "themeTitle": "Solarized Light",
            "tabBarColor": "#d9d2c2",
            "bgColor": "#fdf6e3",
            "textColor": "#586e75",
            "subTextColor": "#839496",
            "yesColor": "#48985d",
            "noColor": "#e51d09",
            "specialBgColor": "#FCF9BE",
            "specialTextColor": "#C58940",
            "coverColor1": "#11000000",
            "coverColor2": "#22000000",
            "coverColor3": "#33000000",
            "coverColor4": "#55000000"
        },
        "Solarized Dark": {
            "themeTitle": "Solarized Dark",
            "tabBarColor": "#004052",
            "bgColor": "#002b36",
            "textColor": "#93a1a1",
            "subTextColor": "#657b83",
            "yesColor": "#6EFC39",
            "noColor": "#f14c4c",
            "specialBgColor": "#00517D",
            "specialTextColor": "#00BFFF",
            "coverColor1": "#19FFFFFF",
            "coverColor2": "#29FFFFFF",
            "coverColor3": "#44FFFFFF",
            "coverColor4": "#55FFFFFF"
        },
        // 抄： https://github.com/Fndroid/clash_for_windows_pkg
        "Cyberpunk": {
            "themeTitle": "Cyberpunk",
            "tabBarColor": "#084A5A",
            "bgColor": "#136377",
            "textColor": "#FCEC0C",
            "subTextColor": "#CF9F0F",
            "yesColor": "#6EFC39",
            "noColor": "#FF5E5E",
            "specialBgColor": "#00517D",
            "specialTextColor": "#00BFFF",
            "coverColor1": "#33000000",
            "coverColor2": "#29FFFFFF",
            "coverColor3": "#44FFFFFF",
            "coverColor4": "#55FFFFFF"
        },
        "OceanBlue": {
            "themeTitle": "海洋蓝",
            "tabBarColor": "#0F4C75",
            "bgColor": "#F0F5F9",
            "textColor": "#333",
            "subTextColor": "#777",
            "yesColor": "#00A8E8",
            "noColor": "#FF5858",
            "specialBgColor": "#C7EEFF",
            "specialTextColor": "#0085A1",
            "coverColor1": "#11000000",
            "coverColor2": "#22000000",
            "coverColor3": "#33000000",
            "coverColor4": "#55000000"
        },
        
        "Vintage Brown": {
            "themeTitle": "复古棕",
            "tabBarColor": "#603C29",
            "bgColor": "#F2E8DA",
            "textColor": "#56413E",
            "subTextColor": "#8F6F65",
            "yesColor": "#B86F52",
            "noColor": "#CF4B3D",
            "specialBgColor": "#FFDAB9",
            "specialTextColor": "#8A4B08",
            "coverColor1": "#11000000",
            "coverColor2": "#22000000",
            "coverColor3": "#33000000",
            "coverColor4": "#55000000"
        },
            
        "Pastel Pink": {
            "themeTitle": "猛男粉",
            "tabBarColor": "#FFDDE1",
            "bgColor": "#FFF4F6",
            "textColor": "#8C3A4F",
            "subTextColor": "#B17D8D",
            "yesColor": "#FF85A2",
            "noColor": "#FF4D6B",
            "specialBgColor": "#FFC2D6",
            "specialTextColor": "#FF1493",
            "coverColor1": "#11000000",
            "coverColor2": "#22000000",
            "coverColor3": "#33000000",
            "coverColor4": "#55000000"
        },
            
        "Nature Green": {
            "themeTitle": "自然绿",
            "tabBarColor": "#4D774E",
            "bgColor": "#E4F5E0",
            "textColor": "#3D6D3A",
            "subTextColor": "#6B9F6A",
            "yesColor": "#8DC63F",
            "noColor": "#6CAB32",
            "specialBgColor": "#AFF07E",
            "specialTextColor": "#008000",
            "coverColor1": "#11000000",
            "coverColor2": "#22000000",
            "coverColor3": "#33000000",
            "coverColor4": "#55000000"
        },
            
        "Midnight Purple": {
            "themeTitle": "午夜紫",
            "tabBarColor": "#2D112C",
            "bgColor": "#322947",
            "textColor": "#D6D1E5",
            "subTextColor": "#AFA6C4",
            "yesColor": "#B081B9",
            "noColor": "#D25FD1",
            "specialBgColor": "#1F0E1E",
            "specialTextColor": "#8B008B",
            "coverColor1": "#11000000",
            "coverColor2": "#22000000",
            "coverColor3": "#33000000",
            "coverColor4": "#55000000"
        }
    }
    // 主题控制器
    property ThemeManager manager: ThemeManager{}

    // ========================= 【字体】 =========================

    // 主要UI文字字体，内容可控，可以用裁切的ttf
    property string fontFamily: "Microsoft YaHei"
    // 数据显示文字字体，内容不可控，用兼容性好的系统字体
    property string dataFontFamily: "Microsoft YaHei"
}