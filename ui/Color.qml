import QtQuick
import QtQuick.Controls.Material
import QtCore

QtObject {
    id: themeColor

    // ——————————————————————————————————————配色配置部分——————————————————————————————————————————
    // 这是在 item list panel, detail page panel, settings panel 贯穿的全局默认配色
    property color panelColor: "#E3F2FD"
    // 这是在 add button 和 滚动条的默认配色
    property color buttonColor: "skyblue"
    // 这是链接的默认配色
    property color linkColor: "#1E88E5"
    // 这是分割线的默认配色
    property color lineColor: "#B0BEC5"
    // 这是边框的默认配色
    property color borderColor: "#CFD8DC"

    // (this part was coded by Codex) 根据彩蛋颜色的深浅程度，动态计算当前标题文字颜色，以及小文字的颜色
    readonly property real panelLuma: (0.299 * panelColor.r) + (0.587 * panelColor.g) + (0.114 * panelColor.b) // 实时刷新值，为当前对比度值。luma值越小，颜色越暗。
    readonly property bool panelColorIsDark: panelLuma < 0.7 // 当前对比度值小于对比度基准值的，被判断为暗色（白字）；大于对比度基准值的，被判断为亮色（黑字）。
    property color panelTitleTextColor: panelColorIsDark ? "white" : Material.foreground // 暗色取白色字，亮色取系统默认值（黑字）
    property color panelInfoTextColor: panelColorIsDark ? "white" : "#607D8B" // 暗色取白色字，亮色取淡灰色

    // QtCode Settings to save color Index automatically
    property var colorSettings: Settings {
        property int colorIndex: 0 // 默认色index为0
    }

    /* Color设置项的六个颜色index：
    0. 默认色（即#87CEEB）
    1. 黄色：#ffc300
    2. 海蓝色(深色模式)：#0285ff
    3. 绿色(深色模式)：#04b84c
    4. 粉色(深色模式)：#ff66ad
    5. 橙色(深色模式)：#fb6a22 */
    // 第一主题色，用于panel、滚动条、按钮、链接等
    readonly property var themeColorValues: ["#87CEEB", "#ffc300", "#0285ff", "#04b84c",  "#ff66ad", "#fb6a22"]
    property int selectedColorIndex: 0

    // 第二主题色，用于浅色字体、边框、分割线等
    readonly property var themeSecondaryColorValues: ["#607D8B", "#7A5A00", "#D7ECFF", "#DDF7E8", "#FFE0EF", "#FFE4D6"]

    // combobox选择软件颜色
    function setSelectedColorIndex(index) {
        let colorIndex;

        // 若传入的index合法，则保持不变，否则恢复默认
        if (index >= 0 && index < themeColorValues.length) {
            colorIndex = index;
        } else {
            colorIndex = 0;
        }

        const selectedColor = themeColorValues[colorIndex];
        const selectedSecondaryColor = themeSecondaryColorValues[colorIndex];
        selectedColorIndex = colorIndex;
        colorSettings.colorIndex = colorIndex;

        // 默认色保留默认设置 颜色精分
        if (colorIndex === 0) {
            panelColor = "#E3F2FD";
            buttonColor = "skyblue";
            linkColor = "#1E88E5";
            lineColor = "#B0BEC5";
            borderColor = "#CFD8DC";
            panelInfoTextColor = "#607D8B";
        } else
        // 其余情况，只分主题色和第二主题色
        {
            panelColor = selectedColor;
            buttonColor = selectedColor;
            linkColor = selectedColor;
            lineColor = selectedSecondaryColor;
            borderColor = selectedSecondaryColor;
            panelInfoTextColor = selectedSecondaryColor;
        }
    }

    Component.onCompleted: setSelectedColorIndex(colorSettings.colorIndex)
}
