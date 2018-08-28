import QtQuick 2.3
//import QtQuick.Controls 2.2
import QtQuick.Controls 1.1
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as NewControls
import QtQuick.Controls.Material 2.1
import ArcGIS.AppFramework.Authentication 1.0
import Esri.ArcGISRuntime 100.2
import Esri.ArcGISRuntime.Toolkit.Dialogs 100.2
import QtQuick.Controls.Styles 1.4

import "../MapTour/components" as Components

Components.Page {
    id:registerPhonePage

    property color themeColor: "steelBlue"
    property var rtCreate: ArcGISRuntimeEnvironment.createObject
    property Portal portal
    property Portal securityPortal

    property var smsUsr:     {
        "geometry": {"spatialReference": {"wkid": 4326}, "x": 0, "y": 0},
        "attributes": {
            "Username": "",
            "PhoneNumber": ""
        },
        "token": ""
      };

    signal register (bool registered)

    isDebug: false
    visible: false
    headerHeight: 50 * app.scaleFactor

    SecureStorageHelper{
        id: secureStorage
    }

    header: Rectangle {
        anchors.fill: parent
        color: app.headerBackgroundColor

        Text {
            id: titleText

            text: qsTr("Register Phone")
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

        ImageButton {
            source: "../MapTour/images/close.png"
            rotation: -90
            height: 30 * app.scaleFactor
            width: 30 * app.scaleFactor
            checkedColor : "transparent"
            pressedColor : "transparent"
            hoverColor : "transparent"
            glowColor : "transparent"

            anchors {
                rightMargin: app.isIphoneX && !app.isPortrait ? app.widthOffset : 10 * app.scaleFactor
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            onClicked: {
                registerPhonePage.hide()
                //rowRequestVerification.visible = false
            }
        }
    }

    content: NewControls.Pane{
        anchors.fill: parent
        padding: 0
        bottomPadding: app.heightOffset
        topPadding: 5
        id: content

        background: Rectangle {
            color: app.pageBackgroundColor
        }

        Flickable {
            anchors.fill: parent
            contentHeight: columnContainer.height
            clip: true

            ColumnLayout{
                id: columnContainer

                Layout.fillHeight: true

                width: app.isPortrait ? Math.min(units(400), parent.width) : Math.min(units(600), parent.width)

                spacing: app.units(5)

                ColumnLayout{
                    id: rowRequestVerification
                    spacing: app.units(1)
                    Layout.leftMargin: units(8)
                    Layout.rightMargin: units(8)
                    //Layout.fillHeight: true
                    //Layout.fillWidth: true
                    /*anchors.right: parent.right*/

                    /*layoutDirection: Qt.RightToLeft*/
                    //spacing: units(8)
                    property real verticalPadding: Qt.platform.os === "windows" ? units(8.9) : units(9.5)


                    TextField {
                        id: phoneNumber
                        placeholderText: qsTr("Enter phone number")
                        Material.accent: "#8f499c"
                        //Layout.topMargin: 100 * scaleFactor
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.family: app.customTextFont.name
                        font.pointSize: app.baseFontSize
                        text: "4162742208"
                    }

                    Button {
                        id: requestVerificationButton


                        anchors {
                            //horizontalCenter: parent.horizontalCenter
//                            bottom: parent.bottom
//                            bottomMargin: 60 * app.scaleFactor
                        }

                        //opacity: 0.0

                        style: ButtonStyle {
                            id: btnStyle

                            property real width: parent.width
                            label: Text {
                                id: lbl

                                text: requestVerificationButton.text
                                anchors.centerIn: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                color: app.titleColor
                                font.family: app.customTextFont.name
                                font.pointSize: app.baseFontSize
                            }

                            background: Rectangle {
                                color: Qt.darker(app.headerBackgroundColor, 1.2)
                                border.color: app.titleColor
                                radius: app.scaleFactor * 2
                                //implicitWidth: 300
                                implicitHeight: 50
                            }
                        }
                        height: implicitHeight < app.units(56) ? app.units(56) : undefined // set minHeight = 64, otherwise let it scale by content height which is the default behavior
                        width: Math.min(0.5 * parent.width, app.units(250))
                        text: qsTr("Request Verification Code")

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                //signInClicked("");
                                console.log("dude")
                                doVerificationCodeRequest()
                            }
                        }


                    }



                    //Click on the button to store key and value in the keychain
                    Button {
                        id: requestVerificationButton_OLD
                        visible: false
                        text: qsTr("Request Verification Code")
                        onClicked: {
                            //toastMessageRec.visible = true
                            //toastMessage.text = "Dude"
                            //rowEnterVerificationCode.visible = true

                            //console.log(securityPortal.portalUser.username + ": " + securityPortal.credential.token);

                            startVerificationNetworkRequest.url += "verification/start"
                            //console.log(networkRequest.url)
                            //console.log(phoneNumber.text)

                            smsUsr.token = securityPortal.credential.token
                            smsUsr.attributes.Username = securityPortal.portalUser.username;
                            smsUsr.attributes.PhoneNumber = phoneNumber.text;
    //                            var dude =
//                            {
//                                attributes: {PhoneNumber: phoneNumber.text},
//                            };

                            var smsRecipient = {
                                country_code: "1",
                                smsUser: JSON.stringify(smsUsr),
                                via: "sms"
                            };

                            console.log(JSON.stringify(smsRecipient));
                            startVerificationNetworkRequest.send(smsRecipient);




                            return


                            retrieveData.visible = false

                            // check if key and value is not null and not empty
                            if (key.text.length > 0 && key.text !== null) {

                                // store key and value into Keychain
                                SecureStorage.setValue(key.text,value.text)
                                toastMessage.text = insertSuccessMessage
                                toastMessageRec.color = successColor
                            }
                            else {
                                toastMessage.text = failMessage;
                                toastMessageRec.color = errorColor;
                            }
                        }
                    }
                }

                SpatialReference {
                    id: mySpatialReference
                    wkid: 4326
                }

                ColumnLayout{
                    id: rowEnterVerificationCode
                    visible: true
                    //spacing: 10
                    Layout.leftMargin: units(8)
                    Layout.rightMargin: units(8)
                    //Layout.fillHeight: true
                    //Layout.fillWidth: true
                    /*anchors.right: parent.right*/

                    /*layoutDirection: Qt.RightToLeft*/
                    spacing: app.units(1)
                    property real verticalPadding: Qt.platform.os === "windows" ? units(8.9) : units(9.5)


                    TextField {
                        id: verificationCode
                        placeholderText: qsTr("Enter verification code")
                        Material.accent: "#8f499c"
                        //Layout.topMargin: 100 * scaleFactor
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        font.family: app.customTextFont.name
                        font.pointSize: app.baseFontSize
                    }

                    //Click on the button to store key and value in the keychain
                    Button {
                        id: submitVerificationCodeButton
                        text: qsTr("Register Phone")
                        onClicked: {
                            console.log(verificationCode.text.length)
                            if(verificationCode.text.length === 0)
                            {
                                messageBox.parent = content;
                                messageBox.descriptionText = qsTr("Please enter verification code");
                                messageBox.visible = true;
                                return;
                            }


                            var geom1 = GeometryEngine.project(mapView.currentViewpointCenter.center, mySpatialReference)

                            smsUsr.token = securityPortal.credential.token
                            smsUsr.attributes.Username = securityPortal.portalUser.username;
                            smsUsr.attributes.PhoneNumber = phoneNumber.text;

                            smsUsr.geometry.x = geom1.x;

                            var smsRecipient = {
                                country_code: "1",
                                smsUser: JSON.stringify(smsUsr),
                                via: "sms",
                                token: verificationCode.text,
                                performEditOnFeatureService: app.info.properties.use_mcscApiForEditing
                            };

                            console.log(JSON.stringify(smsRecipient));
                            busyIndicator.visible = true
                            //storeFeature(smsRecipient)
                            //submitVerificationCodeNetworkRequest.url += "verification/verify"
                            submitVerificationCodeNetworkRequest.send(smsRecipient);
                            //register(true)
                        }
                    }
                }

                RowLayout{
                    id: rowUnsubscribe
                    visible: false
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button {
                        id: signInButton


                        anchors {
                            horizontalCenter: parent.horizontalCenter
//                            bottom: parent.bottom
//                            bottomMargin: 60 * app.scaleFactor
                        }

                        opacity: 0.0

                        style: ButtonStyle {
                            id: btnStyle

                            property real width: parent.width
                            label: Text {
                                id: lbl

                                text: signInButton.text
                                anchors.centerIn: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                wrapMode: Text.WordWrap
                                color: app.titleColor
                                font.family: app.customTextFont.name
                                font.pointSize: app.baseFontSize
                            }

                            background: Rectangle {
                                color: Qt.darker(app.headerBackgroundColor, 1.2)
                                border.color: app.titleColor
                                radius: app.scaleFactor * 2
                                implicitWidth: 200
                                implicitHeight: 60
                            }
                        }
                        height: implicitHeight < app.units(56) ? app.units(56) : undefined // set minHeight = 64, otherwise let it scale by content height which is the default behavior
                        width: Math.min(0.5 * parent.width, app.units(250))
                        text: qsTr("Unsubscribe")

                        MouseArea{
                            anchors.fill: parent
                            onClicked: {
                                //signInClicked("");
                                console.log("dude")
                            }
                        }

                        NumberAnimation{
                            id: signInButtonAnimation
                            target: signInButton
                            running: false
                            properties: "opacity"
                            from: 0.0
                            to: 1.0
                            easing.type: Easing.InQuad
                            duration: 1000
                        }
                    }


                    Button {
                        id: unsubscribeButton
                        visible: false
                        text: qsTr("Unsubscribe")
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {

                            if (app.info.properties.use_mcscApiForEditing)
                            {
                                //secureStorage.setContent("verifiedPhoneNumber", "")
                                var phone = {phoneNumber: secureStorage.getContent("verifiedPhoneNumber"),
                                    token: securityPortal.credential.token};
                                console.log(JSON.stringify(phone))
                                busyIndicator.visible = true
                                unsubscribeNetworkRequest.send(phone)

                            }
                            else
                            {
                                register(false)

                            }


                        }
                    }
                }
            }

        }
    }

    //Display toast message
    Rectangle {
        id: toastMessageRec
        height: 80 * scaleFactor
        width: toastMessage.text === "" ? 0 : toastMessage.width + 30 * scaleFactor
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50 * scaleFactor
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 18 * scaleFactor

        Label {
            id: toastMessage
            anchors.centerIn: parent
            font.family: app.customTextFont.name
            font.bold: true
            font.pointSize: 10
            color: themeColor
            width: 300
            wrapMode: Text.Wrap
        }
    }

    AuthenticationView {
        id: authenticationView
        authenticationManager: AuthenticationManager
    }

    function storeFeature(user)
    {
        //console.log(JSON.stringify(smsUsr))
        storeFeatureNetworkRequest.send(user)
    }

    NetworkRequest {
        id: storeFeatureNetworkRequest
        url: app.info.properties.mcscApiBaseUrl + "arcgis/storeFeature"

        method: "POST"
        responseType: "json"
        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                busyIndicator.visible = false
                console.log(JSON.stringify(storeFeatureNetworkRequest.response));
                toastMessageRec.visible = true
                toastMessage.text = JSON.stringify(storeFeatureNetworkRequest.response);

                console.log(storeFeatureNetworkRequest.response.addResults.length )
                if (storeFeatureNetworkRequest.response.addResults.length === 1 &&
                    storeFeatureNetworkRequest.response.addResults[0].success === true)
                    {
                        console.log("SUCCESS")
                        secureStorage.setContent("verifiedPhoneNumber", smsUsr.attributes.PhoneNumber);
                    }

            }
        }
    }

    NetworkRequest {
        id: unsubscribeNetworkRequest
        url: app.info.properties.mcscApiBaseUrl + "arcgis/unsubscribePhone"

        method: "POST"
        responseType: "json"
        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                busyIndicator.visible = false
                console.log(JSON.stringify(unsubscribeNetworkRequest.response));
                toastMessageRec.visible = true
                toastMessage.text = JSON.stringify(unsubscribeNetworkRequest.response);
                unsubscribeButton.visible = false
                secureStorage.setContent("verifiedPhoneNumber", "");

                if (!app.info.properties.use_mcscApiForEditing)
                    register(false)

            }
        }
    }

    NetworkRequest {
        id: submitVerificationCodeNetworkRequest
        url: app.info.properties.mcscApiBaseUrl + "verification/verify"

        method: "POST"
        responseType: "json"
        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                console.log(JSON.stringify(submitVerificationCodeNetworkRequest.response));
                busyIndicator.visible = false
                //{"addResults":[{"globalId":"ACEC62F0-D864-432F-B398-
               //B79231077A16","objectId":1044,"success":true,"uniqueId":1044}]}

                if(app.info.properties.use_mcscApiForEditing)
                {
                    if(submitVerificationCodeNetworkRequest.response.addResults)
                    {
                        secureStorage.setContent("verifiedPhoneNumber", smsUsr.attributes.PhoneNumber);
                        register(true)
                    }
//                    else
//                        register(false)
                }
                else
                {
                    console.log(submitVerificationCodeNetworkRequest.response)
                    if(submitVerificationCodeNetworkRequest.response.success === true)
                    {
                        secureStorage.setContent("verifiedPhoneNumber", smsUsr.attributes.PhoneNumber);
                        register(true)
                    }
                }

                toastMessageRec.visible = true
                toastMessage.text = JSON.stringify(submitVerificationCodeNetworkRequest.response);

            }

        }
    }

    NetworkRequest {
        id: startVerificationNetworkRequest
        url: app.info.properties.mcscApiBaseUrl

        method: "POST"
        responseType: "json"
        onReadyStateChanged: {
            if (readyState === NetworkRequest.DONE) {
                //console.log(networkRequest.url)
                //var data = JSON.parse(networkRequest.response)
                console.log(JSON.stringify(startVerificationNetworkRequest.response));

                if (startVerificationNetworkRequest.response.success && startVerificationNetworkRequest.response.success === true)
                {
                    rowEnterVerificationCode.visible = true;
                }

                toastMessageRec.visible = true
                toastMessage.text = startVerificationNetworkRequest.response.message

                //messageBox.descriptionText = JSON.stringify(networkRequest.response);
                //messageBox.visible = true;
                //busyIndicator.visible = false;

            }
        }
    }

    function doVerificationCodeRequest(){
        startVerificationNetworkRequest.url += "verification/start"
        //console.log(networkRequest.url)
        //console.log(phoneNumber.text)

        smsUsr.token = securityPortal.credential.token
        smsUsr.attributes.Username = securityPortal.portalUser.username;
        smsUsr.attributes.PhoneNumber = phoneNumber.text;

        var smsRecipient = {
            country_code: "1",
            smsUser: JSON.stringify(smsUsr),
            via: "sms"
        };

        console.log(JSON.stringify(smsRecipient));
        startVerificationNetworkRequest.send(smsRecipient);

    }
    function show () {
        //learnMorePage.pageData = results
        visible = true
        transitionIn(transition.bottomUp)
        //register(false)
    }

    function hide () {
        transitionOut(transition.topDown)
    }

    function loadPortal() {
        console.log(secureStorage.getContent("oAuthRefreshToken"))
        var oauthInfo = rtCreate("OAuthClientInfo", {oAuthMode: Enums.OAuthModeUser, clientId: app.info.properties.mcscClientId }) //"DUDE_AJhw6AaHp2y0Bmx0"
        var credential = rtCreate("Credential", {
                                      oAuthClientInfo: oauthInfo,
                                      oAuthRefreshToken:secureStorage.getContent("oAuthRefreshToken"),
                                      tokenServiceUrl:"http://www.arcgis.com/sharing/rest/oauth2/token"
                                  });
        registerPhonePage.securityPortal = rtCreate("Portal", { url: "http://arcgis.com", credential: credential});
        if (securityPortal.loadStatus === 1) {
            securityPortal.retryLoad()

        }
        securityPortal.load();
        console.log(secureStorage.getContent("tokenServiceUrl"))
    }

    Component.onCompleted: {

        console.log("Component.onCompleted")
        console.log(app.info.properties.clientId)

        var phoneNumber = secureStorage.getContent("verifiedPhoneNumber")
        toastMessage.text = ""

        if(phoneNumber.length === 10)
        {
            rowRequestVerification.visible = false
            rowEnterVerificationCode.visible = false
            rowUnsubscribe.visible = true
            signInButtonAnimation.start()

            toastMessageRec.visible = true
            toastMessage.text = qsTr("Your phone number ") + phoneNumber +  qsTr(" is already registered. You can close this window. Or you can unsubscribe by clicking the button above")
            register(true)
        }
        else
        {
            rowRequestVerification.visible = true
            rowEnterVerificationCode.visible = true
            rowUnsubscribe.visible = false
            toastMessageRec.visible = false

            Qt.openUrlExternally(app.info.properties.mcscNotifyInitiative )

        }

        loadPortal()
    }

    Connections {
        target: securityPortal

        onLoadStatusChanged: {
            console.log("DUDE: " + securityPortal.loadStatus);
            if (securityPortal.loadStatus === Enums.LoadStatusLoaded) {
//                rowRequestVerification.visible = true
//                rowEnterVerificationCode.visible = true
//                rowUnsubscribe.visible = false
//                toastMessageRec.visible = false
            }
            else
            {
                console.log("MAN")
                registerPhonePage.hide()
            }
        }
    }

}
