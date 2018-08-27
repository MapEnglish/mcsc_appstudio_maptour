import QtQuick 2.5

Rectangle {

    id: root

    property string address : "..."
    property color textBackgroundColor: "#44000000"
    property color textColor: "black"
    property real fontPointSize: 16

    width: distanceLabel.contentWidth
    //width: 120*app.scaleFactor
    height: 20*app.scaleFactor
    clip: true
    color: textBackgroundColor

    anchors {
        right: parent.right
        //top: parent.top
        bottom: parent.bottom
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true

        onClicked: {
            if(app.enableDistance && app.showDistance && app.isOnline) {
                var link = "http://maps.google.com?daddr="+address+"&saddr="+app.locationManager.latitude+","+app.locationManager.longitude+"&zoom=14&views=traffic&&directionsmode=driving&x-success=sourceapp://?resume=true"

                if(Qt.platform.os == "ios") {
                    link = "http://maps.apple.com/?daddr=" + address + "&dirflg=d"
                }

                if(Qt.platform.os == "ios" || Qt.platform.os == "android") {
                    Qt.openUrlExternally(link)
                }
            }
        }
    }

    Text {
        id: distanceLabel
        
        clip: true
        text: address

        anchors.margins: 4 * app.scaleFactor

        width: parent.width
        height: parent.height
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        maximumLineCount: 1
        textFormat: Text.StyledText
        //fontSizeMode: Text.Fit
        color: textColor
        font {
            family: app.customTextFont.name
            pointSize: fontPointSize
        }
    }
}
