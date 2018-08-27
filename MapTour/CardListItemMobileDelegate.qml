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
    id: cardListItemMobileDelegate

    signal clicked()

    property bool hasAudio: description.indexOf("<audio") > 0

    //width: Math.min(parent.width,400)
    width: Math.min(app.width, 1024*app.scaleFactor)
    height: app.width * 9/16

    anchors {
        topMargin: 5*app.scaleFactor
        bottomMargin: 5*app.scaleFactor
        horizontalCenter: parent ? parent.horizontalCenter : undefined
    }

    Image {
        id: placeholderImage
        source: "images/placeholder.jpg"
        anchors.fill: cardThumbnailImage2

    }

    //------------ highlight -----------------
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: app.units(2)
        color: app.selectColor
        visible: currentPhotoIndex === index
    }

    //-----------------------
    Rectangle {
        anchors {
            left: cardThumbnailImage2.left
            top: cardThumbnailImage2.top
            topMargin: 3*app.scaleFactor
            leftMargin: 3*app.scaleFactor
        }
        radius: 3
        height: cardItemNumber2.contentHeight + 2*app.scaleFactor
        width: cardItemNumber2.contentWidth + 8*app.scaleFactor

        //color: "#80000000"
        color: app.customRenderer?pageHelper.getColorName(icon_color): "#000000"
        opacity: 0.9;
        z:1

        Text {
            id: cardItemNumber2
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


    Image {
        id: cardThumbnailImage2

        opacity: 0

        anchors {
            bottomMargin: 3*app.scaleFactor
        }
        anchors.fill: parent

        NumberAnimation on opacity {
            id: animateImage2
            from: 0
            to: 1
            duration: 1000
            easing.type: Easing.InSine
        }

        onStatusChanged: if (cardThumbnailImage2.status == Image.Ready) animateImage2.start()

        asynchronous: true

        source : app.tourManager.networkCacheManager.cache(thumb_url, "", null)
        //source: "images/item_thumbnail.png"
        fillMode: Image.PreserveAspectCrop

        DistanceLabel {
            visible: app.showDistance && app.canUseDistance
            //width: 80 * app.scaleFactor
            anchors.margins: 4 * app.scaleFactor
            radius: 2 * app.scaleFactor
            distanceComputed: distance
        }
    }


    Rectangle {
        anchors.fill: cardTitleText2
        anchors.margins: -8*app.scaleFactor;

        gradient: Gradient {
            GradientStop { position: 1.0; color: "#55000000";}
            GradientStop { position: 0.0; color: "#22000000";}
        }
    }

    Text {
        id: cardTitleText2

        font.family: app.customTitleFont.name

        property bool isLink: name.indexOf("//:") > -1

        anchors {
            left: cardThumbnailImage2.left
            right: cardThumbnailImage2.right
            bottom: cardThumbnailImage2.bottom
            margins: 8*app.scaleFactor

            //verticalCenter: parent.verticalCenter
        }

        text: name

        textFormat: Text.StyledText

        maximumLineCount: 3
        elide: Text.ElideRight

        font {
            pointSize: app.baseFontSize
        }
        wrapMode: Text.Wrap
        color: app.subtitleColor
        linkColor: app.linkColor

        onLinkActivated: {
            app.openUrlInternally(link);
        }
    }

    MouseArea {
        id: cardMouseArea2
        anchors.fill: parent

        hoverEnabled: true

        onClicked: {
            console.log("card clicked: " + index);
            currentPhotoIndex = index
            mapListView.currentIndex = index
            mapListView.positionViewAtIndex(index,ListView.Center);
            //onGraphicClickHandler(index);
            onPhotoClickHandler(index)
            mapMode = false
            photoMode = true
        }
    }

}

//--------------------------------
