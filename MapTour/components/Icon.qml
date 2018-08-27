import QtQuick 2.3
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0
import QtGraphicalEffects 1.0

Rectangle {

    id: root

    function units(num) {
        return num? num*AppFramework.displayScaleFactor : 0
    }

    property bool isDebug: false
    property int imageSize: units(24)
    property int containerSize: units(48)
    property int sidePadding: 0
    property url imageSource: ""
    property color maskColor: "transparent"

    signal iconClicked()

    width: containerSize + sidePadding
    height: containerSize
    Layout.preferredWidth: containerSize
    Layout.preferredHeight: containerSize

    color: isDebug? "#66880000": "transparent"

    Image {
        id: image
        width: imageSize
        height: imageSize
        anchors.centerIn: parent
        source: imageSource
        asynchronous: true
        smooth: true
        fillMode: Image.PreserveAspectCrop

        Rectangle {
            anchors.fill: parent
            visible: isDebug
            color: "transparent"
            opacity: 0.5
            border.width: isDebug
        }
    }

    ColorOverlay{
        anchors.fill: image
        source: image
        color: maskColor
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            iconClicked();
        }
    }

}
