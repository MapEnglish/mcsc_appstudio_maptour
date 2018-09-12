import QtQuick 2.3

import "components" as Components

Item {

    id: root

    property bool isOnline: true

    property string appId: ""
    property color primaryColor: "steelBlue"
    property real baseTextSize: app.baseFontSize
    property string referer: ""

    // portal
    property url portalUrl: "https://www.arcgis.com"
    property string organizationId: ""
    property string token: ""

    // tours
    property int tourPageSize: 25
    property string tourOrderBy: "created"
    property string tourSortOrder: "desc"
    property string tourSortField: "modified"
    property string tourItemTypes: ""
    property string tourQueryString: ""

    // rest url formats
    readonly property string searchUrlFormat: "%1/sharing/rest/search?%2"
    readonly property string thumbnailUrlFormat: "%1/sharing/rest/content/items/%2/info/%3"
    readonly property string itemDataUrlFormat: "%1/sharing/rest/content/items/%2/data?%3"

    //---------------------------------------------------------------------------------

    anchors.fill: parent

    property alias networkCacheManager: networkCacheManager
    Components.NetworkCacheManager {
        id: networkCacheManager
        referer: root.referer
        subFolder: appId
    }

    QtObject {
        id: requestType

        property int tours: 0
        property int tourItems: 1
        property int webMapData: 2
        property int featureSetJson: 3
    }

    signal requestSuccess (var results, int type, int errorCode, string errorMsg)
    signal requestError (int type, int errorCode, string errorMsg)

    onRequestSuccess: {
        switch (type) {
        case (requestType.tours):
            tours.errorCode = errorCode
            tours.errorMsg = errorMsg
            tours.toursQueryResults = results
            tours.isRefreshing = false
            break
        case (requestType.tourItems):
            tourItems.errorCode = errorCode
            tourItems.errorMsg = errorMsg
            results.tourId = tourItems.tourId
            tourItems.tourItemsQueryResults = results
            break
        case (requestType.webMapData):
            webMapData.errorCode = errorCode
            webMapData.errorMsg = errorMsg
            webMapData.webMapDataQueryResults = results
            break
        case (requestType.featureSetJson):
            featureSetJson.errorCode = errorCode
            featureSetJson.errorMsg = errorMsg
            featureSetJson.featureSetJsonQueryResults = results
        }
    }

    onRequestError: {
        switch (type) {
        case (requestType.tours):
            tours.errorCode = errorCode
            tours.errorMsg = errorMsg
            tours.toursQueryResults = undefined
            tours.isRefreshing = false
            break
        case (requestType.tourItems):
            tourItems.errorCode = errorCode
            tourItems.errorMsg = errorMsg
            tourItems.tourItemsQueryResults = undefined
            break
        case (requestType.webMapData):
            webMapData.errorCode = errorCode
            webMapData.errorMsg = errorMsg
            webMapData.webMapDataQueryResults = undefined
            break
        case (requestType.featureSetJson):
            featureSetJson.errorCode = errorCode
            featureSetJson.errorMsg = errorMsg
            featureSetJson.featureSetJsonQueryResults = undefined
        }
    }

    //---------------------------------------------------------------------------------

    property alias tours: tours
    ListModel {
        id: tours

        property var toursQueryResults
        property int errorCode
        property string errorMsg
        property bool isRefreshing: false

        signal toursUpdated ()
        signal cacheCleared ()

        onToursQueryResultsChanged: {
            _updateModel()
        }

        function refresh () {
            tours.isRefreshing = true
            var queryParams = getQueryParameters(),
                targetUrl = getTourQueryUrl(queryParams, root.searchUrlFormat)
            queryTours (targetUrl)
        }

        function reset () {
            var queryParams = getQueryParameters(),
                targetUrl = getTourQueryUrl(queryParams, root.searchUrlFormat)
            networkCacheManager.clearCache(targetUrl)
            refresh()
        }

        function getQueryParameters () {
            console.log(root.organizationId)
            return {
                //"token": root.token,
                "sortField": root.tourSortField,
                "sortOrder": root.tourSortOrder,
                "orderBy": root.tourOrderBy,
                "num": root.tourPageSize,
                "f": "pjson",
                "q": getTourQueryString (root.tourQueryString,
                                         root.tourItemTypes,
                                         root.organizationId)
            }
        }

        function queryTours (targetUrl)  {
            requestJson (targetUrl, {}, requestType.tours)
        }

        function getTourQueryUrl (parameters, format) {
            var urlSuffix = root.constructUrlSuffix(parameters)
            return format.arg(portalUrl).arg(urlSuffix)
        }

        function getTourQueryString (str, itemTypes, organizationId) {
            var query = itemTypes
            if (organizationId) query += " orgid:%1".arg(organizationId)
            if (str) query += " %1".arg(str)
            return query
        }

        function getItemById (id) {
            for (var i=0; i<tours.count; i++) {
                var item = tours.get(i)
                if (item.id === id) {
                    return item
                }
            }
        }

        function clearCache () {
            var queryParams = {
                //"token": root.token,
                "sortField": root.tourSortField,
                "sortOrder": root.tourSortOrder,
                "orderBy": root.tourOrderBy,
                "num": root.tourPageSize,
                "f": "pjson",
                "q": getTourQueryString (root.tourQueryString,
                                         root.tourItemTypes,
                                         root.organizationId)
            }
            networkCacheManager.clearCache(getTourQueryUrl(queryParams, root.searchUrlFormat))
            for (var i=0; i<count; i++) {
                networkCacheManager.clearCache(get(i).thumbnailUrl)
                if (i === count-1) cacheCleared()
            }
        }

        function _updateModel () {
            clear()
            if (typeof toursQueryResults !== "undefined" && errorCode === 0) {
                //console.log("########################", JSON.stringify(toursQueryResults))
                for (var i=0; i<toursQueryResults["results"].length; i++) {
                    if (!isOnline && !networkCacheManager.fileFolder.fileExists("%1.json".arg(toursQueryResults["results"][i].id))) {
                        continue
                    }
                    _fillInMissingKeys(toursQueryResults["results"][i])
                    _getThumbnailUrl(toursQueryResults["results"][i])
                    root.replaceValues(toursQueryResults["results"][i], null, "")
                    append(toursQueryResults["results"][i])
                }
            }
            toursUpdated()
        }

        function _getThumbnailUrl (obj) {
            if (obj.thumbnail) {
                obj.thumbnailUrl = root.thumbnailUrlFormat.arg(root.portalUrl).arg(obj.id).arg(obj.thumbnail)
            }
        }

        function _fillInMissingKeys (obj) {
            var keyList = ["thumbnail", "thumbnailUrl"]
            for (var i=0; i<keyList.length; i++) {
                if (!obj.hasOwnProperty([keyList[i]])) {
                    obj[keyList[i]] = ""
                }
            }
        }
    }

    //---------------------------------------------------------------------------------

    property alias tourItems: tourItems
    QtObject {
        id: tourItems

        property var tourItemsQueryResults
        property int errorCode
        property string errorMsg
        property string tourId: ""
        property var tourData

        signal tourItemsUpdated ()

        onTourItemsQueryResultsChanged: {
            if (typeof tourItemsQueryResults !== "undefined") {
                tourItemsUpdated()
            }
        }

        function load (tour) {
            //console.log("###### TOUR ID ######", tour.id)
            tourData = tour
            tourId = tour.id
            getTourItems(tour.id)
        }

        function getTourItems (itemId) {
            var params = {
                "f": "pjson",
            },
            targetUrl = getTourItemUrl(itemId, params),
            obj = {}

            requestJson (targetUrl, obj, requestType.tourItems)
        }

        function getTourItemUrl (itemId, params) {
            var suffix = root.constructUrlSuffix(params)
            return root.itemDataUrlFormat.arg(root.portalUrl).arg(itemId).arg(suffix)
        }
    }

    //---------------------------------------------------------------------------------

    property alias webMapData: webMapData
    QtObject {
        id: webMapData

        property var webMapDataQueryResults
        property int errorCode
        property string errorMsg
        property string webmapId: ""

        signal webMapDataUpdated ()

        onWebMapDataQueryResultsChanged: {
            if (typeof webMapDataQueryResults !== "undefined") {
                webMapDataUpdated()
            }
        }

        function load (webMapId) {
            webMapData.webmapId = webMapId
            getWebMapData(webMapId)
        }

        function getWebMapData (webMapId) {
            var params = {
                "f": "pjson",
            },
            targetUrl = getWebMapDataUrl(webMapId, params),
            obj = {}

            requestJson (targetUrl, obj, requestType.webMapData)
        }

        function getWebMapDataUrl (itemId, params) {
            var suffix = root.constructUrlSuffix(params)
            return root.itemDataUrlFormat.arg(root.portalUrl).arg(itemId).arg(suffix)
        }
    }

    //---------------------------------------------------------------------------------

    property alias featureSetJson: featureSetJson
    QtObject {
        id: featureSetJson

        property var featureSetJsonQueryResults
        property int errorCode
        property string errorMsg
        property string featureServiceUrl: ""
        property var outSpatialReference: undefined
        property var sortOrder: undefined

        signal featureSetJsonUpdated ()

        onFeatureSetJsonQueryResultsChanged: {
            if (typeof featureSetJsonQueryResults !== "undefined") {
                featureSetJsonUpdated()
            }
        }

        function getFeatureSetJson (outSR) {
            var params = {
                "f": "pjson",
                "returnGeometry": "true",
                "where": "1=1",
                "outFields": "*",
            },
            targetUrl = getFeatureSetJsonUrl(params),
            obj = {"outSR": outSR}
            if (typeof featureSetJson.sortOrder !== "undefined") params["orderByFields"] = featureSetJson.sortOrder
            if (typeof outSpatialReference !== "undefined") params["outSpatialReference"] = outSpatialReference

            requestJson (targetUrl, obj, requestType.featureSetJson)
        }

        function getFeatureSetJsonUrl (params) {
            var suffix = root.constructUrlSuffix(params)
            return "%1/query?%2".arg(featureServiceUrl).arg(suffix)
        }
    }

    //---------------------------------------------------------------------------------

    Connections {
        target: app
        onIsOnlineChanged: {
            root.isOnline = app.isOnline
        }
    }

    //---------------------------------------------------------------------------------

    property alias progressDialog: progressDialog
    Components.ProgressDialog {
        id: progressDialog

        signal completed ()

        isDebug: false
        visible: false

        progressBarColor: root.primaryColor
        progressBarBorderColor: Qt.darker(root.primaryColor)
        descriptionTextSize: app.baseFontSize
        buttonTextSize: app.baseFontSize
        descriptionTextColor: Qt.darker(root.primaryColor)
        titleText: ""
        titleTextSize: app.subtitleFontSize

        Component.onCompleted: {
            rightButton.backgroundColor = Qt.darker(root.primaryColor)
            rightButton.textColor = "white"
            rightButton.buttonBorderColor = Qt.darker(root.primaryColor)
            leftButton.backgroundColor = "white"
            leftButton.textColor = Qt.darker(root.primaryColor)
            leftButton.buttonBorderColor = Qt.darker(root.primaryColor)
        }

        onProgressValueChanged: {
            if (progressValue >= 1) {
                hideDialog.start()
            }
        }

        onLeftButtonClicked:{
            close()
        }

        onRightButtonClicked: {
            leftButtonText = qsTr("Ok")
            rightButton.visible = false
            progressBar.visible = true
            root.clearCache(function (initialSize, currentSize, progress, filesNotRemoved) {
                progressValue = progress/100
                progressDialog.descriptionText = "%1 %2% %3".arg(qsTr("Clearing cache...")).arg(progress).arg(qsTr("Complete"))
                if (progressValue === 1) {
                    app.useOfflineMap = false
                    app.mmpkManager.hasOfflineMap()
                }
            })
        }

        Timer {
            id: hideDialog
            interval: 500
            onTriggered: {
                progressDialog.close()
                progressDialog.completed()
            }
        }

        function show () {
            init ()
            open ()
        }

        function init () {
            leftButtonText = qsTr("No")
            rightButtonText = qsTr("Yes")
            rightButton.visible = true
            leftButton.visible = true
            progressBar.visible = false
            //descriptionText = qsTr("Refreshing your app will remove all cached map tour data and images from your device. Are you sure you want to proceed?")
            descriptionText = qsTr("Clear all offline map tours?")
            progressValue = 0
        }
    }

    //---------------------------------------------------------------------------------

    function constructUrlSuffix (obj) {
        var urlSuffix = ""
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
                if (obj[key]) {
                    urlSuffix += "%1=%2&".arg(key).arg(obj[key])
                }
            }
        }
        return urlSuffix.slice(0, -1)
    }

    //---------------------------------------------------------------------------------

    function requestJson (url, obj, type) {
        if (root.token) obj.token = root.token
        networkCacheManager.cacheJson(url, obj, null, function (errorCode, errorMsg) {
            if (errorCode === 0) {
                var cacheName = Qt.md5(url),
                    temp = networkCacheManager.readLocalJson(cacheName)
                    if (temp) {
                        var results = JSON.parse(temp)
                        requestSuccess(results, type, errorCode, errorMsg)
                    } else {
                        requestError(type, errorCode, errorMsg)
                    }
            } else {
                requestError(type, errorCode, errorMsg)
            }
        })
    }

    function hasDataInCache () {
        return networkCacheManager.fileFolder.fileNames().length > 0
    }

    function hasTourDataInCache () {
        return toursInCache().length > 0
    }

    function getDateCached (filename) {
        if (networkCacheManager.fileFolder.fileExists(filename)) {
            //var content = networkCacheManager.fileFolder.readJsonFile(filename)
            return networkCacheManager.fileFolder.fileInfo(filename).lastModified
        }
    }

    function toursInCache () {
        var tourIds = [],
            fileNames = networkCacheManager.fileFolder.fileNames()
        for (var i=0; i<fileNames.length; i++) {
            if (fileNames[i].indexOf(".json") !== -1) {
                tourIds.push(fileNames[i].replace(".json", ""))
            }
        }
        return tourIds
    }

    function clearCache (callback) {
        var files = networkCacheManager.fileFolder.fileNames(),
            initialSize = files.length,
            currentSize = initialSize,
            filesNotRemoved = []

        for (var i=0; i<initialSize; i++) {
            var progress = (((i+1)/initialSize) * 100).toFixed(),
                fileName = files[i]

            if (!networkCacheManager.fileFolder.removeFile(fileName)) {
                filesNotRemoved.push(files[i])
            }
            currentSize = networkCacheManager.fileFolder.fileNames().length
            if (callback) callback(initialSize, currentSize, progress, filesNotRemoved)
        }
    }

    //---------------------------------------------------------------------------------

    function replaceValues (obj, toReplace, replacement) {
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
                if (obj[key] === toReplace) {
                    obj[key] = replacement
                }
            }
        }
    }

    function units(num) {
        return num? num*AppFramework.displayScaleFactor : num
    }
}
