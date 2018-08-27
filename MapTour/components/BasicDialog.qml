import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import ArcGIS.AppFramework 1.0


Item {
    property bool isDebug: false
    property bool isPortrait: parent.width < parent.height

    signal transitionInCompleted()
    signal transitionOutCompleted()

    property real scaleFactor : AppFramework.displayScaleFactor

    property alias _backgroundContainer: _backgroundContainer
    property color maskBackgroundColor : theme.colorDialogMask
    property color dialogBackgroundColor: theme.colorDialogBack

    property int transitionDuration: 200
    property int footerHeight : units(40)
    property int dialogWidth: Math.min(parent.width*0.8, units(400))
    property int dialogHeight : {
        var max = parent.height *0.9
        var height = content.height + header.height + footer.height+ units(24+20)
        if(!header.visible) height = height - units(28+20)
        if(isDebug)console.log(height)
        return height > max ? max : height
    }

    function units(num) {
        return num ? num*AppFramework.displayScaleFactor : 0
    }

    clip: true

    width: parent.width
    height: parent.height

    // customized dialog settings
    property Item header: Item {}
    property Item content: Item {}
    property Item footer: Item {}

    // local settings
    property real dialogOpacity: 0.0

    // open animation
    function _openAnimation(){
        parent.visible=true
        _dialogFadeInAnimation.start()
    }

    // close animation
    function _closeAnimation(){
        _dialogFadeOutAnimation.start()
    }

    Theme {
        id: theme
    }

    // background mask
    Rectangle{
        id: _backgroundContainer
        color: maskBackgroundColor
        width: parent.width
        height: parent.height

        MouseArea{
            anchors.fill: parent
            preventStealing: true
            onWheel: {
                wheel.accepted = true
            }
        }

        // dialog container
        Rectangle{
            id: _dialogContainer
            width: dialogWidth
            height: dialogHeight
            anchors.centerIn: parent

            color: dialogBackgroundColor
            border.color: "green"
            border.width: isDebug ? 1 : 0
            clip: true

            // header
            Rectangle {
                id: headercontainer
                width: parent.width
                height: header.height
                anchors{
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: header.visible? units(14):0
                    leftMargin: units(14)
                    rightMargin: units(14)
                }
                color: "transparent"
                children: [header]
//                visible: header.visible
                clip: true
            }

            // content
            Rectangle {
                id: contentcontainer
                width: parent.width
                height: content.height

                anchors{
                    top: header.visible? headercontainer.bottom: parent.top
                    left: parent.left
                    right: parent.right
                    topMargin: units(1)
                    leftMargin: units(14)
                    rightMargin: units(14)
                }
                color: "transparent"
                children: [content]
//                visible: content.visible
                clip: true
            }

            // footer
            Rectangle {
                id: footercontainer
                width: parent.width
                height: footerHeight
                anchors{
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    bottomMargin: units(10)
                    leftMargin: units(14)
                    rightMargin: units(14)
                }

                color: "transparent"
                children: [footer]
                clip: true
            }

        }

        DropShadow {
            id: _dialogDropShadow
            anchors.fill: _dialogContainer
            horizontalOffset: units(3)
            verticalOffset: units(3)
            radius: units(4)
            samples: units(9)
            color: Qt.darker(maskBackgroundColor)
            source: _dialogContainer
        }


        NumberAnimation{
            id: _dialogFadeInAnimation
            properties: "opacity"
            targets: [_dialogDropShadow, _backgroundContainer]
            from: 0.0
            to: 1.0
            duration: transitionDuration
            easing.type: Easing.InOutQuad
            onStarted: {
                visible = true
            }
            onStopped: {
                transitionInCompleted()
            }
        }


        NumberAnimation{
            id: _dialogFadeOutAnimation
            properties: "opacity"
            targets: [_dialogDropShadow, _backgroundContainer]
            from: 1.0
            to: 0.0
            duration: transitionDuration
            easing.type: Easing.InOutQuad
            onStopped: {
                visible = false
                transitionOutCompleted()
            }
        }


//        Component.onCompleted: _dialogFadeInAnimation.start()
    }


}
