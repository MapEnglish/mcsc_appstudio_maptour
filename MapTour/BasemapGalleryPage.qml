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

import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import Esri.ArcGISRuntime 100.2

import "components" as Components

Components.Page {
    id: basemapGalleryPage

    //property var pageData: {"description":"", "modified":""}

    isDebug: false
    visible: false
    headerHeight: 50 * app.scaleFactor

    header: Rectangle {
        anchors.fill: parent
        color: app.headerBackgroundColor

        Text {
            id: titleText

            text: app.kSelectBasemap
            textFormat: Text.StyledText
            width: 0.85 * parent.width
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.centerIn: parent
            color: app.titleColor
            maximumLineCount: 1
            elide: Text.ElideRight
            font {
                pointSize: app.titleFontSize
                family: app.customTitleFont.name
            }
        }

        MouseArea {
            anchors.fill: parent
            preventStealing: true
        }

        Components.Icon {
            id: closeBtn
            imageSource: "images/close.png"
            anchors {
                rightMargin: 10 * app.scaleFactor
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            MouseArea{
                anchors.fill: closeBtn
                onClicked: {
                    basemapGalleryPage.hide()
                }
            }
        }

    }

    content: Pane {
        anchors.fill: parent
        background: Rectangle {
        }
        topPadding: 0
        leftPadding: 0
        rightPadding: 0
        bottomPadding: app.heightOffset

        GridView {
            id: basemapsGrid
            width: app.isSmallScreen ?  parent.width : Math.min(units(600), parent.width)
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter

            signal basemapSelected (int index)

            property real columns: app.isSmallScreen ? 2 : 3

            property var listModel: app.portal.basemaps

            model: listModel

            cellWidth: width/columns
            cellHeight: cellWidth
            flow: GridView.FlowLeftToRight
            clip: true

            onBasemapSelected: {
                mapView.map.basemap = listModel.get(index)
                basemapGalleryPage.hide()
            }

            delegate: Pane {

                height: GridView.view.cellWidth
                width: GridView.view.cellHeight
                topPadding: app.defaultMargin
                bottomPadding: 0
                leftPadding: 0 //app.baseUnit
                rightPadding: 0 //app.baseUnit


                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Image {
                        id: thumbnailImg
                        source: thumbnailUrl
                        Layout.preferredHeight: 0.8 *parent.height
                        Layout.preferredWidth: 0.8 * parent.width
                        Layout.alignment: Qt.AlignCenter
                        fillMode: Image.PreserveAspectFit
                        BusyIndicator {
                            anchors.centerIn: parent
                            running: thumbnailImg.status === Image.Loading
                        }
                    }

                    Components.BaseText {
                        text: title
                        maximumLineCount: 2
                        //font.pointSize: app.contentsSize
                        color: app.textColor
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredHeight: contentHeight
                        Layout.preferredWidth: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            mapView.map.basemap = basemapsGrid.listModel.get(index)
                            basemapGalleryPage.hide()
                        }
                    }
                }
            }
        }

    }

    onVisibleChanged: {
        if (visible && app.portal.loadStatus !== Enums.LoadStatusLoaded) {
            app.portal.load()
        }
    }

    onTransitionOutCompleted: {
        visible = false
    }

    Component.onDestruction: {
        //console.log("Page destroyed!")
    }

    function show () {
        visible = true
        transitionIn(transition.bottomUp)
    }

    function hide () {
        transitionOut(transition.topDown)
    }

}
