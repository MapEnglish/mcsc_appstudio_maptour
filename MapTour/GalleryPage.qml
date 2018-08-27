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

import QtQuick 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.1

import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2

import "components" as Components

Rectangle {
    id: gallery

    property Portal portal
    property bool refreshButtonVisible: true
    property bool pageReady: toursListView.tourListReady && pageInStack
    property bool pageInStack: false
    property alias toursListView: toursListView
    property string initialTour: ""

    signal tourSelected(QtObject tourInfo);

    Component.onCompleted: {
        tourManager.tours.onToursUpdated.connect(loadInitialTour)
        toursListView.refresh()
    }

    function loadInitialTour () {
        if (tourManager.tours.errorCode === 0 && tourManager.tours.count && initialTour) {
            tourSelected(tourManager.tours.getItemById(initialTour))
            tourManager.tours.onToursUpdated.disconnect(loadInitialTour)
        }
    }

    focus: true

    //-------------------------------------------------------------------------
    //android back button
    Connections {
        target: app
        onBackButtonPressed: {
            if (stackView.currentItem.objectName === "galleryPage") {
                if (app.tourManager.progressDialog.visible) {
                    app.tourManager.progressDialog.close()
                } else if (aboutPage.visible) {
                    aboutPage.hide()
                } else if (menuPage.visible) {
                    menuPage.hideMenu()
                } else {
                    //stackView.pop()
                }
            }
        }
    }
    //-------------------------------------------------------------------------

    color: app.pageBackgroundColor

    Rectangle {
        id: header

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: app.headerHeight
        color: app.headerBackgroundColor

        RowLayout {

            anchors.fill: parent

            ImageButton {
                id: menuButton

                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: app.isIphoneX && !app.isPortrait ? app.widthOffset : app.units(8)
                Layout.preferredWidth: app.units(30)
                Layout.preferredHeight: app.units(30)

                source: "images/menu.png"

                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"

                onClicked: {
                    mask.visible = true;
                    menuPage.showMenu();
                }
            }

            Text {
                id: titleText

                Layout.fillWidth: true
                Layout.leftMargin: app.units(8)
                Layout.rightMargin: app.units(8)
                Layout.alignment: Qt.AlignCenter
                font.family: app.customTitleFont.name
                fontSizeMode: Text.Fit

                text: qsTr("Map Tours")

                font {
                    pointSize: app.titleFontSize
                }
                color: app.titleColor
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        toursListView.positionViewAtBeginning()
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: menuButton.width
                Layout.fillHeight: true
                Layout.margins: app.units(8)
                color: "transparent"
            }

        }
    }

    Components.HeaderShadow {
        anchors.fill: header
        source: header
    }


    Item {
        anchors {
            left: parent.left
            right: parent.right
            top: header.bottom
            bottom: parent.bottom
            topMargin: app.units(4)
            leftMargin: app.units(10)
            rightMargin: app.units(10)
            bottomMargin: app.heightOffset
        }

        clip: true

        //------------------------

        Text {
            id: galleryMessageBox
            color: app.textColor
            font {
                pointSize: app.baseFontSize
            }
            font.family: app.customTextFont.name
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            visible: false
        }

        //---------------------------------------------

        ToursListView {
            id: toursListView

            anchors.fill: parent
            spacing: 0
            portal: gallery.portal

            delegate: TourItemView{

                onClicked: {
                    toursListView.currentIndex = index
                    toursListView.currentTour = toursListView.model.get(index)
                    gallery.tourSelected(toursListView.currentTour);
                }

                onDoubleClicked: {
                    //gallery.tourSelected(toursListView.currentTour);
                }
            }
        }
    }

    onPageReadyChanged: {
        if (pageReady && app.tourManager.tours.count === 1) {
            toursListView.currentIndex = 0;
            toursListView.currentTour = toursListView.model.get(0)

            gallery.tourSelected(toursListView.currentTour);
        }
    }

    //---------------------------------------------

    Rectangle{
        id: mask
        visible: false
        anchors.fill: parent
        color: "#80000000"
        MouseArea{
            anchors.fill: parent
            onClicked: {
                mask.visible = false;
                menuPage.hideMenu();
            }
        }
    }

    MenuPage {
        id: menuPage

        anchors.top: header.bottom
        refreshButtonVisible: gallery.refreshButtonVisible
        galleryButtonVisible: false
        hideMask: function(){mask.visible = false}
        headerHeight: app.headerHeight
    }

    AboutPage {
        id: aboutPage
    }

}

