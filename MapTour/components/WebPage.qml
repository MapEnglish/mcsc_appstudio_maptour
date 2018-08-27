import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework.WebView 1.0

Page {

    transitionDuration: 200

    property url link: ""

    visible: showOnStart

    property bool showOnStart: false
    property bool showHistory: true

    onTransitionOutCompleted: {
        visible = false
    }

    function loadPage(url){
        console.debug("Got: ", url);
        if(url) {
            link = url
        }
    }

    property color headerColor: "#444"

    footerHeight: 0

    header:  Rectangle {
        anchors.fill: parent
        color: headerColor

        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            height: units(2)
            color: Qt.darker(headerColor)
            z:111
            visible: webItem.loading
            width: parent.width * webItem.loadProgress/100
        }

        RowLayout {
            anchors.fill: parent
            //anchors.margins: units(8)
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: units(8)

            Icon {
                isDebug: false
                imageSource: "images/web_close.png"
                containerSize: units(36)
                anchors.verticalCenter: parent.verticalCenter
                onIconClicked: {
                    //close the page
                    transitionOut(transition.topDown)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.width: 0
                color: "transparent"
            }

            Icon {
                visible: showHistory
                imageSource: "images/web_back.png"
                anchors.verticalCenter: parent.verticalCenter
                opacity: webItem.canGoBack ? 1 : 0.3
                onIconClicked: {
                    console.debug("Webpage history back clicked");
                    webItem.goBack()
                }
            }

            Icon {
                visible: showHistory
                imageSource: "images/web_back.png"
                containerSize: units(36)
                rotation: 180
                anchors.verticalCenter: parent.verticalCenter
                opacity: webItem.canGoForward ? 1 : 0.3
                onIconClicked: {
                    console.debug("Webpage history forward clicked");
                    webItem.goForward()
                }
            }

            Icon {
                imageSource: "images/web_refresh.png"
                containerSize: units(36)
                sidePadding: units(4)
                anchors.verticalCenter: parent.verticalCenter
                onIconClicked: {
                    webItem.reload()
                }
            }

            Icon {
                imageSource: "images/web_share.png"
                containerSize: units(36)
                sidePadding: units(4)
                anchors.verticalCenter: parent.verticalCenter
                onIconClicked: {
                    Qt.openUrlExternally(link)
                }
            }
        }

    }

    content:  WebView {
        width: parent.width
        height: parent.height
        id: webItem
        url: link
        clip: true

//        BusyIndicator {
//            visible: running
//            running: webItem.loading
//            z:webItem.z + 1
//            anchors.centerIn: webItem
//        }

        Text {
            color: headerColor
            text: webItem.url
            visible: webItem.loading
            width: parent.width * 0.8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20*scaleFactor
            anchors.horizontalCenter: parent.horizontalCenter
            wrapMode: Text.WrapAnywhere
            z:webItem.z + 1
            textFormat: Text.StyledText
            maximumLineCount: 2
            font.family: app.customTextFont.name
            font.pointSize: app.baseFontSize

            onLinkActivated: {
                Qt.openUrlExternally(link);
            }
        }
    }

    Component.onCompleted:  {
        console.debug("Web page on-complete !!")
    }

    Component.onDestruction: {
        console.debug("Web page on-destruction :(")
    }

}
