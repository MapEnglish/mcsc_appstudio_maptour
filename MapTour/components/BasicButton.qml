import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0
import ".."

Item {
    id: root

    width: parseInt(110*scaleFactor)
    height: parseInt(width/3)

    property bool fillColor: true
    property color backgroundColor: theme.colorButtonFilling
    property color textColor: theme.colorButtonText
    property url iconSource: ""
    property int margins: theme.units(16)
    property int fontPointSize: theme.fontBodySize
    property string buttonText: "Button"
    property color buttonBorderColor: theme.colorButtonBorder

    property color inkColor: theme.colorInk
    property color inkFocusColor: theme.colorInkFocus

    property real scaleFactor : AppFramework.displayScaleFactor
    property real radius: 0

    Theme {
        id: theme
    }

    signal buttonClicked(var mouse)
    property alias label: label
    Rectangle {
        anchors.fill: parent
        border.color: buttonBorderColor
        radius: root.radius
        color: fillColor ? backgroundColor : "transparent"
        border.width: theme.units(1)

        Ink {
            id: ink
            anchors.centerIn: parent
            enabled: true
            centered: true
            circular: true
            color: inkColor
            focusColor: inkFocusColor
            width: parent.width
            height: parent.height
            onClicked: {
                console.log("ink clicked")
                buttonClicked(mouse)
            }
        }

        Text {
            id: label
            height: parent.height
            anchors.centerIn: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            fontSizeMode: Text.HorizontalFit
            font.pointSize: fontPointSize
            font.family: app.customTitleFont.name
            text: buttonText
            maximumLineCount: 1
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: textColor
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                buttonClicked(mouse)
            }
        }

    }

}
