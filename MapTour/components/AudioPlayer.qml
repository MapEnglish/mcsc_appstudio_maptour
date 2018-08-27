import QtQuick 2.5
import QtMultimedia 5.8
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import ArcGIS.AppFramework 1.0

Item {
    id: root

    property color backgroundColor: "#4C4C4C"
    property color primaryColor: "steelBlue"
    property real buttonSize: units(48)
    property real defaultMargin: units(4)

    property string source: ""
    property string playBtnImg: "images/play.png"
    //property string pauseBtnImg: "images/pause.png"
    property string stopBtnImg: "images/stop.png"

    width: Math.min(units(296), parent.width)
    height: units(56)

    Rectangle {
        anchors.fill: parent
        radius: units(2)
        color: backgroundColor
    }

    RowLayout {
        anchors.fill: parent
        spacing: defaultMargin

        Image {
            id: controlButton

            Layout.preferredHeight: buttonSize
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignVCenter
            source: {
                switch (player.playbackState) {
                case Audio.PlayingState:
                    return stopBtnImg
                case Audio.PausedState:
                    return playBtnImg
                case Audio.StoppedState:
                    return playBtnImg
                }
            }

            mipmap: true

            Audio {
                id: player

                source: root.source

                onStatusChanged: {
                    if (status === Audio.EndOfMedia) {
                        player.stop()
                        progressIndicator.value = 0
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    switch (player.playbackState) {
                    case Audio.PlayingState:
                        player.stop()
                        break
                    case Audio.PausedState:
                        player.play()
                        break
                    case Audio.StoppedState:
                        player.play()
                    }
                }
            }
        }

        Slider {
            id: progressIndicator

            Layout.fillWidth: true
            Layout.rightMargin: defaultMargin

            value: player.position/player.duration

            onValueChanged: {
                if (value !== (player.position/player.duration)) {
                    player.seek(value * player.duration)
                }
            }

            style: SliderStyle {

                handle: Rectangle {
                    anchors.centerIn: parent
                    height: units(16)
                    width: units(4)
                }

                groove: Rectangle {
                    height: units(1)
                    width: parent.width

                    Rectangle {
                        color: primaryColor
                        height: parent.height
                        width: styleData.handlePosition
                    }
                }
            }
        }
    }

    function units(num) {
        return num? num*AppFramework.displayScaleFactor : num
    }
}
