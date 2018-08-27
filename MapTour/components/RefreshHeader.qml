/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0

Item {
    id: refreshHeader

    property Flickable target: parent
    property string pullText: qsTr("Pull to refresh...")
    property string releaseText: qsTr("Release to refresh...")
    property string refreshingText: qsTr("Refreshing")
    property real releaseThreshold: refreshLayout.height * 2
    property color textColor: Qt.darker(internal.backgroundColor, 1.5)//"#999999"
    property bool refreshing: false
    property real fontSize: 14
    property string fontFamilyName: ""

    signal refresh();

    anchors {
        left: parent.left
        top: parent.top
        right: parent.right
    }

    height: visible ? -target.tempContentY : 0
    visible: target.tempContentY <= -refreshLayout.height
    Connections {
        target: refreshHeader.target

        onDragEnded: {
            if (refreshHeader.state == "pulled") {
                refresh();
            }

        }
    }

    RowLayout {
        id: refreshLayout
        height: 40 * AppFramework.displayScaleFactor
        width: Math.min(600 * AppFramework.displayScaleFactor, parent.width)
        spacing: 5 * AppFramework.displayScaleFactor
        anchors.centerIn: parent
        clip: true

        Rectangle{
            id: refreshRectangle
            Layout.preferredHeight: refreshLayout.height
            Layout.preferredWidth: refreshLayout.width*0.25-AppFramework.displayScaleFactor
            color: "transparent"
            clip: true


            Rectangle{
                id: refreshArrow
                color: "transparent"
                width: 30 * AppFramework.displayScaleFactor
                height: 30 * AppFramework.displayScaleFactor
                anchors.centerIn: parent
                clip: true

                transformOrigin: Item.Center

                Behavior on rotation {
                    NumberAnimation {
                        duration: 50
                        alwaysRunToEnd: true
                    }
                }

                Image {
                    id: arrow_img
                    anchors.fill: parent
                    source: "images/refresh-arrow.png"
                }

                ColorOverlay{
                    visible: arrow_img.visible
                    anchors.fill: arrow_img
                    source: arrow_img
                    color: textColor
                }
            }



        }

        Text {
            id: refreshText
            Layout.fillHeight: true
            Layout.fillWidth: true

            font {
                pointSize: refreshHeader.fontSize
                family: refreshHeader.fontFamilyName
            }
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: textColor
        }


        Rectangle{
            Layout.preferredHeight: refreshLayout.height
            Layout.preferredWidth: refreshLayout.width*0.25-AppFramework.displayScaleFactor
            color: "transparent"
        }
    }

    states: [


        State {
            name: "base"
            when: target.tempContentY >= -releaseThreshold

            PropertyChanges {
                target: refreshText
                text: pullText
            }

            PropertyChanges {
                target: refreshArrow
                rotation: 180
            }
        },

        State {
            name: "pulled"
            when: target.tempContentY < -releaseThreshold

            PropertyChanges {
                target: refreshText
                text: releaseText

            }

            PropertyChanges {
                target: refreshArrow
                rotation: 0

            }


        }


    ]
}
