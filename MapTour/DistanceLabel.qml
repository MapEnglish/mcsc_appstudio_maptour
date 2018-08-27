import QtQuick 2.5

import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

Rectangle {

    id: root

    property real threshold: 100
    property real distanceComputed: 0
    property real fontPointSize: 16
    property real defaultMargin: 4 * app.scaleFactor
    property real defaultHeight: 25 * app.scaleFactor
    property bool useThreshold: true
    property bool isGreaterThanThreshold: distanceComputed > threshold
    property bool showDistanceIcon: false
    property color textBackgroundColor: "#44000000"
    property color textColor: "#FFFFFF"

    width: distanceLabelContent.width + defaultMargin
    height: defaultHeight
    color: textBackgroundColor
    clip: true

    anchors {
        right: parent.right
        top: parent.top
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
    }

    RowLayout {
        id: distanceLabelContent

        spacing: 0
        anchors.verticalCenter: parent.verticalCenter
        Layout.preferredHeight: root.height
        Layout.preferredWidth: distanceIconContainer.width + distanceLabel.width

        Item {
            id: distanceIconContainer

            Layout.preferredHeight: root.height
            Layout.preferredWidth: root.height
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showDistanceIcon

            Image {
                id: distanceIcon

                anchors.fill: parent
                source: "images/distance.png"
                mipmap: true
            }

            ColorOverlay {
                source: distanceIcon
                anchors.fill: source
                color: textColor
            }
        }

        Text {
            id: distanceLabel

            clip: true
            text: {
                if (root.useThreshold) {
                    return root.isGreaterThanThreshold ? "%1+ %2".arg(threshold).arg(app.distanceUnit) : "%1 %2".arg(root.distanceComputed).arg(app.distanceUnit)
                } else {
                    return "%1 %2".arg(root.distanceComputed).arg(app.distanceUnit)
                }
            }
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: root.showDistanceIcon ? 0 : root.defaultMargin
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignJustify
            verticalAlignment: Text.AlignVCenter
            maximumLineCount: 1
            textFormat: Text.StyledText
            //fontSizeMode: Text.Fit
            color: textColor
            font {
                family: app.customTitleFont.name
                pointSize: fontPointSize
            }
        }
    }
}
