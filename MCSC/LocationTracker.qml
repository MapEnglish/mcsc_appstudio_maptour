import QtQuick 2.7
import QtQuick.Layouts 1.1

import QtGraphicalEffects 1.0
import ArcGIS.AppFramework 1.0

import Esri.ArcGISRuntime 100.2
import Esri.ArcGISRuntime.Toolkit.Dialogs 100.2

import ArcGIS.AppFramework.SecureStorage 1.0
import ArcGIS.AppFramework.Authentication 1.0
import "../MapTour/components" as Components

Item {
    id:dude
    visible: AppFramework.network.isOnline

    property var rtCreate: ArcGISRuntimeEnvironment.createObject
    property Portal securityPortal
    property var webPage

    property bool isIPhoneX: false
    property bool isAutoSignIn: true
    property bool isBioAuth: false
    property bool canUseBioAuth: BiometricAuthenticator.supported && BiometricAuthenticator.activated
    property bool isRegistered: false
    property bool isDeleteFeature: false

    property real iconSize: app.units(36)
    property real radius: 0.5 * iconSize
    property var selectedFeature: null
    property var registerPhoneP: null

    SecureStorageHelper{
        id: secureStorage
    }

    //MATT
    Component {
        id:registerPhonePage

        RegisterPhonePage{

        }
    }

    function registerPhone(){
        var component = phoneWebPageComponent;
        var webPage = component.createObject(app);
        webPage.load("https://mcsctwilio.azurewebsites.net/verification");
    }

    function updateLocation(){
       console.log(mapView.map.operationalLayers.count /*get(0).name*/)

       var phoneNumber = secureStorage.getContent("verifiedPhoneNumber")
       if(mapView.map.operationalLayers.count < 2)
       {
        featureTable.credential = securityPortal.credential

        console.log("PHONE NUMBER: " + phoneNumber)

        featureTable.definitionExpression = "PhoneNumber = '" + phoneNumber + "'"
        //featureTable.populateFromService(null,true,"*")
        mapView.map.operationalLayers.append(featureLayer)
       }
       else
       {
          queryFeatures()
       }




    }

    function queryFeatures(){
        var phoneNumber = secureStorage.getContent("verifiedPhoneNumber")
        console.log(phoneNumber)
        var queryParameters = rtCreate("QueryParameters", {whereClause:"PhoneNumber = '" + phoneNumber + "'" })//"PhoneNumber = '" + phoneNumber + "'"  "1=1"
        featureTable.queryFeatures(queryParameters);
        //featureLayer.selectFeaturesWithQuery(queryParameters,Enums.SelectionModeNew)
    }

    Credential{
        id:credential
        username: "esrica_hub"
        password: "16demouc"
    }
    FeatureLayer {
        id: featureLayer

        selectionColor: "cyan"
        selectionWidth: 3

        onLoadStatusChanged: {
            console.log("LOADED")
            queryFeatures()
        }

        // signal handler for selecting features
        onSelectFeaturesStatusChanged: {
            //console.log("SELECTED FEATURE")
            if (selectFeaturesStatus === Enums.TaskStatusCompleted) {
                if (!selectFeaturesResult.iterator.hasNext)
                    return;

                selectedFeature = selectFeaturesResult.iterator.next();
                console.log("SELECTED FEATURE")
                //selectedFeature.onLoadStatusChanged.connect(doUpdateGeometry);
                //selectedFeature.load();

                //dudeupdateFeature(selectedFeature)

            }
        }

        // declare as child of feature layer, as featureTable is the default property
        ServiceFeatureTable {
            id: featureTable
            url: app.info.properties.mcscLocationTrackerFeatureService
            //url: "https://services.arcgis.com/TUacvp5ehCmnEQRb/arcgis/rest/services/SMS_Recipients/FeatureServer/0"
            credential: credential
            // url: "http://sampleserver6.arcgisonline.com/arcgis/rest/services/DamageAssessment/FeatureServer/0"
            // make sure edits are successfully applied to the service
            onApplyEditsStatusChanged: {
                if (applyEditsStatus === Enums.TaskStatusCompleted) {
                    console.log("successfully added feature");
                }
            }

            // signal handler for the asynchronous addFeature method
            onAddFeatureStatusChanged: {
                console.log("ADD FEATURE " + addFeatureStatus)
                if (addFeatureStatus === Enums.TaskStatusCompleted) {
                    // apply the edits to the service
                    featureTable.applyEdits();
                }
            }

            onQueryFeatureCountStatusChanged: {
                if(queryFeatureCountStatus === Enums.TaskStatusCompleted)
                {
                    console.log("FEATURE COUNT: " + queryFeatureCountResult);
                }
            }

            onUpdateFeatureStatusChanged: {
                console.log("UPDATE FEATURE " + updateFeatureStatus)
                if (updateFeatureStatus === Enums.TaskStatusCompleted){
                   console.log("FEATURE UPDATED")
                   featureTable.applyEdits()
                }
                else if(updateFeatureStatus === Enums.TaskStatusErrored)
                {
                    console.log(featureTable.error.message)
                }

            }

            // signal handler for the asynchronous deleteFeature method
            onDeleteFeatureStatusChanged: {
                if (deleteFeatureStatus === Enums.TaskStatusCompleted) {
                    // apply the edits to the service
                    featureTable.applyEdits();
                    secureStorage.setContent("verifiedPhoneNumber", "")

                }
            }

            onQueryFeaturesStatusChanged: {
                if (queryFeaturesStatus === Enums.TaskStatusCompleted) {
//                    if (!queryFeaturesResult.iterator.hasNext) {
//                        errorMsgDialog.visible = true;
//                        return;
//                    }

                    // clear any previous selection
                    //featureLayer.clearSelection();

                    var features = []
                    // get the features
                    while (queryFeaturesResult.iterator.hasNext) {
                        features.push(queryFeaturesResult.iterator.next());
                    }

                    console.log("FEATURE COUNT: " + features.length);


                    if (features.length === 0)
                    {
                        var phoneNumber = secureStorage.getContent("verifiedPhoneNumber")
                        console.log("createFeatureWithAttributes: " + phoneNumber);
                        console.log(mapView.map.operationalLayers.get(1).name)
                        var featureAttributes = {"PhoneNumber": phoneNumber};

                        // create a new feature using the mouse's map point
                        var feature = featureTable.createFeatureWithAttributes(featureAttributes, mapView.currentViewpointCenter.center);

                        // add the new feature to the feature table
                        featureTable.addFeature(feature);
                    }
                    else
                    {
                        console.log("QueryFeatures: " + isDeleteFeature)
                        //MATT ADD createFeature logic here
                        //console.log(features[0].geometry.x)

                        selectedFeature = features[0]

                        if(isDeleteFeature === true)
                        {
                            // delete the feature in the feature table asynchronously
                            featureTable.deleteFeature(selectedFeature);
                            isDeleteFeature = false
                        }
                        else
                        {
                            selectedFeature.onLoadStatusChanged.connect(doUpdateGeometry);
                            selectedFeature.load();
                        }
                    }


                    //featureLayer.selectFeatures(features)
                    //dudeupdateFeature(features[0])


                    // select the features
                    // The ideal way to select features is to call featureLayer.selectFeaturesWithQuery(), which will
                    // automatically select the features based on your query.  This is just a way to show you operations
                    // that you can do with query results. Refer to API doc for more details.
                    //featureLayer.selectFeatures(features);

                    // zoom to the first feature
                    //mapView.setViewpointGeometryAndPadding(features[0].geometry, 30);
                }
            }


        }
    }

    function doUpdateGeometry(){
        if (selectedFeature.loadStatus === Enums.LoadStatusLoaded) {
            selectedFeature.onLoadStatusChanged.disconnect(doUpdateGeometry);

            //selectedFeature.attributes.replaceAttribute("typdamage", damageComboBox.currentText);
            // update the feature in the feature table asynchronously
            selectedFeature.geometry = mapView.currentViewpointCenter.center;

            featureTable.updateFeature(selectedFeature);
        }
    }

    function dudeupdateFeature(feature){

        var geom1 = GeometryEngine.project(mapView.currentViewpointCenter.center, mySpatialReference)
        //feature.geometry = mapView.currentViewpointCenter.center


        console.log(feature.geometry.x)

        //pointBuilder.setXY(mapView.currentViewpointCenter.center.x,mapView.currentViewpointCenter.center.y)
        pointBuilder.setXY(geom1.x,geom1.y)
        //feature.geometry = pointBuilder.geometry
        console.log(pointBuilder.toText())
        console.log(featureTable.credential.token)
        featureTable.updateFeature(feature)
    }

    PointBuilder{
        id:pointBuilder
        spatialReference: mapView.spatialReference

    }
    function man(){
        console.log("man")
    }
    function updateLocation_OLD(){

        var phoneNumber = secureStorage.getContent("verifiedPhoneNumber")
        //return;


        if(!AppFramework.network.isOnline)
        {
            messageBox.descriptionText = "App is currently offline";
            messageBox.visible = true;
            return;
        }

        //console.log("DUDE");
        console.log(securityPortal.portalUser.username + ": " + securityPortal.credential.token);

        var geom1 = GeometryEngine.project(mapView.currentViewpointCenter.center, mySpatialReference)
        console.log(geom1.x + ", " + geom1.y)
        //http://localhost:1337/api/arcgis/updateUserLocation

        var dude =
        {
            geometry: "{\"spatialReference\": {\"wkid\": 4326},\"x\":" + geom1.x + ",\"y\":" + geom1.y + "}",
            attributes: "{\"Username\": \""  + securityPortal.portalUser.username +  "\",\"PhoneNumber\": \"" + phoneNumber  + "\"}",
            token: securityPortal.credential.token
        };

        console.log(JSON.stringify(dude));
        busyIndicator.visible = true;
        networkRequest.send(dude);

    }

//    width: 40
//    height: 40


    width: mapControls.radius + mapControls.defaultMargin
    height: 1 * width

    Rectangle {

        Layout.preferredWidth: 2 * mapControls.radius // parent.parent.radius
        Layout.preferredHeight: Layout.preferredWidth
        radius: 0.5 * Layout.preferredWidth
        color: "#FFFFFF"
        anchors.fill: parent

        Image {
            id: checkinImg
            source: "images/profile.png" //"../MapTour/images/distance.png"
            anchors {
                fill: parent
                margins: 0.2 * mapControls.defaultMargin
            }
            mipmap: true
        }
        ColorOverlay{
            anchors.fill: checkinImg
            source: checkinImg
            color: "#4C4C4C"
        }

        SpatialReference {
            id: mySpatialReference
            wkid: 4326
        }

        NetworkRequest {
            id: networkRequest
            url: app.info.properties.mcscApiBaseUrl + "arcgis/updateUserLocation"
            //url:"http://localhost:1337/api/arcgis/updateUserLocation"
            //url: "https://mcsctwilio.azurewebsites.net/api/arcgis/updateUserLocation"
            method: "POST"
            responseType: "json"
            onReadyStateChanged: {
                if (readyState === NetworkRequest.DONE) {
                    //console.log(networkRequest.url)
                    //var data = JSON.parse(networkRequest.response)
                    console.log(JSON.stringify(networkRequest.response));
                    messageBox.descriptionText = JSON.stringify(networkRequest.response);
                    messageBox.visible = true;
                    busyIndicator.visible = false;

                }
            }
        }


        Components.MessageDialog {
            id: updateLocationMessageBox

            showLeftButton: true
            showRightButton: true
            visible: false
            parent: parent.parent.parent.parent
            height: 200

            onLeftButtonClicked: {
                visible = false;
                secureStorage.setContent("oAuthRefreshToken", "");
            }
            onRightButtonClicked: {
                visible = false;

//                if(canUseBioAuth)
//                {
//                    BiometricAuthenticator.message = qsTr("authenticate to proceed")
//                    BiometricAuthenticator.authenticate()
//                }

//                return;

                //secureStorage.setContent("oAuthRefreshToken", "");
                console.log(secureStorage.getContent("oAuthRefreshToken"));
                //console.log(securityPortal.portalUser.username)
                if(secureStorage.getContent("oAuthRefreshToken") === "")
                {
                    var component = webPageComponent;
                    webPage = component.createObject(app);
                    webPage.load();
                }
                else
                {
                    loadPortal();
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {

                var phoneNumber = secureStorage.getContent("verifiedPhoneNumber")
                console.log(phoneNumber)
                registerPhoneP = registerPhonePage.createObject(app)
                console.log(registerPhoneP)
                if (phoneNumber.length !== 10)
                {
                    registerPhoneP = registerPhonePage.createObject(app)
                    //registerPhoneP.register.connect(man)
                    registerPhoneP.show()
//                    tourPage.learn.createObject(app)
//                    tourPage.learn.show()
                    return
                }


                if(canUseBioAuth)
                {
                    BiometricAuthenticator.message = qsTr("Send us your location?")
                    BiometricAuthenticator.authenticate()
                }
                else
                {
                    //messageBox.showRightButton = true;
                   // messageBox.showLeftButton = true;
                    updateLocationMessageBox.descriptionText = "Send us your location?"
                    updateLocationMessageBox.visible = true;
                }
                return;
                //secureStorage.setContent("oAuthRefreshToken", "");
                console.log(secureStorage.getContent("oAuthRefreshToken"));
                //console.log(securityPortal.portalUser.username)
                if(secureStorage.getContent("oAuthRefreshToken") == "")
                {
                    var component = webPageComponent;
                    webPage = component.createObject(app);
                    webPage.load();



                }
                else
                {
                    loadPortal();
                    //updateLocation();
                }


                //webPageComponent.openUrlInternally();
                //webPage.transitionIn(webPage.transition.bottomUp);
                //app.openUrlInternally("https://mcsctwilio.azurewebsites.net/verification")
                //loadPortal()
                return

                //console.log(mapView.currentViewpointCenter.center.x + ", " + mapView.currentViewpointCenter.center.y)
                var geom1 = GeometryEngine.project(mapView.currentViewpointCenter.center, mySpatialReference)
                console.log(geom1.x + ", " + geom1.y)
                //http://localhost:1337/api/arcgis/updateUserLocation

                var dude =
                {
                    geometry: "{\"spatialReference\": {\"wkid\": 4326},\"x\":" + geom1.x + ",\"y\":" + geom1.y + "}",
                    attributes: "{\"Username\": \"menglish65\",\"PhoneNumber\": \"\"}",
                    token: "ku4fbFuBBfykvvDaj5uxThkKgk5xtwjuhK352tj08-5FyAllH0PyFiJst3xQSp8jEoygm1Y7Wp47sSJxG6rp520h84hXB0wBp9r5S7xGqUbOxZebJg9alhwuHcrrvdbKPnfGPWyr1gEGKVj1xSrHo_H0r3nwt4zZ1eloYOBC1Gdjp-_uKu9a6x_EY22IT08aYAzPk6-I7AAZvcsvaTD-ANj6iQk02E4xCghWFcA_ERQ."
                };

//                        var dude ="
//                        {
//                            \"geometry\": {
//                                \"spatialReference\": {
//                                    \"wkid\": 4326
//                                },
//                                \"x\": geom1.x,
//                                \"y\": geom1.y
//                            },
//                            \"attributes\": {
//                                \"Username\": \"menglish65\",
//                               \"PhoneNumber\": \"\"
//                            },
//                            \"token\": \"ku4fbFuBBfykvvDaj5uxThkKgk5xtwjuhK352tj08-5FyAllH0PyFiJst3xQSp8jEoygm1Y7Wp47sSJxG6rp520h84hXB0wBp9r5S7xGqUbOxZebJg9alhwuHcrrvdbKPnfGPWyr1gEGKVj1xSrHo_H0r3nwt4zZ1eloYOBC1Gdjp-_uKu9a6x_EY22IT08aYAzPk6-I7AAZvcsvaTD-ANj6iQk02E4xCghWFcA_ERQ.\"
//                        }";

                var dude1 = {"geometry":{"spatialReference":{"wkid":4326},"x":-98,"y":49},"attributes":{"Username":"menglish65","PhoneNumber":""},"token":"_QLwfiO7STsMSGtXBlPeAkvep6D8jDMrpvaxWtLq6HXmBNoPjDKS1cCFI6pxdiLqb8uT1XEHzn6nK1ZfuKVv-htu5FLXR14rBfUVWI9S8aL4ObaWsn1cQq7mOHwkKpdZaQ2K5BR2XF7ozm0m9oJb4VoyRYUOFkVst-_4t4vIozeKwWl7gPF7CLYnx7K9cF1SoxD2_JmKJ7TLyZRLbQ-VMUSQG3xb8Vxb97zDa0UlgJS0."};
                //networkRequest.send({adds:"[{\"attributes\":{\"description\":\"Networkrequest Sample\",\"symbolid\":\"13\",\"timestamp\":null},\"geometry\":{\"paths\":[[[-11542803.322978519,3129176.1574580222],[-3547788.0343353897,8625749.168400176],[-5746417.238712249,-3366773.7645645197]]],\"spatialReference\":{\"latestWkid\":3857,\"wkid\":102100}}}]", f:"json"});
               //networkRequest.send({geometry:{spatialReference:{wkid:4326},x:-98,y:49},attributes:{Username:"menglish65",PhoneNumber:""},token:"_QLwfiO7STsMSGtXBlPeAkvep6D8jDMrpvaxWtLq6HXmBNoPjDKS1cCFI6pxdiLqb8uT1XEHzn6nK1ZfuKVv-htu5FLXR14rBfUVWI9S8aL4ObaWsn1cQq7mOHwkKpdZaQ2K5BR2XF7ozm0m9oJb4VoyRYUOFkVst-_4t4vIozeKwWl7gPF7CLYnx7K9cF1SoxD2_JmKJ7TLyZRLbQ-VMUSQG3xb8Vxb97zDa0UlgJS0."});
                busyIndicator.visible = true;
                networkRequest.send(dude);
                //networkRequest.send(JSON.stringify(dude));
                console.log(JSON.stringify(dude));

                //mapView.Center
                //mapView.setViewpointWithAnimationCurve(mapView.map.initialViewpoint, 2.0, Enums.AnimationCurveEaseInOutCubic)
            }
        }
    }

    Component {
        id: phoneWebPageComponent

        Components.WebPage {
            id: phoneWebPage

            showHistory: false
            isDebug: false
            headerHeight: app.headerHeight
            headerColor: app.headerBackgroundColor

            function load(url) {

                visible = true;
                phoneWebPage.transitionIn(phoneWebPage.transition.bottomUp);
                loadPage(url);
            }

            function unload(url) {

                visible = false;
                phoneWebPage.transitionOut(phoneWebPage.transition.topDown);
                //loadPage(url);
            }

            onTransitionOutCompleted: {
                visible = false;
                phoneWebPage.destroy();

//                AuthenticationManager.credentialCache.removeAllCredentials();
//                secureStorage.setContent("oAuthRefreshToken", "")
            }

           Component.onDestruction: {
               console.log("DESTROYED")
           }


        }


    }

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
                //loadPage(url);
            }

            function unload(url) {

                visible = false;
                webPage.transitionOut(webPage.transition.topDown);
                //loadPage(url);
            }

            onTransitionOutCompleted: {
                visible = false;
                webPage.destroy();
//                AuthenticationManager.credentialCache.removeAllCredentials();
//                secureStorage.setContent("oAuthRefreshToken", "")
            }

            onTransitionInCompleted: {
                loadPortal()
            }

            AuthenticationView {
                id: authenticationView
                authenticationManager: AuthenticationManager
            }
        }


    }

    Connections{
        target: menuPage.registerPhone

        onRegister:{
            console.log("MENUPAGE REGISTERPHONE")
        }
    }

    Connections
    {
        target: tourPage.learn

        onRegister:{
            console.log("TOURPAGE LEARN")
            isRegistered = registered
            console.log(isRegistered)
            if(isRegistered === false)
            {
                isDeleteFeature = true

            }
            loadPortal()

//            isRegistered = registered
//            dude.visible = isRegistered
        }
    }
    Connections
    {
        target: registerPhoneP

        onRegister:
        {
            console.log("REGISTERED SIGNAL")
            console.log(registered)
            //loadPortal()
            //updateLocation()
        }
    }

    Connections
    {
        target: AppFramework.network

        onOnlineStateChanged:
        {
            if(isRegistered)
                dude.visible = AppFramework.network.isOnline
        }
    }


    Connections {
        target: securityPortal

        onLoadStatusChanged: {
            console.log("DUDE: " + securityPortal.loadStatus);
            if (securityPortal.loadStatus === Enums.LoadStatusLoaded) {
                secureStorage.setContent("oAuthRefreshToken", securityPortal.credential.oAuthRefreshToken );
                secureStorage.setContent("tokenServiceUrl", securityPortal.credential.tokenServiceUrl);
                console.log("MAN");
                console.log(securityPortal.portalUser.username + ": " + securityPortal.credential.token);

                //var component = webPageComponent,
                //webPage = component.createObject(app);
                if(webPage != undefined)
                {
                    webPage.unload();
                    //dude.updateLocation();
                }

//                var learn = registerPhonePage.createObject(app)
//                learn.show()
//                return
                console.log(JSON.stringify(securityPortal.portalInfo.licenseInfo.json))
                var licenseResult = ArcGISRuntimeEnvironment.setLicense(securityPortal.portalInfo.licenseInfo)
                console.log(licenseResult)
                dude.updateLocation();


            }

        }
    }

    function loadPortal() {

        var oauthInfo = rtCreate("OAuthClientInfo", {oAuthMode: Enums.OAuthModeUser, clientId: app.info.properties.mcscClientId }) //"AJhw6AaHp2y0Bmx0"
        var credential = rtCreate("Credential", {
                                      oAuthClientInfo: oauthInfo,
                                      oAuthRefreshToken: secureStorage.getContent("oAuthRefreshToken"),
                                      tokenServiceUrl:"http://www.arcgis.com/sharing/rest/oauth2/token"
                                  });

        dude.securityPortal = rtCreate("Portal", { url: "http://arcgis.com", credential: credential});
        if (securityPortal.loadStatus === 1) {
            console.log("DUDEMAN")
            securityPortal.retryLoad()

        }
        securityPortal.load();
        console.log(secureStorage.getContent("oAuthRefreshToken"))

    }

    function appInitialization() {
        if (Qt.platform.os === "ios" && AppFramework.systemInformation.hasOwnProperty("unixMachine")) {
            if (AppFramework.systemInformation.unixMachine === "iPhone10,3" || AppFramework.systemInformation.unixMachine === "iPhone10,6") {
                isIPhoneX = true;
            }
        }

        isAutoSignIn = app.settings.value("appAutoSignIn",true);
        isBioAuth = true;// app.settings.value("appBioAuth");

        if (isAutoSignIn) {
            if (isBioAuth && canUseBioAuth  ) {
                BiometricAuthenticator.message = qsTr("Send us your location?")
                BiometricAuthenticator.authenticate()
            } else {
                loadPortal()
                //stackView.push(profilePage)
            }
        }
    }
    Connections {
        target: BiometricAuthenticator
        onAccepted: {
            console.log(secureStorage.getContent("oAuthRefreshToken"));
            //console.log(securityPortal.portalUser.username)
            if(secureStorage.getContent("oAuthRefreshToken") === "")
            {
                var component = webPageComponent;
                webPage = component.createObject(app);
                webPage.load();
            }
            else
            {
                loadPortal();
            }

            //loadPortal()
            //stackView.push(profilePage)
            //updateLocation();
        }
    }

    Component.onCompleted: {
        console.log("YEAH: " + dude.radius)


        var phoneNumber = secureStorage.getContent("verifiedPhoneNumber")
        console.log (phoneNumber.length)
        dude.visible = (phoneNumber.length === 10) ? true : false
        isRegistered = dude.visible
    }
}
