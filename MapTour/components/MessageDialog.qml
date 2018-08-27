import QtQuick 2.3
import QtQuick.Controls 2.2 as NewControls
import QtQuick.Controls.Material 2.2
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import QtQuick.Layouts 1.1
import ".."

Item {
    id: messageDialog
    signal rightButtonClicked()
    signal leftButtonClicked()
    signal transitionInCompleted()
    signal transitionOutCompleted()

    property bool isDebug: false
    property bool showRightButton: true
    property bool showLeftButton: true

    property string titleText: "Title"
    property string descriptionText: "This is description!"
    property string leftButtonText: qsTr("CANCEL")
    property string rightButtonText: qsTr("OK")

    property int titleTextSize: theme.fontTitleSize
    property int descriptionTextSize: theme.fontBodySize
    property int buttonTextSize: theme.fontBodySize

    property color titleTextColor: theme.colorTitle
    property color descriptionTextColor: theme.colorBody
    property color buttonBorderColor: theme.colorButtonBorder
    property color buttonTextColor: theme.colorButtonText
    property color buttonBackgroundColor: theme.colorButtonFilling

    property color themeColor: "steelBlue"

    function units(num) {
        return num ? parseInt(num*AppFramework.displayScaleFactor) : 0
    }

    function close(){
        _root._closeAnimation()
        visible = false
    }

    function open(){
        _root._openAnimation()
    }

    Theme {
        id: theme
    }

    anchors.fill: parent

    BasicDialog{
        id: _root

        header: Rectangle{
            width: parent.width
            height: headerText.text>""? headerText.contentHeight:units(8)
            color: "transparent"
            border.color: "pink"
            border.width: isDebug ? 1 : 0
            visible: headerText>""
            Text {
                width: parent.width

                id: headerText
                text: ""
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 2
                font.pointSize: titleTextSize
                font.family: app.customTitleFont.name
                font.bold: false
                color: titleTextColor
            }
        }

        content: Rectangle{
            width: parent.width
            height: {contentText.text>""?contentText.contentHeight + units(16) :0}   //fit the children
            color: "transparent"
            visible: contentText.text>""
            clip: true
            border.color: "pink"
            border.width: isDebug ? 1 : 0
            Text {
                id: contentText
                width: parent.width
                text: descriptionText
                font.pointSize: descriptionTextSize
                font.family: app.customTextFont.name
                wrapMode: Text.Wrap
                color: descriptionTextColor

            }
        }


        footer: Rectangle{
            anchors.fill: parent
            color: "transparent"
            border.color: "pink"
            border.width: isDebug ? 1 : 0
            RowLayout{
                id: buttons

                Layout.fillHeight: true
                Layout.fillWidth: true
                anchors.right: parent.right

                layoutDirection: Qt.RightToLeft
                spacing: units(8)
                property real verticalPadding: Qt.platform.os === "windows" ? units(8.9) : units(9.5)

                NewControls.Button {
                    id: rightButton

                    visible: showRightButton
                    padding: buttons.verticalPadding
                    leftPadding: units(24)
                    rightPadding: units(24)
                    text: rightButtonText
                    background: Rectangle {
                        color: Qt.darker(themeColor)
                        border.color: Qt.darker(themeColor)
                    }
                    contentItem: Text {
                        id: rightBtnContent
                        text: rightButton.text
                        color: "white"
                        font.pointSize: buttonTextSize
                    }
                    onClicked: {
                        rightButtonClicked()
                    }
                }

                NewControls.Button {
                    id: leftButton

                    visible: showLeftButton
                    padding: buttons.verticalPadding
                    leftPadding: units(24)
                    rightPadding: units(24)
                    text: leftButtonText
                    background: Rectangle {
                        color: "white"
                        border.color: Qt.darker(themeColor)
                    }
                    contentItem: Text {
                        id: leftBtnContent
                        text: leftButton.text
                        color: Qt.darker(themeColor)
                        font.pointSize: buttonTextSize
                    }
                    onClicked: {
                        leftButtonClicked()
                    }
                }
            }
        }

        onTransitionInCompleted: {
            messageDialog.transitionInCompleted()
        }

        onTransitionOutCompleted: {
            messageDialog.transitionOutCompleted()
        }
    }
}
