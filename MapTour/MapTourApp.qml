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

import QtQuick 2.3
import QtQml 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls 2.2 as NewControls
import QtPositioning 5.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.2
import ArcGIS.AppFramework.Networking 1.0

import "components" as Components
import "../MCSC" as MCSC

App {
    id: app
    width: 400
    height: 640

    property string appId: app.info.itemInfo.id
    property alias customTitleFont : customTitleFont
    property alias customTextFont : customTextFont

    property bool isDebug: false

    property bool isOnline: isWindows7 ? Networking.isOnline : networkConfig.isOnline

    property real scaleFactor : AppFramework.displayScaleFactor

    property real baseFontSize : app.info.propertyValue("baseFontSize", 16) * fontScale
    property real subscriptFontSize: 0.8 * baseFontSize
    property real subtitleFontSize: 1.2 * baseFontSize
    property real titleFontSize: 1.4 * baseFontSize
    property real fontScale: 1.0

    property color valuehighlightColor: "#00ffffff"

    property color selectColor: Qt.lighter(app.headerBackgroundColor)

    property real smallSizeThreshold: units(450)
    property bool isSmallScreen: (width || height) < smallSizeThreshold
    property bool isPortrait: height > width
    property bool isSignedIn: false

    property real headerHeight: 50 * app.scaleFactor

    property bool isIphoneX: false
    property bool isWindows7: false
    readonly property real heightOffset: isIphoneX ? app.units(20) : 0
    readonly property real widthOffset: isIphoneX && !app.isPortrait ? app.units(40) : 0

    //******************* Map Tour Definition ****************
    property string tourTitle: ""
    property string tourSubtitle: ""
    property variant tourOrderArray: []

    //***************** Config *************************

    property string landingpageBackground : app.info.propertyValue("startBackground") > "" ? app.folder.fileUrl(app.info.propertyValue("startBackground")) : ""
    property string customTitleFontTTF: app.info.propertyValue("customTitleFontTTF","");
    property string customTextFontTTF: app.info.propertyValue("customTextFontTTF","");
    property string portalQueryItemTypes: app.info.propertyValue("portalQueryItemTypes","type:\"Web Mapping Application\"")
    property var urlParameters
    //portal
    property var orgId : app.info.propertyValue("orgId", null);
    property var queryString :app.info.propertyValue("queryString", null);
    property var sortOrder: app.info.propertyValue("portalSortOrder","desc");
    property var sortField: app.info.propertyValue("portalSortField","modified");
    //colors
    property color headerBackgroundColor: app.info.propertyValue("textBackgroundColor","#084d73");
    property string textColor : app.info.propertyValue("textColor","#444");
    property color titleColor: "#FFFFFF"
    property color subtitleColor: "#EBEBEB"
    property color pageBackgroundColor: "#EAEAEA"
    property color separatorColor: "#22111111"
    property color linkColor: "#0000FF"
    //maptour
    property bool showGallery: app.info.propertyValue("showGallery",true);
    property var webmapid: app.info.propertyValue("webmapid","");
    property var tourLayerId: app.info.propertyValue("tourlayerId","");
    property bool showBasemapSwitcher: app.info.propertyValue("showBasemapSwitcher",true);

    //custom fields
    property string titleField: app.info.propertyValue("maptour_titleField","NAME");
    property string descField: app.info.propertyValue("maptour_descriptionField","CAPTION");
    property string thumbnailField: app.info.propertyValue("maptour_thumbnailField", "PIC_URL");
    property string imageField: app.info.propertyValue("maptour_imageField","THUMB_URL");
    property string iconColorField : app.info.propertyValue("maptour_iconColorField", "icon_color") || "icon_color";
    property bool customRenderer : app.info.propertyValue("maptour_customRenderer",true);
    property bool customSort : app.info.propertyValue("maptour_customSort",false);
    property string customSortField: app.info.propertyValue("maptour_customSortField","NUMBER");
    property string customSortOrder: app.info.propertyValue("maptour_customSortOrder","asc");
    property string feedbackEmail: app.info.propertyValue("feedbackEmail","");

    property bool enableTourItemSorting: app.info.propertyValue("enableTourItemSorting", "true");
    property string sortType: app.info.propertyValue("sortType", "default")

    // location info
    property bool enableDistance: app.info.propertyValue("enableDistance", false)
    property bool canUseDistance: locationManager.valid && locationManager.isLocationValid
    property bool showDistance: enableDistance && canUseDistance
    property real distanceThresholdInKm: 0.5
    property string distanceUnit: Qt.locale().measurementSystem === Locale.MetricSystem ? "km" : "mi"

    readonly property url portalUrl: app.info.propertyValue("portalUrl", "https://www.arcgis.com")

    property alias locationManager: locationManager
    LocationManager {
        id: locationManager

        property real lastObtainedDeviceLatitude: 0
        property real lastObtainedDeviceLongitude: 0

        isDebug: app.isDebug
        active: enableDistance || sortType === "distance"
    }

    //Strings for offline
    readonly property string kFavorites: qsTr("Favorites")
    readonly property string kClearCache: qsTr("Clear cache")
    readonly property string kClearData: qsTr("Clear data")
    readonly property string kConfirmation: qsTr("Are you sure?")
    readonly property string kRemoveAllCache: qsTr("Remove all cached map tour data and images from your device.")
    readonly property string kOk: qsTr("Ok")

    readonly property string offlineMMPKID: app.info.propertyValue("offlineMMPKID", "")
    property bool downloadOfflineMap: false
    property bool useOfflineMap: false

    // Strings for basemap switcher
    readonly property string kSelectBasemap: qsTr("Select a basemap")
    readonly property string kBasemaps: qsTr("Basemaps")
    readonly property string kChangeBasemap: qsTr("Change basemap")

    //strings for cellular data verification
    readonly property string kOfflineMapAvailable: "Offline map available. Download using mobile data?"
    readonly property string kWaitForWifi: "Wait for Wi-Fi"
    readonly property string kUseMobileData: "Use your mobile data to download the offline map?"

    onIsOnlineChanged: {
        //console.log("#####################", app.isOnline)
        if (stackView.depth < 2) {
            useOfflineMap = !isOnline && mmpkManager.hasOfflineMap()
        }
    }

    //--------------------------------------------------------------------------

    Button {
        id: androidBackButtonTester
        visible: isDebug
        z: 10
        width: 50
        height: width/2
        text: "back"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40
        onClicked: {
            backButtonPressed()
        }
    }

    focus: true

    signal backButtonPressed ()

    Keys.onReleased: {
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape){
            event.accepted = true
            backButtonPressed ()
        }
    }

    //--------------------------------------------------------------------------

    //custom font if any
    FontLoader {
        id: customTitleFont
        source: app.folder.fileUrl(customTitleFontTTF)
    }

    FontLoader {
        id: customTextFont
        source: app.folder.fileUrl(customTextFontTTF)
    }

    //----------------------------------------------------

    property alias busyIndicator: busyContainer

    Components.CustomBusyIndicator {
        id: busyContainer

        visible: false
        busyColor: headerBackgroundColor
        anchors.centerIn: parent
        color: AppFramework.alphaColor(app.textColor, 0.2)
    }

    property alias busyIndicatorTimer: busyIndicatorTimer
    Timer {
        id: busyIndicatorTimer
        interval: 800
        repeat: false
        triggeredOnStart: true

        onTriggered: {
            busyIndicator.visible = running ? true : false
        }
    }

    //---------------------------------------------------
    property alias stackView: stackView
    NewControls.StackView {

        id: stackView
        anchors.fill: parent

        initialItem: landingPage

        onCurrentItemChanged: {
            var pageNames = ["galleryPage", "tourPage"]
            for (var i=0; i<pageNames.length; i++) {
                if (currentItem.objectName === pageNames[i]) {
                    currentItem.pageInStack = true
                }
            }
        }

        function showGallery(tourId) {
            app.busyIndicator.visible = true
            push(galleryPage, {"initialTour": tourId});
        }

        function showTour(tourInfo) {
            if(tourInfo) {
                if (stackView.currentItem.objectName !== "tourPage") {
                    stackView.push(tourPage);
                    stackView.currentItem.loadTour(tourInfo);
                }
            } else {
                tourManager.tours.onToursUpdated.connect(function () {
                    if (tourManager.tours.errorCode === 0 && tourManager.tours.count) {
                        tourManager.tourItems.onTourItemsUpdated.connect(function () {
                            if (tourManager.tourItems.errorCode === 0 &&
                                typeof tourManager.tourItems.tourItemsQueryResults !== "undefined" &&
                                stackView.currentItem.objectName !== "tourPage") {
                                stackView.push(tourPage)
                                stackView.currentItem.loadTour(tourManager.tourItems.tourItemsQueryResults)
                            }
                        })
                        tourManager.tourItems.load(tourManager.tours.get(0))
                    }
                })
                tourManager.tours.refresh()
            }
        }


    }

    //--------------------------------------------------------------------------


    Component {
        id: landingPage

        LandingPage {

            onSignInClicked: {
                if(!app.showGallery) {
                    stackView.showTour(null);
                } else {
                    stackView.showGallery(tourId);
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: galleryPage

        GalleryPage {
            objectName: "galleryPage"
            portal: app.portal

            onTourSelected: {
                app.busyIndicator.visible = true
                tourManager.tourItems.onTourItemsUpdated.disconnect(showTour)
                tourManager.tourItems.onTourItemsUpdated.connect(showTour)
                tourManager.tourItems.load(tourInfo)
            }

            Timer {
                id: delayedPush
                property int triggerCount: 0

                interval: 1000
                repeat: false
                triggeredOnStart: true

                onTriggered: {
                    triggerCount +=1
                    if (triggerCount === 1) {
                        stackView.showTour(tourManager.tourItems.tourItemsQueryResults)
                    } else {
                        triggerCount = 0
                    }
                }
            }

            function showTour() {
                delayedPush.start()
            }
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: tourPage

        TourPage {
            objectName: "tourPage"
            portal: app.portal

            onExit: {
                if (stackView.currentItem.objectName === "tourPage") {
                    stackView.pop();
                    tourItemsListModel.clear();
                    stackView.currentItem.toursListView.refresh();
                }
            }
        }
    }

    //--------------------------------------------------------------------------

    property alias portal: portal
    Portal {
        id: portal
        url: app.portalUrl
        property QtObject basemapsListModel: ListModel {}

        onLoadStatusChanged: {
            switch (loadStatus) {
            case Enums.LoadStatusFailedToLoad:
                retryLoad()
                tourManager.organizationId = portal.portalInfo.organizationId
                break
            case Enums.LoadStatusLoaded:
                fetchBasemaps()
                break
            }
        }

        onFetchBasemapsStatusChanged: {
                    switch (fetchBasemapsStatus) {
                    case Enums.TaskStatusCompleted:
                        for (var i=0; i<basemaps.count; i++) {
                            basemapsListModel.append({"basemaps":basemaps.get(i)})
                        }
                        basemapsListModel = basemaps;
                        break
                    }
        }


        Component.onCompleted: {
            if (app.isOnline) {
                load()
            }
        }
    }

    //--------------------------------------------------------------------------

    property alias tourManager: tourManager
    TourManager {
        id: tourManager

        appId: app.appId
        referer: app.portalUrl
        isOnline: app.isOnline
        baseTextSize: 0.8 * app.baseFontSize
        primaryColor: app.headerBackgroundColor
        portalUrl: portal.url
        // MATT
        organizationId: app.orgId  //"Sv9ZXFjH5h1fYAaI"portal.loadStatus === Enums.LoadStatusLoaded ? portal.portalInfo.organizationId : app.orgId
        tourPageSize: 25
        tourOrderBy: app.sortField || "created"
        tourSortField: app.sortField || "created"
        tourSortOrder: app.sortOrder ||  "desc"
        tourItemTypes: app.portalQueryItemTypes
        tourQueryString: app.queryString

    }

    //--------------------------------------------------------------------------

    property alias mmpkManager: mmpkManager
    Components.MmpkManager {
        id: mmpkManager

        itemId: app.offlineMMPKID
        rootUrl: "%1/sharing/rest/content/items/".arg(app.portalUrl)
        subFolder: app.appId
    }

    property alias mmpkDialog: mmpkDialog
    Components.MessageDialog {
        id: mmpkDialog

        titleText: ""
        visible: false
        titleTextSize: app.subtitleFontSize
        descriptionTextSize: app.baseFontSize
        themeColor: app.headerBackgroundColor
        descriptionText: networkConfig.isMobileDataOnly ? app.kOfflineMapAvailable : qsTr("Offline map available. Download now?")
        leftButtonText: networkConfig.isMobileDataOnly ? kWaitForWifi : qsTr("Later")

        onLeftButtonClicked: {
            app.downloadOfflineMap = false
            close()
        }

        onRightButtonClicked: {
            mmpkManager.downloadOfflineMap(handleDownloadStatus)
            close()
        }

        function handleDownloadStatus () {

            if (app.mmpkManager.loadStatus === 0) {
                //success
                toast.show(qsTr("Download complete!"))
                app.downloadOfflineMap = false
            } else if (app.mmpkManager.loadStatus === -1 || app.mmpkManager.loadStatus === 2) {
                toast.show(qsTr("Failed to download. Try again later."))
            }
        }
    }

    Components.ToastDialog {
        id: toast
    }

    Components.CustomBusyIndicator {
        visible: app.mmpkManager.loadStatus === 1
        busyColor: headerBackgroundColor
        anchors.centerIn: parent
        color: AppFramework.alphaColor(app.textColor, 0.2)
    }

    //--------------------------------------------------------------------------

    property alias networkConfig: networkConfig
    Components.NetworkConfig {
        id: networkConfig
    }

    //--------------------------------------------------------------------------
    FileFolder {
        id: toursFolder
        path: "~/ArcGIS/MapTours2"
    }

    //--------------------------------------------------------------------------

    Component {
        id: webPageComponent

        Components.WebPage {
            id: webPage

            showHistory: false
            isDebug: false
            headerHeight: app.headerHeight
            headerColor: app.headerBackgroundColor

            function load(url) {
                visible = true;
                webPage.transitionIn(webPage.transition.bottomUp);
                loadPage(url);
            }

            onTransitionOutCompleted: {
                visible = false;
                webPage.destroy();
            }
        }
    }

    function openUrlInternally (link) {
        var component = webPageComponent,
            webPage = component.createObject(app);
        webPage.load(link);
    }

    // ---------------------------------------------------------------------------

    function setSystemProps  () {
        var sysInfo = typeof AppFramework.systemInformation !== "undefined" && AppFramework.systemInformation ? AppFramework.systemInformation : ""
        if (!sysInfo) return
        if (Qt.platform.os === "ios" && sysInfo.hasOwnProperty("unixMachine")) {
            if (sysInfo.unixMachine === "iPhone10,3" || sysInfo.unixMachine === "iPhone10,6") {
                app.isIphoneX = true
            }
        } else if (Qt.platform.os === "windows") {
            var kernelVersionPattern = /^6\.1/
            var osVersionPattern = /^7/
            app.isWindows7 = kernelVersionPattern.test(AppFramework.kernelVersion) && osVersionPattern.test(AppFramework.osVersion)
        }
    }

    NetworkRequest {
        id: checkMmpkTags
        responseType: "json"

        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                downloadOfflineMap = response.typeKeywords.indexOf("Published Map") !== -1 && app.isOnline
            }
        }
    }

    Component.onCompleted: {

        /* MATT
        Ontario: https://mcsc.maps.arcgis.com/apps/MapTour/index.html?appid=7521054e318f492eb13be4a2613122c8
        SK & MB: https://mcsc.maps.arcgis.com/apps/MapTour/index.html?appid=a4dcfd2a378241c1aa5895a6dc1aca79
        AB & BC: https://mcsc.maps.arcgis.com/apps/MapTour/index.html?appid=731e08dc237f4394806a33349266e2d0
        Atlantic: https://mcsc.maps.arcgis.com/apps/MapTour/index.html?appid=cc072692f425410c966685d237f9180d
        Quebec: https://mcsc.maps.arcgis.com/apps/MapTour/index.html?appid=e5aa25e3992448b0b897a3480fcf3104
        Territories: https://mcsc.maps.arcgis.com/apps/MapTour/index.html?appid=f1cdb4c1afee4f9fb1a0317be56e78f2
        */

//        tourManager.clearCache()
//        urlParameters = {index: 9999, appid: "7521054e318f492eb13be4a2613122c8"}

        //urlParameters = null
        useOfflineMap = !isOnline && mmpkManager.hasOfflineMap()
        if (offlineMMPKID > "" && !useOfflineMap) {
            checkMmpkTags.url =  "%1/sharing/rest/content/items/%2?f=json".arg(portal.url).arg(offlineMMPKID)
            checkMmpkTags.send()
        }
        setSystemProps ()
    }

    onOpenUrl: {
        var urlInfo = AppFramework.urlInfo(url)
        urlParameters = urlInfo.queryParameters
    }

    // ---------------------------------------------------------------------------

    function units(num) {
        return num? num*AppFramework.displayScaleFactor : num
    }

    function prettyDate (val) {
        var date = null;

        if (typeof val == "number") {
            date = new Date(val);
        } else {
            date = new Date((val || "").replace(/-/g, "/").replace(/[TZ]/g, " "));
        }

        if (isNaN(date.getTime())) {
            date = new Date(val || "");
        }

        var diff = (((new Date()).getTime() - date.getTime()) / 1000),
                day_diff = Math.floor(diff / 86400);

        if (isNaN(day_diff) || day_diff < 0) {
            return;
        }

        return (day_diff === 0 && (diff < 10 && "just now" || diff < 20 && "10 secs ago" || diff < 30 && "20 secs ago" || diff < 40 && "30 secs ago" || diff < 90 && "1 minute ago" || diff < 3600 && Math.floor(diff / 60) + " minutes ago" || diff < 7200 && "1 hour ago" || diff < 86400 && Math.floor(diff / 3600) + " hours ago") || day_diff == 1 && "Yesterday" || day_diff < 7 && day_diff + " days ago" || day_diff < 31 && Math.ceil(day_diff / 7) + " weeks ago" || day_diff < 365 && Math.ceil(day_diff / 30) + " months ago" || "more than a year ago");

    }

    // ---------------------------------------------------------------------------

}
