import QtQuick 2.5

import Esri.ArcGISRuntime 100.2


Item {

    property MapView mapView
    property var webMapInfo
    property QtObject strings

    signal graphicsCreationCompleted ()

    Connections {
        target: mapView.map

        onLoadStatusChanged: {
            switch (mapView.map.loadStatus) {
            case Enums.LoadStatusLoaded:
                if (!mapView.tourGraphics.graphics.count)  {
                    getTourData ()
                }
            }
        }
    }

    Connections {
        target: app.tourManager.featureSetJson

        onFeatureSetJsonUpdated: {
            if (app.tourManager.featureSetJson.errorCode !== 0) {
                tourError(qsTr("Unable to get tour points information from map"));
            } else {
                createGraphics(app.tourManager.featureSetJson.featureSetJsonQueryResults)
            }
        }
    }

    onGraphicsCreationCompleted: {
        //mapView.graphicsOverlays = mapView.tourGraphics
        //console.log("################", mapView.tourGraphics.renderer)
    }

    //------------------------------------------------------------------------------------------------------

    Connections {
        target: app.locationManager

        onPositionChanged: {
            if (app.canUseDistance) {
                var dist = getDistanceBetweenTwoPoints(app.locationManager.lastObtainedDeviceLatitude,
                                                       app.locationManager.lastObtainedDeviceLongitude,
                                                       app.locationManager.latitude,
                                                       app.locationManager.longitude)
                if (dist > app.distanceThresholdInKm) {
                    app.locationManager.lastObtainedDeviceLatitude = app.locationManager.latitude
                    app.locationManager.lastObtainedDeviceLongitude = app.locationManager.longitude
                    busyIndicatorTimer.start()
                    updateDistancesOfTourItems()
                    sortButton.activated(sortButton.currentIndex)
                }
            }
        }
    }

    function updateDistancesOfTourItems() {
        //console.log("COUNT OF ITEMS", JSON.stringify(tourItemsListModel.get(0)))
        if (tourItemsListModel.count) {
            for (var i=0; i<tourItemsListModel.count; i++) {
                tourItemsListModel.setProperty(i, "distance", getDistanceOfTourItem(tourItemsListModel.get(i)).distance)
            }
        }
    }

    //------------------------------------------------------------------------------------------------------

    function getTourData () {
        var layerJson = findOperationalLayerJson(tourLayerId),
                layerInfo = getLayerInfo(layerJson)

        if (!layerJson)  return tourError (strings.kNoMapTourLayer)

        hideTourLayer (tourLayerId, layerInfo)

        if (layerJson.featureCollection) {
            console.log("Feature collection")
            createGraphics(layerJson.featureCollection.layers[0].featureSet)
        } else {
            console.log("Feature service")
            getFeatureSetJson (layerInfo)
            //createGraphics() // createGraphcis is called after the JSON has been gotten in the connection to app.tourManager.featureSetJson below
        }
    }

    function createGraphics (featureSetJson) {
        mapView.clearItems()
        for (var i=0; i<featureSetJson.features.length; i++) {
            var feature = featureSetJson.features[i]

            if (!(feature.geometry && feature.geometry.x && feature.geometry.y)) {
                continue
            }

            normalizeAttributes(feature, i)

            if (feature.attributes.defaultOrder === -1) continue
           // var sr = ArcGISRuntimeEnvironment.createObject("SpatialReference", {wkid: feature.geometry.spatialReference.wkid}),

               var sr = mapView.spatialReference,
               point = ArcGISRuntimeEnvironment.createObject("Point", {x: feature.geometry.x, y: feature.geometry.y,
                                                                       spatialReference: sr}),
               graphic = ArcGISRuntimeEnvironment.createObject("Graphic", {geometry: point})

            graphic.attributes.attributesJson = feature.attributes

            feature.attributes.geometry = feature.geometry

            mapView.appendGraphic(graphic, feature.attributes)

            //console.log(JSON.stringify(graphic.attributes.attributesJson))
            //console.log("#################")
            //console.log(JSON.stringify(feature.attributes))
            if (i === featureSetJson.features.length - 1) {
                graphicsCreationCompleted()
            }
        }
    }

    //------------------------------------------------------------------------------------------------------

    function normalizeAttributes (feature, idx) {
        normalizeObjectID(feature, idx)
        normalizeDescription(feature)
        normalizeColor(feature)
        normalizeName(feature)
        normalizeThumbUrl(feature)
        normalizePicUrl(feature)

        addVideoAttribute(feature)
        addSortAttributes(feature, idx)
    }

    function addSortAttributes (graphic, idx) {
        //graphic["name"] = graphic.attributes.name;
        graphic.attributes["defaultOrder"] = -1;
        graphic.attributes["currentOrder"] = idx + 1
        graphic.attributes["distance"] = 0
        graphic.attributes["location"] = ""

        if (app.customSort) {
            graphic.attributes.defaultOrder = graphic.attributes[app.customSortField.toString()];
        } else {
            if (app.tourOrderArray.length > 0) {
                if (app.tourOrderArray.indexOf(graphic.attributes.objectid) !== -1) {
                    graphic.attributes.defaultOrder = app.tourOrderArray.indexOf(graphic.attributes.objectid);
                }
            }
        }

        if (app.canUseDistance) {
            var d = getDistanceOfTourItem(graphic)
            graphic.attributes.distance = d.distance
            graphic.attributes.location = d.location
        }
        return graphic
    }

    function getDistanceOfTourItem(tourItem) {
        if (!tourItem.geometry.spatialReference) {
            tourItem.geometry.spatialReference = app.tourManager.webMapData.webMapDataQueryResults.spatialReference
        }
        var obj = {},
            sr = ArcGISRuntimeEnvironment.createObject("SpatialReference", {wkid: tourItem.geometry.spatialReference.wkid}),
            point = ArcGISRuntimeEnvironment.createObject("Point", {x: tourItem.geometry.x, y: tourItem.geometry.y, spatialReference: sr}),
            itemCoord = CoordinateFormatter.toLatitudeLongitude(point, Enums.LatitudeLongitudeFormatDecimalDegrees, 3),
            itemCoordArr = itemCoord.split(" "),
            itemLat = runtimeDegreeToFloat(itemCoordArr[0]),
            itemLon = runtimeDegreeToFloat(itemCoordArr[1])

        var distance = getDistanceBetweenTwoPoints(itemLat, itemLon,
                                               app.locationManager.latitude,
                                               app.locationManager.longitude);
        if (distance) {
            distance = app.distanceUnit === "km" ? (distance).toFixed(1) : ((distance * 0.621371).toFixed(1))
        } else {
            distance = 0
        }

        obj.distance = distance
        obj.location = itemCoord

        return obj
    }

    function getDistanceBetweenTwoPoints(lat1, lon1, lat2, lon2) {
        // Haversine formula for getting the great-circle distance between two points
        var r = 6371,
            dLat = (lat2 - lat1) * (Math.PI/180),
            dLon = (lon2 - lon1) * (Math.PI/180),
               a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                   Math.cos(lat1 * (Math.PI/180)) *
                   Math.cos(lat2 * (Math.PI/180)) *
                   Math.sin(dLon/2) * Math.sin(dLon/2),
               c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a)),
               d = r * c

        return d
    }

    function runtimeDegreeToFloat(runtimeDegree) {
        var negativeDirectionStrings = ["S", "W"],
                sign = ""
        for (var i=0; i<negativeDirectionStrings.length; i++) {
            if (runtimeDegree.indexOf(negativeDirectionStrings[i]) !== -1) {
                sign = "-"
            }
        }
        runtimeDegree = "%1%2".arg(sign).arg(runtimeDegree.replace(/[^0-9\.]/g, ""))

        return Number(runtimeDegree)
    }

    function addVideoAttribute (graphic) {
        graphic.attributes.is_video = false
        if (graphic.attributes.IS_VIDEO || graphic.attributes.is_video ||
            graphic.attributes.pic_url.indexOf("www.youtube.com") > 1 ||
            graphic.attributes.pic_url.indexOf("vimeo.com") > 1 ) {

            graphic.attributes.is_video = true
        }
    }

    function normalizePicUrl (graphic) {
        if (graphic.attributes.Picture || graphic.attributes.PIC_URL ||
            graphic.attributes.pic_url || app.imageField) {

            graphic.attributes.pic_url = graphic.attributes.Picture || graphic.attributes.PIC_URL ||
                                         graphic.attributes.pic_url || graphic.attributes[app.imageField]
        }

        if (!graphic.attributes.pic_url || graphic.attributes.pic_url.length < 1) {
             graphic.attributes.pic_url = graphic.attributes.thumb_url || "images/placeholder.jpg"
        }

        graphic.attributes.pic_url = addHttp(graphic.attributes.pic_url);
        app.tourManager.networkCacheManager.cache(graphic.attributes.pic_url, "", null)
    }

    function normalizeThumbUrl (graphic) {
        if (app.thumbnailField || graphic.attributes.Thumb ||
            graphic.attributes.Thumb_URL || graphic.attributes.THUMB_URL ||
            graphic.attributes.Thumbnail || graphic.attributes.thumb_url) {

            graphic.attributes.thumb_url = graphic.attributes[app.thumbnailField] || graphic.attributes.Thumb ||
                                           graphic.attributes.THUMB_URL || graphic.attributes.Thumb_URL ||
                                           graphic.attributes.Thumbnail || graphic.attributes.thumb_url
        }

        if (!graphic.attributes.thumb_url || graphic.attributes.thumb_url.length < 1) {
             graphic.attributes.thumb_url = graphic.attributes.pic_url || "../images/item_thumbnail.jpeg"
        }

        graphic.attributes.thumb_url = addHttp(graphic.attributes.thumb_url)
        app.tourManager.networkCacheManager.cache(graphic.attributes.thumb_url, "", null)
    }

    function normalizeName (graphic) {
        if (graphic.attributes.Name || graphic.attributes.NAME ||
            graphic.attributes.name || app.titleField) {

            graphic.attributes.name = graphic.attributes.Name ||
                                      graphic.attributes.NAME ||
                                      graphic.attributes.name ||
                                      graphic.attributes[app.titleField]
        }
    }

    function normalizeColor (graphic) {
        if (graphic.attributes.Color || graphic.attributes.Icon_color ||
            graphic.attributes.ICON_COLOR || app.iconColorField) {

            graphic.attributes.icon_color = graphic.attributes.Color ||
                                            graphic.attributes.ICON_COLOR ||
                                            graphic.attributes.Icon_color ||
                                            graphic.attributes[app.iconColorField]
        }
    }

    function normalizeDescription (graphic) {
        if (graphic.attributes.Description || graphic.attributes.DESCRIPTION ||
            graphic.attributes.description || graphic.attributes.Caption  ||
            graphic.attributes.CAPTION || graphic.attributes.caption || app.descField) {

            graphic.attributes.description = graphic.attributes.Description || graphic.attributes.DESCRIPTION ||
                                             graphic.attributes.description || graphic.attributes.Caption ||
                                             graphic.attributes.CAPTION || graphic.attributes.caption ||
                                             graphic.attributes[app.descField]
        }
    }

    //------------------------------------------------------------------------------------------------------

    function normalizeObjectID (graphic, idx) {
        var objectIdKeys = ["OBJECTID", "ObjectID", "ObjectId", "F__OBJECTID", "__OBJECTID", "FID"]
        for (var j=0; j<objectIdKeys.length; j++) {
            if (graphic.attributes.hasOwnProperty(objectIdKeys[j])) {
                if (graphic.attributes[objectIdKeys[j]] || (graphic.attributes[objectIdKeys[j]] === 0)) {
                    graphic.attributes.objectid = graphic.attributes[objectIdKeys[j]] // sometimes, a field with the name objectid doesnt get created, hence added the field name uniqueId below
                    graphic.attributes.uniqueId = graphic.attributes[objectIdKeys[j]]
                    break
                }
            }
        }

        if (typeof graphic.attributes.objectid === "undefined") {
            graphic.attributes.objectid = "GUID-%1".arg(idx)
        }

        if (typeof graphic.attributes.uniqueId === "undefined") {
            graphic.attributes.uniqueId = "GUID-%1".arg(idx)
        }
    }

    function getFeatureSetJson (layerInfo) {
        app.tourManager.featureSetJson.featureServiceUrl = layerInfo.url
        app.tourManager.featureSetJson.outSpatialReference = mapView.map.spatialReference
        if(app.customSort) {
            var orderBy = [];
            orderBy.push({fieldName : app.customSortField.toString(),
                          order: app.customSortOrder == "desc" ? Enums.PortalQuerySortOrderDescending : Enums.PortalQuerySortOrderAscending});
            app.tourManager.featureSetJson.sortOrder = orderBy
        }
        app.tourManager.featureSetJson.getFeatureSetJson(mapView.map.spatialReference.wkid.toString())
    }

    function getFeatureLayer (layerInfo, tourLayerId) {
        var layers = mapView.map.operationalLayers,
            featureLayer = null

        for (var i=layers.count; i--;) {
            var layer = layers.get(i)
            if (!layer) continue
            if (layer.name === layerInfo.name ||
                layer.name.indexOf(layerInfo.id) > -1 ||
                layer.name.indexOf(tourLayerId) > -1 ||
                tourLayerId.indexOf(layer.name) > -1 ||
                layer.name.indexOf("MAP_TOUR") > -1 ||
                layer.name.indexOf("maptour") > -1) {

                if (layer.layerType === Enums.LayerTypeFeatureLayer ||
                    layer.layerType === Enums.LayerTypeArcGISMapImageLayer ||
                    layer.layerType === Enums.LayerTypeFeatureCollectionLayer) {
                    featureLayer = layer
                }
            }
        }
        return featureLayer
    }

    function hideTourLayer (tourLayerId, layerInfo) {
        if (app.isOnline) {
            var featureLayer = getFeatureLayer (layerInfo, tourLayerId)
            if (featureLayer) featureLayer.visible = false
        }
    }

    function getLayerInfo (layerJson) {
        var info = {"name": "", "url": "", "id":""}
        if (!layerJson) {
            tourError (strings.kNoMapTourLayer)
        } else {
            info.name = layerJson.title || ""
            info.url = layerJson.url || ""
            info.id = layerJson.id || ""
        }
        return info
    }

    function findOperationalLayerJson(slug) {
        var json = null
        if (slug && slug.length > 0) {
            for (var index = 0; index < webMapInfo.operationalLayers.length; index++) {
                if (webMapInfo.operationalLayers[index].title.indexOf(slug) > -1 ||
                    slug === webMapInfo.operationalLayers[index].id ||
                    webMapInfo.operationalLayers[index].url&&webMapInfo.operationalLayers[index].url.indexOf(slug)>-1 ||
                    webMapInfo.operationalLayers[index].title.toLowerCase().indexOf(slug)>-1 ||
                    webMapInfo.operationalLayers[index].id.toLowerCase().indexOf("maptour")>-1) {
                        json  = webMapInfo.operationalLayers[index]
                        break
                }
            }
        } else {
            if (webMapInfo.operationalLayers.length === 1 &&
                webMapInfo.operationalLayers[0].title.toLowerCase().indexOf("maptour")>-1 ||
                webMapInfo.operationalLayers[0].id.toLowerCase().indexOf("maptour")>-1) {
                    json = webMapInfo.operationalLayers[0]
            }
        }
        if (!json) {
            if (webMapInfo.operationalLayers.length === 1) {
                json = webMapInfo.operationalLayers[0]
            }
        }
        return json
    }

    function getColorName (colorCode) {
        var colorName = "unknown";
        //console.log("got color: ", colorCode , colorName);
        if (typeof colorCode === "string") {
            switch(colorCode.toLowerCase()) {
                case "r" : colorName = "red"; break;
                case "g" : colorName = "green"; break;
                case "b" : colorName = "blue"; break;
                case "p" : colorName = "purple"; break;
            }
        }
        //console.log("got color: ", colorCode , colorName);
        return colorName;
    }

    function addHttp(url) {
        if(url) {
            var prefix = "//";
            return (url.substr(0, prefix.length) === prefix) ? "http:%1".arg(url) : url;
        } else {
            return url;
        }
    }
}
