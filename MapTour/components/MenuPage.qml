import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import QtGraphicalEffects 1.0

Item {
    id: menuPage
    property alias isDebug: _root.isDebug

    signal header_leftIcon_Clicked()
    signal header_rightIcon_Clicked()
    signal backButtonClicked()
    signal transitionInCompleted()
    signal transitionOutCompleted()

    property color headerBackgroundColor: "#3c8b09"
    property real headerHeight: units(56)
    property string header_titleText: "Title"
    property color header_titleTextColor: "#ffffff"
    property url header_rightIconUrl: "./images/web_close.png"
    property url content_loaderUrl: ""

    property alias header: _root.header
    property alias content: _root.content
    property alias footer: _root.footer

    property alias transitionType: _root.transitionType
    property alias transitionDuration: _root.transitionDuration
    property alias transition: _root.transition
    property alias initX: _root.x
    property alias initY: _root.y
    property alias transitionXOffset:_root.transitionXOffset

    property int menuWidth: Math.min(parent.width*4/5, units(300))
    property int menuHeight: parent.height

    anchors.fill: parent

    function units(num) {
        return num ? num*AppFramework.displayScaleFactor : 0
    }

    function transitionIn(type_in){
        _root.transitionIn(type_in)
    }

    function transitionOut(type_out){
        _root.transitionOut(type_out)
    }

    Page{
        id: _root
        width: menuWidth
        height: menuHeight
        transitionType: type.none
        headerHeight: menuPage.headerHeight
        header: Rectangle{
            anchors.fill: parent
            MouseArea {
                anchors.fill: parent
                preventStealing: true
            }
            Rectangle{
                id: headerContainer
                anchors.fill: parent
                color: headerBackgroundColor

                Text{
                    id: midTitleText
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    text: header_titleText
                    anchors{
                        left: parent.left
                        right: rightButton.left
                        top: parent.top
                        bottom: parent.bottom
                        margins: units(16)
                    }
                    elide: Text.ElideMiddle
                    font.pointSize: 20
                    color: header_titleTextColor
                    clip: true
                }

                ImageButton{
                    id: rightButton
                    visible: header_rightIconUrl!=""
                    anchors{
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: units(7)
                    }
                    source: header_rightIconUrl
                    smooth: true
                    height: units(30)
                    width: units(30)
                    checkedColor : "transparent"
                    pressedColor : "transparent"
                    hoverColor : "transparent"
                    glowColor : "transparent"
                    onClicked: {
                        header_rightIcon_Clicked()
                    }
                }
            }
        }

        content: Rectangle{
            anchors.fill: parent
            Loader{
                focus: true
                source: content_loaderUrl
                anchors.fill: parent
            }
            color: "transparent"
        }

        footer: Rectangle{
            visible: false
        }

        onBack: {
            backButtonClicked()
        }

        onTransitionInCompleted: {
            menuPage.transitionInCompleted()
        }

        onTransitionOutCompleted: {
            menuPage.transitionOutCompleted()
        }
    }    

}
