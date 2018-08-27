/* Copyright 2017 Esri
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
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtGraphicalEffects 1.0

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "components" as Components

Item {
    id: itemView

    signal clicked()
    signal doubleClicked()
    signal searchCompleted()

    property real maxThumbnailWidth: app.units(140)
    property real maxThumbnailHeight: maxThumbnailWidth * 133 / 200
    property real defaultMargins: app.units(8)
    property real footerHeight: isCached ? app.units(20) : 0

    property bool isDebug: false
    property bool isCached: app.tourManager.toursInCache().indexOf(id) !== -1

    width: Math.min(parent.width, app.units(600))
    height: maxThumbnailHeight + footerHeight + 4*defaultMargins

    anchors.horizontalCenter: parent.horizontalCenter
    clip: true

    Rectangle{
        id: container
        color: "#FFFFFF"
        radius: app.units(2)
        anchors.fill: parent
        anchors.topMargin: app.units(5)

//        border.color: app.separatorColor
//        border.width: app.units(0.5)
    }
    Rectangle{
        id:topSpacing
        width: parent.width
        height: app.units(10)
        anchors.top: parent.top
        anchors.margins: 0
        color: app.pageBackgroundColor
    }

    Rectangle {
        id: bottomShadow

        width: parent.width
        height: app.units(1)
        color:  app.separatorColor
        //opacity: 0.2
        anchors.bottom: parent.bottom
        anchors.margins: 0
    }
//    Rectangle {
//        id: rightShadow

//        width: app.units(1)
//        height: parent.height
//        color:  app.separatorColor
//        //opacity: 0.2
//        anchors.right: parent.right
//        anchors.margins: 0
//    }

    ColumnLayout {
        anchors {
            margins: itemView.defaultMargins
            topMargin: app.units(16)
            fill: parent
        }
        spacing: itemView.defaultMargins


        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            spacing: app.units(4)
            //anchors.bottom: parent.bottom

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Layout.fillHeight: true

                spacing: isPortrait ? 0 : app.units(4)

                Text {
                    id: tourTitle
                    text: title
                    font {
                        pointSize: app.baseFontSize
                        family: app.customTitleFont.name
                    }

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    wrapMode: Text.Wrap
                    color: app.textColor
                    textFormat: Text.StyledText
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignTop

                    Rectangle {
                        visible: isDebug
                        anchors.fill: parent
                        color:  "transparent"
                        border.color: "red"
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: parent.height
                Image {
                    id: thumbnailImage

                    Layout.preferredWidth: maxThumbnailWidth
                    Layout.preferredHeight: maxThumbnailHeight
                    Layout.alignment: Qt.AlignTop

                    sourceSize.width: 200
                    sourceSize.height: 133

                    asynchronous: true

                    source : app.tourManager.networkCacheManager.cache(getThumbnail(thumbnailUrl, thumbnail), "", null)
                    fillMode: Image.PreserveAspectCrop

                    opacity: 0
                    onStatusChanged: if (thumbnailImage.status == Image.Ready) animateThumb.start()

                    NumberAnimation on opacity {
                        id: animateThumb
                        from: 0
                        to: 1
                        duration: 600
                    }
                }
            }
        }

        RowLayout {
                   Layout.preferredWidth: parent.width
                   Layout.preferredHeight: footerHeight
                   visible: isCached
                   spacing: app.units(4)

                   Components.Icon {
                       imageSource : "images/ic_offline_pin_white_24dp_2x.png"
                       imageSize: app.units(20)
                       isDebug: false
                       anchors.left: parent.left
                       maskColor: "green"
                       containerSize: app.units(24)
                       opacity: 0.5
                       Layout.preferredWidth:app.units(24)
                   }

                   Text {
                       text: qsTr("Offline")
                       textFormat: Text.StyledText
                       visible: isCached
                       color: app.textColor
                       elide: Text.ElideRight
                       opacity: 0.5
                       font {
                           pointSize: app.subscriptFontSize
                           family: app.customTitleFont.name
                       }
                   }

                   Rectangle {
                       Layout.preferredHeight: parent.height
                       Layout.fillWidth: true
                       color: "transparent"
                   }

                   Components.Icon {
                       imageSource : "images/ic_update_white_24dp_2x.png"
                       isDebug: false
                       imageSize: app.units(20)
                       containerSize: app.units(24)
                       Layout.alignment: Qt.AlignRight
                       opacity: 0.5
                       Layout.preferredWidth:app.units(24)
                   }
               }
    }



    MouseArea {
        id: mouseArea
        anchors.fill: parent

        hoverEnabled: true

        onEntered: {
            //container.opacity = 0.6
        }

        onExited: {
            //container.opacity = 1
        }

        onClicked: {
            itemView.ListView.view.currentIndex = index;
            itemView.clicked();
        }

        onDoubleClicked: {
            //itemView.ListView.view.currentIndex = index;
            //itemView.doubleClicked();
        }
    }

    //--------------------------------

    function getThumbnail(thumbUrl, thumb) {

        //console.log("get thumbnail: ", thumb, typeof thumb, Object.keys(thumb));


        if(thumb) {
            app.tourManager.networkCacheManager.cache(thumbUrl, "", null)
            return thumbUrl;
        } else {
            return "images/item_thumbnail.png";
        }
    }

    //---------------------------------
}
