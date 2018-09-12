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
import QtSensors 5.3
import QtPositioning 5.3
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
//import QtQuick.Window 2.0
import QtQuick.Controls 2.2 as NewControls
import QtQuick.Controls.Styles 1.4

import Esri.ArcGISRuntime 100.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "components" as Components
import "../MCSC" as MCSC

NewControls.Pane {
    id: tourPage

    property Portal portal
    //property PortalItem tourItemInfo

    property var tourInfo
    property string tourLayerId: ""
    property bool pageInStack: false
    property bool photoMode: false
    property bool panelMode: false
    property bool showGraphics: true
    property bool isPhotoFullScreen: photoMode && mapViewPanel.panelThreshold
    property bool isSmallScreen: app.isSmallScreen
    property bool mapMode: false
    property bool descriptionReadMode: false
    property real screenHeight : parent ? parent.height : 0
    property real screenWidth : parent ? parent.width : 0
    property int bannerHeight: app.headerHeight
    property int currentPhotoIndex: -1

    property alias sortButton: sortButton
    property alias mapListView: mapViewPanel.featuresList
    property alias tourItemsListModel: tourItemsListModel

    property var learn
    property var basemapGallery

    signal exit()
    signal tourError(string message)

    //--------------------------------------------------------------------------

    Component.onCompleted: {
        mapMode = !isSmallScreen;
    }

    background: Rectangle {
        color: app.pageBackgroundColor
    }

    padding: 0

    function loadTour(itemInfo) {

        if(itemInfo && itemInfo.values) {
            tourInfo = itemInfo

            //console.log(JSON.stringify(tourInfo));
            console.log("------ Load Tour -------");
            //console.log("Tour ID: ", tourItemInfo.itemId);
            //console.log(JSON.stringify(tourInfo))

            if(tourInfo.values) {
                console.log("Webmap found: ", tourInfo.values.webmap);
                console.log("title found: ", tourInfo.values.title);
                console.log("subtitle found: ", tourInfo.values.subtitle);
                console.log("source layer: ", tourInfo.values.sourceLayer);

                if(tourInfo.values.sourceLayer) {
                    tourLayerId = tourInfo.values.sourceLayer;
                }

                app.tourOrderArray = [];
                if(tourInfo.values.order) {
                    tourInfo.values.order.forEach(function(value){
                        if(value.visible) {
                            app.tourOrderArray.push(value.id);
                        }
                    });
                }

                if(tourInfo.values.title) {
                    app.tourTitle = tourInfo.values.title;
                }

                if(tourInfo.values.subtitle) {
                    app.tourSubtitle = tourInfo.values.subtitle;
                }

                //reset any previous over-rides

                app.titleField = app.info.propertyValue("maptour_titleField","Name");
                app.descField = app.info.propertyValue("maptour_descriptionField","CAPTION");
                app.thumbnailField = app.info.propertyValue("maptour_thumbnailField", "PIC_URL");
                app.imageField = app.info.propertyValue("maptour_imageField","THUMB_URL");
                app.iconColorField = app.info.propertyValue("maptour_iconColorField", "icon_color") || "icon_color";


                if(tourInfo.values.fieldsOverride) {
                    console.log("##### OVERRIDES ######")
                    var overrideObj = tourInfo.values.fieldsOverride;
                    if(overrideObj.fieldName && overrideObj.fieldName.length > 1) {
                        app.titleField = overrideObj.fieldName;
                    }

                    if(overrideObj.fieldDescription && overrideObj.fieldDescription.length > 1) {
                        app.descField = overrideObj.fieldDescription;
                    }

                    if(overrideObj.fieldURL && overrideObj.fieldURL.length > 0) {
                        app.imageField = overrideObj.fieldURL;
                    }

                    if(overrideObj.fieldThumb && overrideObj.fieldThumb.length > 0) {
                        app.thumbnailField = overrideObj.fieldThumb;
                    }

                    if(overrideObj.fieldIconColor && overrideObj.fieldIconColor.length > 0) {
                        app.iconColorField = overrideObj.fieldIconColor;
                    }

                    console.log("Overrides for fields: ", app.titleField, app.descField, app.imageField, app.thumbnailField, app.iconColorField);
                }

                console.log("### After overrides: ", app.titleField, app.thumbnailField, app.imageField, app.iconColorField)

            }

            if(!tourLayerId && !app.tourLayerId) {
                tourError(qsTr("Sorry! Unable to find Map Tour Layer"));
            }

            if(!tourInfo.values || !tourInfo.values.webmap) {
                tourError(qsTr("Sorry! Unable to load this Map Tour"));
                busyIndicator.visible = false;
                return;
            }

            app.tourManager.webMapData.load(tourInfo.values.webmap)
        } else if(itemInfo && itemInfo.type === "Web Map"){
            console.log("##TourPageHelper:: item is of type webmap !!!");
            tourLayerId = app.tourLayerId;
            app.tourManager.webMapData.load(itemInfo.id)
        } else if(!app.showGallery && app.tourLayerId && app.webmapid) {
            //webmap provided by user
            console.log("#TourPageHelper:: webmap provided by user");
            //tourMap.loadLayers(app.featureServiceLayer, app.basemapLayer);
            tourLayerId = app.tourLayerId;
            app.tourManager.webMapData.load(app.webmapid);
        } else {
            tourError(qsTr("Unable to get webmap and tour layer to show!"));
        }
    }

    //--------------------------------------------------------------------------

    Components.CustomListModel {
        id: tourItemsListModel

        property int sortCount: 0
        property FileFolder fileFolder: app.tourManager.networkCacheManager.fileFolder
        readonly property string fileName: "%1.json".arg(app.tourManager.tourItems.tourId)

        function cacheMetaData () {
            var content = {}
            if (!fileFolder.fileExists(fileName)) {
                content["dateCached"] = new Date()
                fileFolder.writeJsonFile(fileName, content)
            }
        }

        onSortingCompleted: {
            sortCount += 1
            tourGraphics.updateLabels()
            if (app.urlParameters && sortCount === 1) {
                if (app.urlParameters.hasOwnProperty("appid") &&
                    app.urlParameters.hasOwnProperty("index")) {




                    var idx = parseInt(app.urlParameters.index)
                    // MATT - force tour to open at newest tour point
                    if (idx === 9999)
                    {
                        photoMode = true
                        mapMode = true
                        onPhotoClickHandler(tourItemsListModel.count - 1)
                    }
                    else
                    {
                        if (app.urlParameters.appid === tourInfo.tourId &&
                            idx - 1 <= tourItemsListModel.count &&
                            idx > 0) {
                            mapMode = true
                            onPhotoClickHandler(idx - 1)
                        }
                    }
                }
            } else {
                onPhotoClickHandler(0)
            }
        }
    }

    //--------------------------------------------------------------------------

    TourPageHelper {
        id: pageHelper

        mapView: mapView
        strings: strings
        webMapInfo: app.tourManager.webMapData.webMapDataQueryResults

        onGraphicsCreationCompleted: {
            var sortOrder = app.customSort ? (app.customSortOrder || "desc") : "desc"
            switch (app.sortType.toLowerCase()) {
            case "title":
                sortButton.activated(1)
                break
            case "distance":
                if (app.showDistance) {
                    sortButton.activated(2)
                } else if (app.canUseDistance) {
                    tourItemsListModel.sortByNumberAttribute("distance", "desc")
                } else {
                    sortButton.activated(0)
                }
                break
            default:
                sortButton.activated(0)
            }
        }
    }

    //--------------------------------------------------------------------------
    //android back button
    Connections {
        target: app
        onBackButtonPressed: {
            if (stackView.currentItem.objectName === "tourPage") {
                if (photoMode) {
                    mapViewPanel.closePhoto()
                } else if (messageBox.visible) {
                    messageBox.close()
                } else if (mmpkDialog.visible) {
                    mmpkDialog.close()
                } else if (aboutPage.visible) {
                    aboutPage.hide()
                } else if (learn) {
                    learn.hide()
                } else if (menuPage.visible) {
                    menuPage.hideMenu()
                } else {
                    stackView.pop()
                }
            }
        }
    }
    //--------------------------------------------------------------------------

    QtObject {
        id: strings

        readonly property string kOf: qsTr(" of ")
        readonly property string kNoMapInOfflineMode: qsTr("Map not available in offline mode. Click to refresh.")
        readonly property string kMapCredits: qsTr("Map Credits")
        readonly property string kDefault: qsTr("Default")
        readonly property string kSortByDistance: qsTr("Sort by Distance")
        readonly property string kSortByTitle: qsTr("Sort by Title")
        readonly property string kSomethingWentWrong: qsTr("Something went wrong. Sorry!")
        readonly property string kList: qsTr("List")
        readonly property string kMap: qsTr("Map")
        readonly property string kOpenVideo: qsTr("Click to Open Video")
        readonly property string kNoMapTourLayer: qsTr("Sorry, No Map Tour Layer found!")

        readonly property string kMapDownloadSize: qsTr("Map download size")
        readonly property string kLastUpdated: qsTr("Last updated")
        readonly property string kDoYouWantToUpdateMap: qsTr("Do you want to update offline map?")
        readonly property string kSwitchingOffline: qsTr("Switching to offline map.")
        readonly property string kSwitchingOnline: qsTr("Switching to online map.")
    }

    //--------------------------------------------------------------------------

    Connections {
        target: app.tourManager.webMapData

        onWebMapDataUpdated: {
            pageHelper.webMapInfo = app.tourManager.webMapData.webMapDataQueryResults
            if (app.tourManager.webMapData.errorCode === 0 && typeof app.tourManager.webMapData.webMapDataQueryResults !== "undefined") {
                loadMap()
            } else {
                tourError(app.tourManager.webMapData.errorMsg);
            }
        }
    }

    function loadMap (viewpointExtent) {
        offlineMapMask.visible = false
        showGraphics = true
        if (app.isOnline && !app.useOfflineMap) {
            map.initUrl = "%1/home/webmap/viewer.html?webmap=%2".arg(app.portalUrl).arg(app.tourManager.webMapData.webmapId)
            mapView.map = map
            if (viewpointExtent) mapView.setViewpoint(viewpointExtent)
        } else if (app.mmpkManager.offlineMapExist && app.useOfflineMap) {
            mmpk.load()
        } else if (app.mmpkManager.offlineMapExist && !app.useOfflineMap) {
            showGraphics = false
            mmpk.cancelLoad()
            mapView.map = map
            pageHelper.getTourData()
            app.busyIndicator.visible = false
        } else {
            //no network nor mmpk
            showGraphics = false
            pageHelper.getTourData()
            app.busyIndicator.visible = false
        }
    }

    onShowGraphicsChanged: {
        offlineMapMask.visible = !showGraphics
    }

    //------------------------- CARD VIEW -------------------------------------------

    Rectangle {
        anchors.fill: parent
        color: app.pageBackgroundColor
        z:-1
    }

    ScrollBar {
        id: scrollBar1
        visible: !photoMode
        scrollItem: cardList
        orientation: "vertical"
    }

    Component {
        id: cardListItemMobileDelegate
        CardListItemMobileDelegate {}
    }

    Component {
        id: cardListItemDelegate
        CardListItemDelegate {}
    }

    ListView {
        id: cardList

        anchors {
            top: banner.bottom
            left: parent.left
            right: parent.right
            bottom: iPhoneXOffset.visible ? iPhoneXOffset.top : parent.bottom
            bottomMargin: 0
            leftMargin: app.widthOffset
            rightMargin: app.widthOffset
        }

        orientation: ListView.Vertical
        height: screenHeight - bannerHeight
        width: screenWidth
        visible: !mapMode
        clip: true
        currentIndex: currentPhotoIndex
        spacing: app.units(3)

        preferredHighlightBegin: 0;
        preferredHighlightEnd: 0  //this line means that the currently highlighted item will be central in the view

        cacheBuffer: isSmallScreen ? parent.height : parent.height*3

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: banner.bottom
            bottomMargin: 5*app.scaleFactor
            topMargin: 5*app.scaleFactor
        }

        model: tourItemsListModel

        onCountChanged: {
            if (count) {
                tourItemsListModel.cacheMetaData()
            }
        }

        delegate: isSmallScreen? cardListItemMobileDelegate : cardListItemDelegate
    }

    //------------------------- MAP VIEW -------------------------------------------

    MapView {
        id: mapView

        property int mapReadyCount: 0
        property real initialMapRotation: 0

        onMapReadyCountChanged: {
            if (mapReadyCount === 1) {
                initialMapRotation = mapRotation
            }
        }

        visible: mapMode || photoMode

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: panelMode ? parent.bottom : mapViewPanel.top
            topMargin: app.headerHeight
        }

        property alias mmpk: mmpk
        MobileMapPackage {
            id: mmpk

            signal mmpkLoaded ()

            path: app.mmpkManager.fileUrl

            //Component.onCompleted: {
            //    mmpk.load()
            //}

            onLoadStatusChanged: {
                if (loadStatus === Enums.LoadStatusLoaded) {
                    loadMapInMapView(0)
                    offlineMapMask.visible = false
                } else {
                    offlineMapMask.visible = true
                }
            }

            onMmpkLoaded: {
                pageHelper.getTourData()
                app.busyIndicator.visible = false
            }

            function loadMapInMapView (idx) {
                if (!idx) idx = 0
                var currentViewpointExtent = offlineMapMask.visible ? mapView.map.initialViewpoint : mapView.currentViewpointExtent
                mapView.map = mmpk.maps[idx]
                mapView.setViewpoint(currentViewpointExtent)
                mmpkLoaded()
            }
        }

        Rectangle {
            id: offlineMapMask

            anchors {
                fill: parent
            }
            visible: !(map.loadStatus === Enums.LoadStatusLoaded) && !app.isOnline && !busySymbol.visible
            color: "black"

            Image {
                anchors.fill: parent
                fillMode: Image.Tile
                opacity: 0.4
                source: "images/mapmask.jpg"
            }

            Rectangle {

                id: refreshMap

                property real fontPointSize: app.baseFontSize

                anchors {
                    fill: parent
                    leftMargin: panelMode ? mapViewPanel.width : undefined
                }

                width: Math.min(app.units(600), 0.8*parent.width)
                height: app.units(100)
                color: "transparent"

                Text {
                    id: mapStatus

                    text: qsTr("Map not available in offline mode. Click to refresh.")
                    visible: !app.isOnline
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                    color: "white"
                    font.pointSize: app.baseFontSize
                    font.family: app.customTextFont.name
                    fontSizeMode: Text.HorizontalFit
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    anchors.fill: parent
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            refreshMap.refresh()
                        }
                    }
                }

                Connections {
                    target: app
                    onIsOnlineChanged: {
                        //console.log("IS ONLINE #################", app.isOnline)
                        if (app.isOnline) {
                            refreshMap.refresh()
                        }
                    }
                }

                function refresh () {
                    busySymbolTimer.start()
                    loadMap()
                }
            }
        }

        backgroundGrid: BackgroundGrid {
            gridLineWidth: 1
            gridLineColor: "#22000000"
        }

        rotationByPinchingEnabled: true
        zoomByPinchingEnabled: true
        wrapAroundMode: Enums.WrapAroundModeEnabledWhenSupported

        Components.CustomBusyIndicator {
            id: busySymbol

            Timer {
                id: busySymbolTimer

                interval: 1000
                repeat: false
                triggeredOnStart: true

                onTriggered: {
                    busySymbol.visible = running ? true : false
                }
            }

            visible: false
            busyColor: app.headerBackgroundColor
            anchors {
                centerIn: offlineMapMask
            }

            color: AppFramework.alphaColor(app.textColor, 0.2)
            onVisibleChanged: {
                if (visible) {
                    app.busyIndicator.visible = false
                }
            }
        }

        Map {
            id: map

            onLoadStatusChanged: {
                switch (map.loadStatus) {
                case Enums.LoadStatusLoaded:
                    app.busyIndicator.visible = false
                    mapView.mapReadyCount += 1

                    if (app.offlineMMPKID && !mmpkManager.offlineMapExist && app.downloadOfflineMap && app.mmpkManager.loadStatus !== 1) {
                        app.mmpkDialog.open()
                    }

                    break
                }
            }

            onLoadErrorChanged: {
                tourError("%1 \n%2".arg(mapView.map.loadError.message).arg(mapView.map.loadError.additionalMessage))
                app.busyIndicator.visible = false
            }
        }

        Connections {
            target: AuthenticationManager

            onAuthenticationChallenge: {
                tourError(qsTr("Premium content or secured layers are not supported."))
                app.busyIndicator.visible = false
            }
        }

        ColumnLayout {
            id: mapControls

            property real defaultMargin: app.units(16)
            property real iconSize: app.units(36)
            property real radius: 0.5 * iconSize

            height: 3 * width
            width: mapControls.radius + defaultMargin
            spacing: defaultMargin
            visible: (map.loadStatus === Enums.LoadStatusLoaded) || (mmpk.loadStatus === Enums.LoadStatusLoaded)
            anchors {
                top: parent.top
                right: parent.right
                margins: mapControls.defaultMargin
                rightMargin: app.isIphoneX && !app.isPortrait ? app.widthOffset : mapControls.defaultMargin
                topMargin: mapControls.defaultMargin + bannerHeight
            }

            Image {
                id: northArrow

                opacity: mapView.mapRotation ? 1 : 0
                rotation: mapView.mapRotation
                Layout.preferredWidth: 2 * mapControls.radius
                Layout.preferredHeight: Layout.preferredWidth
                source: "images/compass.png"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mapView.setViewpointRotation(mapView.initialMapRotation)
                    }
                }
            }

            MCSC.LocationTracker{

            }

            Rectangle {

                Layout.preferredWidth: 2 * mapControls.radius
                Layout.preferredHeight: Layout.preferredWidth
                radius: 0.5 * Layout.preferredWidth
                color: "#FFFFFF"

                Image {
                    id: homeImg
                    source: "images/home.png"
                    anchors {
                        fill: parent
                        margins: 0.2 * mapControls.defaultMargin
                    }
                    mipmap: true
                }
                ColorOverlay{
                    anchors.fill: homeImg
                    source: homeImg
                    color: "#4C4C4C"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        mapView.setViewpointWithAnimationCurve(mapView.map.initialViewpoint, 2.0, Enums.AnimationCurveEaseInOutCubic)
                    }
                }
            }

            Rectangle {
                id: locationBtn

                property bool checked: false

                Layout.preferredWidth: 2 * mapControls.radius
                Layout.preferredHeight: Layout.preferredWidth
                radius: 0.5 * Layout.preferredWidth
                color: "#FFFFFF"

                Image {
                    id: locationImg
                    source: "images/location.png"
                    anchors {
                        fill: parent
                        margins: 0.2 * mapControls.defaultMargin
                    }
                    mipmap: true
                }
                ColorOverlay{
                    anchors.fill: locationImg
                    source: locationImg
                    color: devicePositionSource.active && locationBtn.checked ? "steelBlue" : "#4c4c4c"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        locationBtn.checked = !locationBtn.checked
                        if (!mapView.locationDisplay.started) {
                            mapView.locationDisplay.start()
                            mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeRecenter
                        } else {
                            mapView.locationDisplay.stop()
                        }
                    }
                }
            }

            Rectangle {
                id: basemapBtn
                visible: app.showBasemapSwitcher
                Layout.preferredWidth: 2 * mapControls.radius
                Layout.preferredHeight: Layout.preferredWidth
                radius: 0.5 * Layout.preferredWidth
                color: "#FFFFFF"

                Image {
                    id: basemapImg
                    source: "images/basemaps.png"
                    anchors {
                        fill: parent
                        margins: 0.2 * mapControls.defaultMargin
                    }
                    mipmap: true
                }
                ColorOverlay{
                    anchors.fill: basemapImg
                    source: basemapImg
                    color: "#4C4C4C"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {

                        basemapGallery = basemapGalleryPage.createObject(app)
                        basemapGallery.onTransitionOutCompleted.connect(function () {
                            basemapGallery.destroy()
                        })
                        basemapGallery.show()

                    }
                }
            }

        }

        locationDisplay {
            positionSource: PositionSource {
                id: devicePositionSource
            }
            compass: Compass {}
            //autoPanMode: Enums.LocationDisplayAutoPanModeRecenter
        }

        property alias tourGraphics: tourGraphics
        GraphicsOverlay {
            id: tourGraphics

            visible: showGraphics
            selectionColor: "cyan"
            renderingMode: Enums.GraphicsRenderingModeStatic
            labelsEnabled: true
            renderer: UniqueValueRenderer {
                id: uvRenderer

                fieldNames: ["icon_color"]
                defaultLabel: "default"
                defaultSymbol: defaultSymbol

                UniqueValue {
                    id: uvInfoBlue

                    label: "Blue"
                    values: ["b"]
                    symbol: pmsBlue
                }

                UniqueValue {
                    id: uvInfoBlue2

                    label: "Blue"
                    values: ["B"]
                    symbol: pmsBlue
                }

                UniqueValue {
                    id: uvInfoGreen

                    label: "Green"
                    values: ["g"]
                    symbol: pmsGreen
                }

                UniqueValue {
                    id: uvInfoGreen2

                    label: "Green"
                    values: ["G"]
                    symbol: pmsGreen
                }

                UniqueValue {
                    id: uvInfoPurple

                    label: "Purple"
                    values: ["p"]
                    symbol: pmsPurple
                }
                UniqueValue {
                    id: uvInfoPurple2

                    label: "Purple"
                    values: ["P"]
                    symbol: pmsPurple
                }

                UniqueValue {
                    id: uvInfoRed

                    label: "Red"
                    values: ["r"]
                    symbol: pmsRed
                }
                UniqueValue {
                    id: uvInfoRed2

                    label: "Red"
                    values: ["R"]
                    symbol: pmsRed
                }

                PictureMarkerSymbol {
                    id: defaultSymbol

                    url: "images/esri_pin_default.png"
                    width: 14
                    height: 24
                }

                PictureMarkerSymbol {
                    id: pmsBlue

                    url: "images/esri_pin_blue.png"
                    width: 14
                    height: 24
                }

                PictureMarkerSymbol {
                    id: pmsGreen

                    url: "images/esri_pin_green.png"
                    width: 14
                    height: 24
                }

                PictureMarkerSymbol {
                    id: pmsPurple

                    url: "images/esri_pin_purple.png"
                    width: 14
                    height: 24
                }

                PictureMarkerSymbol {
                    id: pmsRed

                    url: "images/esri_pin_red.png"
                    width: 14
                    height: 24
                }
            }

            onComponentCompleted: {
                createLabels ()
            }

            function createLabels () {
                var textSymbol = ArcGISRuntimeEnvironment.createObject("TextSymbol", {size: 10, color: "#FFFFFF", fontWeight: Enums.FontWeightBold}),
                        labelDefinitionJson = {
                    "labelExpressionInfo": {"expression": "$feature.currentOrder"},
                    "labelPlacement": "esriServerPointLabelPlacementCenterCenter",
                    "repeatLabelDistance":1,
                    "symbol": textSymbol.json,
                },
                labelDefinition = ArcGISRuntimeEnvironment.createObject("LabelDefinition", {json: labelDefinitionJson})
                tourGraphics.labelDefinitions.append(labelDefinition)
            }

            function updateLabels () {
                for (var i=0; i<tourItemsListModel.count; i++) {
                    for (var j=0; j<tourGraphics.graphics.count; j++) {
                        if (tourGraphics.graphics.get(j).attributes.attributesJson.uniqueId === tourItemsListModel.get(i).uniqueId) {
                            var graphicAttributes = tourGraphics.graphics.get(j).attributes.attributesJson
                            graphicAttributes.currentOrder = i+1
                            tourGraphics.graphics.get(j).attributes.attributesJson = graphicAttributes
                            break
                        }
                    }
                }
            }
        }

        function appendGraphic (graphic, attributes) {
            //console.log(graphic.geometry.spatialReference.wkid, spatialReference.wkid, mapView.spatialReference.wkid, mapView.map.spatialReference.wkid)
            tourGraphics.graphics.append(graphic)
            //console.log(JSON.stringify(attributes))
            tourItemsListModel.append(attributes)
        }

        function clearItems () {
            tourGraphics.graphics.clear()
            tourItemsListModel.clear()
        }

        onMouseClicked: {
            tourGraphics.clearSelection()
            var tolerance = app.units(5),
                    returnPopupsOnly = false,
                    maximumResults = 1
            mapView.identifyGraphicsOverlayWithMaxResults(tourGraphics, mouse.x, mouse.y, tolerance, returnPopupsOnly, maximumResults)
        }

        onIdentifyGraphicsOverlayStatusChanged: {
            switch (identifyGraphicsOverlayStatus) {
            case Enums.TaskStatusCompleted:
                if (identifyGraphicsOverlayResult.graphics.length) {
                    var graphic = identifyGraphicsOverlayResult.graphics[0]
                    for (var i=0; i<tourGraphics.graphics.count; i++) {
                        if (graphic.equals(tourGraphics.graphics.get(i))) {
                            onGraphicClickHandler(graphic)
                            break
                        }
                    }
                }
                break
            case Enums.TaskStatusErrored:
                break
            }
        }
    }

    MapViewPanel {
        id: mapViewPanel
    }

    DropShadow {
        visible: mapViewPanel.panelThreshold && mapViewPanel.visible && !isPhotoFullScreen
        anchors.fill: mapViewPanel ? mapViewPanel : undefined
        horizontalOffset: 1
        verticalOffset: 2
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: mapViewPanel
        cached: true
    }

    //--------------------------------------------------------------------------

    Components.MessageDialog {
        id: messageBox

        showLeftButton: false
        visible: false
        titleTextSize: app.subtitleFontSize
        descriptionTextSize: app.baseFontSize


        onRightButtonClicked: {
            visible = false
            if (map.loadStatus !== Enums.LoadStatusLoaded){
                exit()
            }
        }
    }

    onTourError: {
        messageBox.visible = message&&app.isOnline ? true : false;
        messageBox.descriptionText = message? message : strings.kSomethingWentWrong;
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: banner

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: photoMode ? 0 : bannerHeight
        color: app.headerBackgroundColor
        //opacity: 0.9

        MouseArea {
            anchors.fill: parent
            onClicked: {
                mouse.accepted = false
                //app.isOnline = !app.isOnline
            }
        }

        ImageButton {
            id: menuButton

            visible: !photoMode

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                margins: 8*app.scaleFactor
                leftMargin: app.isIphoneX && !app.isPortrait ? app.widthOffset : 8*app.scaleFactor
            }
            width: app.units(30)
            height: app.units(30)

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

        ComboBox {
            id: sortButton

            visible: (tourItemsListModel.count > 1) && !photoMode && app.enableTourItemSorting
            model: comboBoxOptions

            anchors {
                right: infoButton.left
                top: parent.top
                margins: 8 * app.scaleFactor
                rightMargin: 16 * app.scaleFactor
            }

            width: app.units(30)
            height: width

            style: ComboBoxStyle {
                background: Image {
                    source: "images/sort.png"
                }
                label: QtObject {}
            }

            ListModel {
                id: comboBoxOptions
            }

            onPressedChanged: {
                if (pressed) {
                    sortButton.updateSortView()
                }
            }

            onActivated: {
                app.busyIndicatorTimer.start()
                currentIndex = index

                var sortOrder = app.customSort ? (app.customSortOrder || "desc") : "desc"
                switch (currentText) {
                case (strings.kDefault):
                    tourItemsListModel.sortByNumberAttribute("defaultOrder", sortOrder)
                    break
                case (strings.kSortByDistance):
                    tourItemsListModel.sortByNumberAttribute("distance", "desc")
                    break
                case (strings.kSortByTitle):
                    tourItemsListModel.sortByStringAttribute("name", "desc")
                }
                mapViewPanel.featuresList.positionViewAtBeginning()
                cardList.positionViewAtBeginning()
                if (tourItemsListModel.sortCount !== 1) {
                    currentPhotoIndex = 0
                }
            }

            Component.onCompleted: {
                updateSortView()
                currentIndex = 0
            }

            function updateSortView() {
                var index = -1,
                        currentTextCopy = currentText,
                        options = [
                            {"name": strings.kDefault},
                            {"name": strings.kSortByTitle},
                            {"name": strings.kSortByDistance}
                        ]
                comboBoxOptions.clear()
                for (var i=0; i<options.length; i++) {
                    if (!app.showDistance && (options[i].name === strings.kSortByDistance)) {
                        continue
                    }
                    comboBoxOptions.append(options[i])
                    if (options[i].name === currentTextCopy) {
                        index = comboBoxOptions.count - 1
                    }
                }
                currentIndex = index
            }
        }

        ImageButton {
            id: infoButton

            anchors {
                right: parent.right
                top: parent.top
                margins: 8 * app.scaleFactor
                rightMargin: app.isIphoneX && !app.isPortrait ? app.widthOffset : 8*app.scaleFactor
            }
            width: app.units(30)
            height: app.units(30)
            visible: !photoMode

            source: "images/info.png"

            checkedColor : "transparent"
            pressedColor : "transparent"
            hoverColor : "transparent"
            glowColor : "transparent"

            onClicked: {
                //Qt.openUrlExternally("%1/home/webmap/viewer.html?webmap=%2".arg(app.portalUrl).arg(app.tourManager.webMapData.webmapId))
                Qt.openUrlExternally("https://notifications-mcsc.hub.arcgis.com/")
                return

                learn = learnMorePage.createObject(app)
                learn.onTransitionOutCompleted.connect(function () {
                    learn.destroy()
                })
                learn.show(app.tourManager.tourItems.tourData)
            }
        }

        Text {
            id: titleText

            anchors {
                left: menuButton.right
                right: parent.right
                verticalCenter: parent.verticalCenter
            }

            //text: tourItemInfo ? tourItemInfo.title : app.info.title
            text: tourInfo ? tourInfo.values.title : app.info.title
            elide: Text.ElideRight

            font.family: app.customTitleFont.name

            font {
                pointSize: app.baseFontSize
            }
            //color: "#f7f8f8"
            color: app.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: false
        }

        Rectangle {
            id: buttonBar
            //visible: false
            visible: !photoMode
            anchors {
                left: menuButton.right
                centerIn: parent
            }

            color: "transparent"
            radius: 2
            border.color: "#FFFFFF"
            border.width: 1
            clip:true

            //height: bannerHeight*0.8
            height: Math.max(32 * app.scaleFactor, listLabel.contentHeight + app.units(2), + mapLabel.contentHeight + app.units(2))
            width: Math.max(125 * app.scaleFactor, 2*listLabel.contentWidth + app.units(4), + 2*mapLabel.contentWidth + app.units(4))

            GridLayout {
                rowSpacing: 0
                columnSpacing: 0
                columns: 2
                anchors.verticalCenter: parent.verticalCenter
                anchors {
                    fill: parent
                    margins: 0
                }

                Rectangle {
                    Layout.preferredWidth:  parent.width/2
                    Layout.preferredHeight: parent.height
                    anchors.margins: 0
                    radius: buttonBar.radius
                    clip: true
                    color: (mapMode && !photoMode) ? "transparent" : "white"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!(mapMode && !photoMode)) {
                                cardList.positionViewAtBeginning()
                            }
                            mapMode = false
                            photoMode = false
                        }
                    }

                    Text {
                        id: listLabel
                        text: strings.kList
                        anchors.centerIn: parent
                        font {
                            pointSize: app.subtitleFontSize
                        }
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: (mapMode && !photoMode)? "white" : Qt.darker(app.headerBackgroundColor)
                        font.family: app.customTextFont.name
                    }
                }

                Rectangle {
                    Layout.preferredWidth: parent.width/2
                    Layout.preferredHeight: parent.height
                    radius: buttonBar.radius
                    anchors.margins: 0
                    clip: true
                    color: mapMode&&!photoMode ? "white" : "transparent"
                    Text {
                        id: mapLabel
                        text: strings.kMap
                        anchors.centerIn: parent
                        font {
                            pointSize: app.subtitleFontSize
                        }
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        color: mapMode&&!photoMode ? Qt.darker(app.headerBackgroundColor) : "white"
                        font.family: app.customTextFont.name
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            photoMode = false
                            mapMode = true
                        }
                    }
                }

            }
        }
    }

    Components.HeaderShadow {
        source: banner
        anchors.fill: banner
    }

    //--------------------------------------------------------------------------

    Rectangle {
        id: iPhoneXOffset

        visible:  (!panelMode || !mapMode || photoMode) && app.heightOffset > 0
        anchors.bottom: parent.bottom
        height: app.heightOffset
        width: parent.width
        color: photoMode ? mapViewPanel.backgroundColor : app.pageBackgroundColor
    }

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

        hideMask: function(){mask.visible = false}
        headerHeight: bannerHeight

        Connections {
            target: app

            onUseOfflineMapChanged: {
                //console.log(mapView.currentViewpointExtent)
                if (app.useOfflineMap) {
                    if (mmpk.loadStatus !== Enums.LoadStatusLoaded) {
                        mmpk.loadStatusChanged.connect(function () {
                            if (mmpk.loadStatus === Enums.LoadStatusLoaded) {
                                mmpk.loadMapInMapView()
                            }
                        })
                        mmpk.load()
                    } else {
                        mmpk.loadMapInMapView(0)
                    }
                    showGraphics = true
                    tourError("")
                    messageBox.visible = false
                } else {
                    mmpk.cancelLoad()
                    loadMap(mapView.currentViewpointExtent)
                }
            }
        }
    }

    Component {
        id: learnMorePage

        LearnMorePage {
        }
    }

    Component {
        id: basemapGalleryPage
        BasemapGalleryPage {
        }
    }

    AboutPage {
        id: aboutPage
    }

    //--------------------------------------------------------------------------

    function onGraphicClickHandler (graphic) {
        tourGraphics.clearSelection()

        for (var i=0; i<tourItemsListModel.count; i++) {
            if (tourItemsListModel.get(i).uniqueId === graphic.attributes.attributesJson.uniqueId) {
                if (mapListView.currentIndex !== i) {
                    mapListView.currentIndex = i
                    currentPhotoIndex = i
                    graphic.selected = true
                    mapView.setViewpointGeometry(graphic.geometry.extent)
                    break
                }
            }
        }
    }

    function onPhotoClickHandler (index) {
        tourGraphics.clearSelection()
        currentPhotoIndex = index

        if (index < tourItemsListModel.count) {
            index = index+1
        }

        if (index > 0) {
            index = index-1
        }

        console.log("Got photo index: ", index)

        if (mapListView.currentIndex !== index) {
            mapListView.currentIndex = index
            currentPhotoIndex = index
        }

        for (var i=0; i<tourGraphics.graphics.count; i++) {
            var graphic = tourGraphics.graphics.get(i)
            //console.log(tourItemsListModel.get(index).objectid, graphic.attributes.attributesJson.objectid)
            if (graphic.attributes.attributesJson.uniqueId === tourItemsListModel.get(index).uniqueId) {
                graphic.selected = true
                mapView.setViewpointGeometry(graphic.geometry.extent)
                break
            }
        }
    }
}

