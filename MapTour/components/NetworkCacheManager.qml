import QtQuick 2.5
import QtQuick.Controls 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

Item {
    id: networkCacheManager

    property string subFolder: ""
    property string returnType
    property string referer: ""
    property string userAgent: networkCacheManager.buildUserAgent(app)

    property alias fileFolder: fileFolder
    FileFolder{
        id: fileFolder
        readonly property url storageBasePath: AppFramework.userHomeFolder.fileUrl("ArcGIS/AppStudio/cache")
        property url storagePath: subFolder&&subFolder>"" ? storageBasePath + "/" + subFolder : storageBasePath
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

    function cache(url, alias, callback){

        if(!(alias>"")) alias = url;
        var result = url
        var cacheName = Qt.md5(alias)

        //console.log("**** NM:cache :: for  ", url, alias, cacheName)

        if(!fileFolder.fileExists(cacheName)){
            //console.log("**** NM:cache :: no cache, creating new ...");
            var component = networkRequestComponent;
            var networkRequest = component.createObject(parent);
            networkRequest.downloadImage(url, {} , cacheName, fileFolder.path, callback);
        } else{
            var cacheUrl = [fileFolder.url, cacheName].join("/");
            //console.log("####cacheUrl####", cacheUrl);
            result = cacheUrl;
        }

        return result;
    }

    function clearAllCache(){
        var names = fileFolder.fileNames();
        //console.log("**** NM:clearAllCache :: Total files ", names.length)
        for(var i=0; i<names.length; i++){
            var success = fileFolder.removeFile(names[i]);
            //console.log("**** NM:clearAllCache :: Removing file ", names[i], success)
        }
    }

    function isCached(alias){
        var name = Qt.md5(alias);
        //console.log("**** NM: isCached : ", alias)
        return fileFolder.fileExists(name);
    }

    function clearCache(alias){
        var name = Qt.md5(alias);
        return fileFolder.removeFile(name);
    }

    function deleteCacheName(cacheName){
        return fileFolder.removeFile(cacheName);
    }

    function refreshCache(url, alias, callback){
        if(!(alias>"")) alias = url;
        if(isCached(alias)){
            clearCache(alias);
        }
        //console.log("**** NM: url : ", url);
        if(callback) {
            cache(url, alias, callback);
        } else {
            return cache(url,alias);
        }
    }

    function cacheJson(url, obj, alias, callback){
        if(!(alias>"")) alias = url;
        var cacheName = Qt.md5(alias)

        //console.log("**** NM:cache :: for  ", url, alias, cacheName)

        if(!fileFolder.fileExists(cacheName)){
            //console.log("**** NM:cache :: no cache, creating new ...");
            var component = networkRequestComponent;
            var networkRequest = component.createObject(parent);
            networkRequest.requestCompleted.connect(networkRequest.destroy)
            networkRequest.downloadImage(url, obj, cacheName, fileFolder.path, callback);
        } else{
            var cacheUrl = [fileFolder.url, cacheName].join("/");
            //console.log("####cacheUrl####", cacheUrl);
            var result = fileFolder.readTextFile(cacheName);
            callback(0, "");
        }
    }

    function readLocalJson(cacheName){
        var result = fileFolder.readTextFile(cacheName);
        return result;
    }


    Component{
        id: networkRequestComponent
        NetworkRequest{
            id: networkRequest

            property string name;
            property var callback;

            signal requestCompleted ()

            responseType: networkCacheManager.returnType
            onUrlChanged: {
                if (url.toString().indexOf("arcgis.com") === -1) {
                    method = "GET"
                } else {
                    method = "POST"
                }
            }

            headers.referer: networkCacheManager.referer
            headers.referrer: networkCacheManager.referer
            headers.userAgent: networkCacheManager.userAgent

            onReadyStateChanged: {
                var fileName = name;
                if (readyState === NetworkRequest.DONE ){
                    //console.log("####error####", errorCode, networkRequest.url);
                    if(errorCode != 0){
                        fileFolder.removeFile(networkRequest.name);
                        try {
                            callback(errorCode, errorText);
                        } catch (err) {}
                    } else{
                        //console.log("**** NM: download successful", networkRequest.name, fileName);
                        var json = fileFolder.readJsonFile(networkRequest.name);
                        if(json.error!=null){
                            var code = json.error.code;
                            var message = json.error.message;
                            fileFolder.removeFile(networkRequest.name);
                            callback(code, message);
                        } else{
                            if(callback!=null){
                                callback(0, "");
                            }
                        }
                    }
                    requestCompleted()
                }
            }

            function downloadImage(url, obj, name, fileFolderPath, callback) {
                if (url) {
                    networkRequest.url = url;
                    networkRequest.callback = callback;
                    //console.log("####PATH####", name)
                    networkRequest.name = name;
                    networkRequest.responsePath = [fileFolderPath, name].join("/");
                    networkRequest.send(obj);
                }
            }
        }
    }

    function buildUserAgent(app) {
        var userAgent = "";

        function addProduct(name, version, comments) {
            if (!(name > "")) {
                return;
            }

            if (userAgent > "") {
                userAgent += " ";
            }

            name = name.replace(/\s/g, "");
            userAgent += name;

            if (version > "") {
                userAgent += "/" + version.replace(/\s/g, "");
            }

            if (comments) {
                userAgent += " (";

                for (var i = 2; i < arguments.length; i++) {
                    var comment = arguments[i];

                    if (!(comment > "")) {
                        continue;
                    }

                    if (i > 2) {
                        userAgent += "; "
                    }

                    userAgent += arguments[i];
                }

                userAgent += ")";
            }

            return name;
        }

        function addAppInfo(app) {
            var deployment = app.info.value("deployment");
            if (!deployment || typeof deployment !== 'object') {
                deployment = {};
            }

            var appName = deployment.shortcutName > ""
                    ? deployment.shortcutName
                    : app.info.title;

            var udid = app.settings.value("udid", "");

            if (!(udid > "")) {
                udid = AppFramework.createUuidString(2);
                app.settings.setValue("udid", udid);
            }

            appName = addProduct(appName, app.info.version, Qt.locale().name, AppFramework.currentCpuArchitecture, udid)

            return appName;
        }

        if (app) {
            addAppInfo(app);
        } else {
            addProduct(Qt.application.name, Qt.application.version, Qt.locale().name, AppFramework.currentCpuArchitecture, Qt.application.organization);
        }

        addProduct(Qt.platform.os, AppFramework.osVersion, AppFramework.osDisplayName);
        addProduct("AppFramework", AppFramework.version, "Qt " + AppFramework.qtVersion, AppFramework.buildAbi);
        addProduct(AppFramework.kernelType, AppFramework.kernelVersion);

        // console.log("userAgent:", userAgent);

        return userAgent;
    }
}
