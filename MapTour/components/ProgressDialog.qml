import QtQuick 2.3
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import ".."

Item {
    id: progressDialog
    signal rightButtonClicked()
    signal leftButtonClicked()
    signal transitionInCompleted()
    signal transitionOutCompleted()

    property bool isDebug: false

    property real progressValue: 0.0

    property string titleText: "Title"
    property string descriptionText: "This is description!"
    property string rightButtonText: qsTr("RESTART")
    property string leftButtonText: qsTr("CANCEL")

    property int titleTextSize: theme.fontTitleSize
    property int descriptionTextSize: theme.fontBodySize
    property int buttonTextSize: theme.fontBodySize

    property color titleTextColor: theme.colorTitle
    property color descriptionTextColor: theme.colorBody
    property color buttonBorderColor: theme.colorButtonBorder
    property color buttonTextColor: theme.colorButtonText
    property color buttonBackgroundColor: theme.colorButtonFilling
    property alias maskBackgroundColor: _root.maskBackgroundColor

    property color progressBarColor: theme.colorProgress
    property color progressBarBackgroundColor: theme.colorProgressBackground
    property color progressBarBorderColor: theme.colorProgressBorder

    property alias progressBar: progressBar
    property alias leftButton: leftButton
    property alias rightButton: rightButton

    function units(num) {
        return num ? num*AppFramework.displayScaleFactor : 0
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
            height: {return titleText>""?headerText.contentHeight:0}
            color: "transparent"
            border.color: "pink"
            border.width: isDebug ? 1 : 0

            Text {
                width: parent.width

                id: headerText
                text: titleText
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                maximumLineCount: 2
                font.pointSize: titleTextSize
                font.bold: false
                font.family: app.customTitleFont.name
                color: titleTextColor
            }
        }

        content: Rectangle{
            width: parent.width
            height: {
                var height = progressBar.visible ? progressBar.height : 0
                if(descriptionText>"") height+=contentText.contentHeight+units(10)
                return height
            }
            color: "transparent"
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
                visible: {return descriptionText.length>0}
            }
            ProgressBar{
                id: progressBar
                visible: false
                anchors.top: contentText.visible?contentText.bottom:parent.top
                anchors.topMargin: contentText.visible? units(14):0
                width: parent.width
                height: units(20)
                value: progressValue

                style: ProgressBarStyle {
                    background: Rectangle {
                        radius: 2
                        color: progressBarBackgroundColor
                        border.color: progressBarBorderColor
                        border.width: 1
                        implicitWidth: 200
                        implicitHeight: 24
                    }
                    progress: Rectangle {
                        color: progressBarColor
                        border.color: progressBarBorderColor
                    }
                }
            }
        }


        footer: Rectangle{
            anchors.fill: parent
            color: "transparent"
            border.color: "pink"
            border.width: isDebug ? 1 : 0

            RowLayout{
                Layout.fillHeight: true
                Layout.fillWidth: false
                anchors.right: parent.right

                layoutDirection: Qt.RightToLeft

                BasicButton {
                    id: rightButton
                    width: units(76)
                    height: units(36)
                    fillColor: true
                    fontPointSize: buttonTextSize
                    textColor: buttonTextColor
                    backgroundColor: buttonBackgroundColor
                    buttonText: rightButtonText
                    onButtonClicked: {
                        rightButtonClicked()
                    }
                }

                BasicButton {
                    id: leftButton
                    width: units(76)
                    height: units(36)
                    fillColor: true
                    fontPointSize: buttonTextSize
                    textColor: buttonTextColor
                    backgroundColor: buttonBackgroundColor
                    buttonText: leftButtonText
                    onButtonClicked: {
                        leftButtonClicked()
                    }
                }
            }
        }

        onTransitionInCompleted: {
            progressDialog.transitionInCompleted()
        }

        onTransitionOutCompleted: {
            progressDialog.transitionOutCompleted()
        }
    }


}

