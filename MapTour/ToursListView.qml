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

import Esri.ArcGISRuntime 100.2

import "components" as Components

ListView {
    id: listView

    property int searchPageSize: 25
    property string orderBy: app.sortField || "created"
    property string sortOrder: app.sortOrder ||  "desc"
    property Portal portal
    property QtObject currentTour: currentIndex >= 0 ? model.get(currentIndex) : null
    property bool tourListReady: false
    property real tempContentY: 0
    property real diffContentY: 0

    signal clicked(PortalItem itemInfo)
    signal doubleClicked(PortalItem itemInfo)
    signal tourListUpdated()

    model: app.tourManager.tours
    highlightFollowsCurrentItem: true
    focus: true
    spacing: app.units(8)

    footer: Rectangle {
        height:60*app.scaleFactor
        color: "transparent"
        width: parent.width
        visible: app.tourManager.tours.count > 0
        Text {
            anchors.centerIn: parent
            font.family: app.customTextFont.name
            text: qsTr("Click on a Tour to get started")
            font {
                pointSize: app.subscriptFontSize
            }
            color: app.textColor
            wrapMode: Text.Wrap
        }
    }

    Connections {
        target: app
        onIsOnlineChanged: {
            //console.log("IS ONLINE #################", app.isOnline)
            refresh()
        }
    }

    onCountChanged: {
        if (count === 0) tourListReady = false
    }

    onAtYBeginningChanged: {
        tempContentY = 0
        if(atYBeginning && contentY != 0 ){

                        diffContentY = contentY - tempContentY
                    }

    }

    onContentYChanged: {
        if(atYBeginning){
            tempContentY =0
        }

            tempContentY = contentY - diffContentY

    }

    Connections {
        target: app.tourManager.tours
        onToursUpdated: {
            //console.log("###################### RESULTS ",JSON.stringify(app.tourManager.tours.get(0)))
            if (app.tourManager.tours.count === 0 && app.tourManager.tours.errorCode === 0) {
                galleryMessageBox.visible = true
                galleryMessageBox.text = qsTr("No map tours to display.")
            } else if (app.tourManager.tours.errorCode !== 0) {
                galleryMessageBox.visible = true
                galleryMessageBox.text = app.tourManager.tours.errorMsg
            } else {
                galleryMessageBox.visible = false
            }

            app.busyIndicator.visible = false
            listView.tourListUpdated()
            listView.tourListReady = true
        }
    }

    function refresh () {
        app.tourManager.tours.refresh()
        app.busyIndicatorTimer.start()
    }

    function reset () {
        app.tourManager.tours.reset()
        app.busyIndicatorTimer.start()
    }


    Components.RefreshHeader {
        id: refreshHeader
        y: -parent.contentY - height
        z: parent.z - 1
        textColor: app.textColor
        fontFamilyName: app.customTextFont.name
        fontSize: 0.7*app.baseFontSize
        onRefresh: {
            if (!app.tourManager.tours.isRefreshing) {
                if (app.isOnline) {
                    listView.reset()
                } else {
                    listView.refresh()
                }
            }
        }
    }
}
