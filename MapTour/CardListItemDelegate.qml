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

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtGraphicalEffects 1.0

Item {
    id: cardListItemDelegate

    signal clicked()
    signal doubleClicked()

    property real maxThumbnailWidth: parent ? Math.min(parent.width, 800*app.scaleFactor) * 0.4 : 0
    property real maxThumbnailHeight: maxThumbnailWidth * 9/16

    width: parent ? Math.min(parent.width, 800*app.scaleFactor) : 0
    height: maxThumbnailHeight

    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    anchors.margins: 4*app.scaleFactor

    clip: true

    Rectangle {
        height: 2*app.scaleFactor
        color: currentPhotoIndex === index ? app.selectColor : "transparent"
        width: parent.width
        anchors.bottom: parent.bottom
    }

    Item {
        anchors {
            fill: parent
            bottomMargin: 3*app.scaleFactor
        }


        Rectangle {
            anchors.fill: parent
            color: "#FFFFFF"
//            border.color: app.separatorColor
//            border.width: app.units(0.5)
        }
        Rectangle {
            id: bottomShadow

            width: parent.width
            height: app.units(1)
            color:  app.separatorColor
            //opacity: 0.2
            anchors.top: parent.bottom
            anchors.margins: 0
        }

        Image {
            id: cardThumbnailImage

            height: Math.min(parent.height, maxThumbnailHeight)
            width: height * 200 / 133
            anchors {
                left: parent.left
                top: parent.top
            }

            onStatusChanged: if (cardThumbnailImage.status == Image.Error) cardThumbnailImage.source = "images/item_thumbnail.jpeg"

            asynchronous: true

            source : app.tourManager.networkCacheManager.cache(thumb_url, "", null)
            //source: "images/item_thumbnail.png"
            fillMode: Image.PreserveAspectCrop

            //-------
            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    topMargin: 3*app.scaleFactor
                    leftMargin: 3*app.scaleFactor
                }
                radius: 3
                height: cardItemNumber.contentHeight + 2*app.scaleFactor
                width: cardItemNumber.contentWidth + 8*app.scaleFactor

                //color: "#80000000"
                color: app.customRenderer?pageHelper.getColorName(icon_color): "#000000"
                opacity: 0.9;

                Text {
                    id: cardItemNumber
                    text: index + 1
                    color: "white"
                    anchors {
                        centerIn: parent
                    }
                    font {
                        pointSize: app.baseFontSize
                    }

                    font.family: app.customTextFont.name
                }
            }

            BusyIndicator {
                visible: cardThumbnailImage.status !== (Image.Ready || Image.Error)
                anchors.centerIn: parent
            }

            DistanceLabel {
                visible: app.showDistance && app.canUseDistance
                distanceComputed: distance
                anchors.margins: 4 * app.scaleFactor
                radius: 2 * app.scaleFactor
            }

            //---------------


        }

        Text {
            id: cardTitleText

            anchors {
                left: cardThumbnailImage.right
                leftMargin: 10 * app.scaleFactor
                right: parent.right
                //topMargin: 5*app.scaleFactor
            }

            font.family: app.customTitleFont.name

            text: name

            textFormat: Text.StyledText

            maximumLineCount: 3
            elide: Text.ElideNone

            font {
                pointSize: app.baseFontSize
            }
            wrapMode: Text.Wrap
            color: app.textColor
            linkColor: app.linkColor

            onLinkActivated: {
                app.openUrlInternally(link);
            }
        }

        Text {
            id: cardDescriptionText

            font.family: app.customTextFont.name

            anchors {
                left: cardThumbnailImage.right
                leftMargin: 10 * app.scaleFactor
                right: parent.right
                top: cardTitleText.bottom
                topMargin: 10 * app.scaleFactor
                bottom: parent.bottom
            }

            visible: !isSmallScreen

            linkColor: app.linkColor

            onLinkActivated: {
                app.openUrlInternally(link);
            }

            //maximumLineCount: 2

            elide: Text.ElideRight

            text: {
                if (description.indexOf("<audio") > -1) {
                    return description.replace(/(<audio\b[^>][\s\S]+<\/audio>)/gi, "")
                } else {
                    return description
                }
            }

            textFormat: Text.StyledText

            font {
                pointSize: app.baseFontSize
            }

            wrapMode: Text.Wrap
            color: app.textColor

            opacity: 0.9
        }

        MouseArea {
            id: cardMouseArea
            anchors.fill: parent

            hoverEnabled: true

            onClicked: {
                console.log("card clicked: " + index);
                //cardList.ListView.view.currentIndex = index;
                //cardList.currentIndex = index;
                currentPhotoIndex = index
                mapListView.currentIndex = index
                mapListView.positionViewAtIndex(index,ListView.Center);
                onPhotoClickHandler(index)
                //onGraphicClickHandler(index);
                if (panelMode) {
                    mapViewPanel.screenSize.state = ""
                }
                mapMode = false
                photoMode = true
            }
        }

    }
}
