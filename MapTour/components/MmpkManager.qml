import QtQuick 2.5
import QtQuick.Controls 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    id: mmpkManager
    property string itemId: ""
    property string rootUrl: "http://www.arcgis.com/sharing/rest/content/items/"
    property string itemName: itemId > "" ? "%1.mmpk".arg(itemId) : ""
    property url fileUrl: [fileFolder.url, itemName].join("/")
    property string subFolder: "MapTour"
    property int loadStatus: -1 //unknow = -1, loaded = 0, loading = 1, failed to load = 2
    property bool offlineMapExist: hasOfflineMap()

    FileFolder{
        id: fileFolder
        readonly property url storageBasePath: AppFramework.userHomeFolder.fileUrl("ArcGIS/AppStudio/cache")
        property url storagePath: subFolder && subFolder>"" ? storageBasePath + "/" + subFolder : storageBasePath
        url: storagePath
        Component.onCompleted: {
            if(!fileFolder.exists){
                fileFolder.makeFolder(storagePath);
            }
            if (!fileFolder.fileExists(".nomedia") && Qt.platform.os === "android") {
                fileFolder.writeFile(".nomedia", "")
            }
        }
    }

    Component.onCompleted: {
        var oldMmpkExists = fileFolder.fileExists(itemId);
        if (oldMmpkExists) {
            fileFolder.renameFile(itemId, "%1.mmpk".arg(itemId))
        }
        hasOfflineMap()
    }

    function downloadOfflineMap(callback){
        if(itemId>""){
            var component = typeNetworkRequestComponent;
            var networkRequest = component.createObject(parent);
            var url = rootUrl+itemId+"?f=json";
            //console.log("url::", url)
            networkRequest.checkType(url, callback);
        }
    }

    function updateOfflineMap(callback){
        if(offlineMapExist){
            downloadOfflineMap(callback);
        }
    }

    function hasOfflineMap(){
        offlineMapExist = fileFolder.fileExists(itemName)
        return offlineMapExist;
    }

    function deleteOfflineMap(){
        if(fileFolder.fileExists("~"+itemName))fileFolder.removeFile("~"+itemName);
        if(fileFolder.fileExists(itemName))fileFolder.removeFile(itemName);
        hasOfflineMap();
    }

    Component{
        id: typeNetworkRequestComponent
        NetworkRequest{
            id: typeNetworkRequest

            property var callback

            method: "GET"
            ignoreSslErrors: true

            onReadyStateChanged: {
                if (readyState === NetworkRequest.DONE ){
                    if(errorCode != 0){
                        loadStatus = 2;
                        //console.log(errorCode, errorText);
                    } else {
                        //console.log("Type Response", responseText)
                        var root = JSON.parse(responseText);
                        if(root.type == "Mobile Map Package"){
                            loadStatus = 1;
                            var component = networkRequestComponent;
                            var networkRequest = component.createObject(parent);
                            var url = rootUrl+itemId+"/data";
                            var path = [fileFolder.path, "~"+itemName].join("/");
                            networkRequest.downloadFile("~"+itemName, url, path, typeNetworkRequest.callback);
                        } else {
                            loadStatus = 2;
                        }
                    }
                    if (callback) callback ()
                }
            }

            function checkType(url, callback){
                typeNetworkRequest.url = url;
                typeNetworkRequest.callback = callback;
                typeNetworkRequest.send();
                loadStatus = 1;
            }
        }
    }

    Component{
        id: networkRequestComponent
        NetworkRequest{
            id: networkRequest

            property var name;
            property var callback;

            method: "GET"
            ignoreSslErrors: true

            onReadyStateChanged: {
                if (readyState === NetworkRequest.DONE ){
                    if(errorCode != 0){
                        fileFolder.removeFile(networkRequest.name);
                        loadStatus = 2;
                        //console.log(errorCode, errorText);
                    } else {
                        loadStatus = 0;
                        if(hasOfflineMap()) fileFolder.removeFile(itemName);
                        fileFolder.renameFile(name, itemName);
                        hasOfflineMap();
                        callback();
                    }
                }
            }

            function downloadFile(name, url, path, callback){
                networkRequest.name = name;
                networkRequest.url = url;
                networkRequest.responsePath = path;
                networkRequest.callback = callback;
                networkRequest.send();
                loadStatus = 1;
            }
        }
    }
}
