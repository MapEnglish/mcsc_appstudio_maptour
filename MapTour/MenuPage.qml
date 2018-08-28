import QtQuick 2.3
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.3

import QtQuick.Controls 2.1 as NewControls
import QtQuick.Controls.Material 2.1 as NewMaterial

import ArcGIS.AppFramework 1.0

import "components" as Components
import "../MCSC" as MCSC

Components.MenuPage {
    id: menuPage

    property var registerPhone
    property color backgroundColor: app.pageBackgroundColor
    property real defaultMargin: units(8)
    property var hideMask

    property bool refreshButtonVisible: false
    property bool galleryButtonVisible: true

    // menu items
    readonly property string kGallery: qsTr("Back to Gallery")
    readonly property string kFontSize: qsTr("Font Size")
    readonly property string kNotify: qsTr("Receive Notifications")
    readonly property string kAbout: qsTr("About the App")
    readonly property string kDistance: qsTr("Show Distance")
    readonly property string kFeedback: qsTr("Send Feedback")
    readonly property string kDownloadMap: qsTr("Download offline map")
    readonly property string kUpdateMap: qsTr("Update offline map")
    readonly property string kUseOfflineMap: qsTr("Use offline map")

    property string refreshText: app.tourManager.hasTourDataInCache() || app.mmpkManager.offlineMapExist ? qsTr("Clear cache") : qsTr("Refresh")

    signal menuItemClicked(string name)
    signal switchChanged(string name, bool checked)

    visible: false
    isDebug: false
    menuHeight: parent.height
    headerHeight: units(50)
    header_titleText: ""
    transitionType: transition.none
    initX: -menuWidth
    transitionDuration: 200
    headerBackgroundColor: app.headerBackgroundColor
    header_rightIconUrl: "images/close.png"
    x: {
        var res = -width
        return res
    }

    //MATT
    Component {
        id:registerPhonePage

        MCSC.RegisterPhonePage{

        }
    }

    content: NewControls.Pane {
        id: menuContentContainer

        anchors.fill: parent
        background: Rectangle {
            color: backgroundColor
        }
        padding: 0
        leftPadding: app.widthOffset

//        Rectangle {
//            anchors.fill: parent
//            gradient: Gradient {
//                GradientStop { position: 0.0; color: "#22000000";}
//                GradientStop { position: 1.0; color: "#00000000";}
//            }
//        }

        ListView {
            id: menuListView

            anchors.fill: parent
            clip: true
            spacing: units(1)

            model: menuModel

            delegate: Rectangle {
                width: parent.width - 4 * menuPage.defaultMargin
                height: units(60) * app.fontScale
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                color: "transparent"

                Components.Ink {
                    anchors.fill: parent
                    enabled: !control

                    RowLayout {
                        anchors.fill: parent

                        Text {
                            id: text

                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignLeft
                            text: name
                            color: app.textColor
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            maximumLineCount: 2
                            clip: true
                            font {
                                pointSize: app.baseFontSize
                                family: app.customTextFont.name
                            }
                        }

                        Switch {
                            id: switchButton

                            visible: control === "switch"
                            checked: {
                                if (name === kDistance) {
                                    return app.showDistance
                                } else if (name === kUseOfflineMap) {
                                    return app.useOfflineMap
                                } else {
                                    return false
                                }
                            }
                            onCheckedChanged: {
                                switchChanged(name, checked)
                            }
                            style: switchStyle
                        }

                        NewControls.SpinBox {
                            id: box
                            visible: control === "spinBox"
                            from: 80
                            to: app.isSmallScreen? 120:160
                            NewMaterial.Material.accent: app.headerBackgroundColor
                            stepSize: app.isSmallScreen? 10:20
                            value: app.fontScale*100
                            textFromValue: function(value, locale) {
                                return value+"%";
                            }

                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text.replace("%",""))
                            }

                            implicitHeight: 30*app.scaleFactor
                            Layout.maximumWidth: 0.45 * parent.width
                            anchors.verticalCenter: parent.verticalCenter
                            //font.pointSize: app.baseFontSize
                            font.family: app.customTextFontTTF.name
                            onValueChanged: {
                                app.fontScale = value/100;
                                app.settings.setValue("fontScale", app.fontScale);
                            }
                        }

                    }

                    onClicked: {
                        if (control === "") {
                            menuItemClicked(name)
                        }
                    }
                }

                Rectangle {
                    visible: index !== menuListView.count - 1
                    anchors.bottom: parent.bottom
                    color: app.textColor
                    opacity: 0.2
                    width: parent.width
                    height: units(1)
                }
            }
        }
    }

    Component {
        id: switchStyle

        SwitchStyle {
            id: style

            property color checkedGrooveColor: Qt.lighter(app.headerBackgroundColor, 1.9)
            property color checkedHandleColor: app.headerBackgroundColor
            property color grooveColor: Qt.darker(app.pageBackgroundColor)
            property color handleColor: "#FFFFFF"

            groove: Item {
                    width: units(48)
                    height: units(22)

                    Rectangle {
                        width: parent.width - units(2)
                        height: units(16)
                        radius: height/2
                        anchors.centerIn: parent
                        border {
                            width: units(1)
                            color: control.checked ? style.checkedGrooveColor : style.grooveColor
                        }

                        color: control.checked ? style.checkedGrooveColor : style.grooveColor

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }
                        }
                    }
                }

            handle: Rectangle {
                width: units(22)
                height: units(22)

                radius: height/2

                color: control.checked ? style.checkedHandleColor : style.handleColor

                border.width: units(1)
                border.color: control.checked ? style.checkedHandleColor : style.grooveColor

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }
        }
    }

    ListModel {
        id: menuModel
    }

    onHeader_rightIcon_Clicked: {
        hideMenu()
    }

    onTransitionOutCompleted: {
        visible = false
    }

    onSwitchChanged: {
        switch (name) {
        case (qsTr("Show Distance")):
            app.showDistance = checked
            app.locationManager.active = checked
            break
        case (kUseOfflineMap):
            app.useOfflineMap = checked
        }
    }

    onMenuItemClicked: {
        hideMenu(function () {
            switch(name) {
            case kGallery:
                exit();
                break;
            case kAbout:
                aboutPage.show();
                break;
            case refreshText:
                refreshCache()
                break;
            case kFeedback:
                Qt.openUrlExternally(generateFeedbackEmailLink());
                break;
            case kDownloadMap:
                mmpkDialog.open()
                break;
            case kNotify:
                //Qt.openUrlExternally("https://notifications-mcsc.hub.arcgis.com/");
                registerPhone = registerPhonePage.createObject(app)
                registerPhone.show()
                break;
            }
        })
    }

    function generateFeedbackEmailLink() {
        var urlInfo = AppFramework.urlInfo("mailto:%1".arg(app.feedbackEmail)),
            deviceDetails = [
                    "%1: %2 (%3)".arg(qsTr("Device OS")).arg(Qt.platform.os).arg(AppFramework.osVersion),
                    "%1: %2".arg(qsTr("Device Locale")).arg(Qt.locale().name),
                    "%1: %2".arg(qsTr("App Version")).arg(app.info.version),
                    "%1: %2".arg(qsTr("AppStudio Version")).arg(AppFramework.version),
                ];
        urlInfo.queryParameters = {
            "subject": "%1 %2".arg(qsTr("Feedback for")).arg(app.info.title),
            "body": "\n\n%1".arg(deviceDetails.join("\n"))
        };
        return urlInfo.url
    }

    function updateMenu () {
        var menuItems = [
                    {"name": kGallery,
                     "control": ""},
                    {"name": kFontSize,
                     "control": "spinBox"},
                    {"name": kAbout,
                     "control": ""},
                    {"name": kNotify,
                     "control": ""},
                    {"name": kFeedback,
                     "control": ""},
                    {"name": kDistance,
                     "control": "switch"},
                    {"name": refreshText,
                     "control": ""},
                    {"name": kUseOfflineMap,
                     "control": "switch"},
                    {"name": kDownloadMap,
                     "control": ""},
                ]
        menuModel.clear()
        for (var i=0; i < menuItems.length; i++) {
            if ((menuItems[i].name === kGallery && (!app.showGallery || !galleryButtonVisible)) ||
                (menuItems[i].name === kFeedback && app.feedbackEmail.length === 0) ||
                (menuItems[i].name === kDistance && !(app.canUseDistance)) ||
                (menuItems[i].name === refreshText && !(refreshButtonVisible)) ||
                (menuItems[i].name === kUseOfflineMap && (!app.mmpkManager.offlineMapExist || !kUseOfflineMap)) ||
                (menuItems[i].name === kDownloadMap && (app.mmpkManager.offlineMapExist || !app.isOnline || !app.offlineMMPKID || !app.downloadOfflineMap))
                ) {
                continue
            }
            menuModel.append(menuItems[i])
        }
        return 0
    }

    function refreshCache () {
        if (app.tourManager.hasTourDataInCache()) {
            app.tourManager.progressDialog.completed.connect(toursListView.refresh)
            app.tourManager.progressDialog.show()
            return
        } else {
            if (app.isOnline) {
                app.tourManager.tours.cacheCleared.disconnect(toursListView.refresh)
                app.tourManager.tours.cacheCleared.connect(toursListView.reset)
            } else {
                app.tourManager.tours.cacheCleared.disconnect(toursListView.reset)
                app.tourManager.tours.cacheCleared.connect(toursListView.refresh)
            }
            app.tourManager.tours.clearCache()
        }
    }

    function showMenu () {
        menuPage.refreshText = app.tourManager.hasTourDataInCache() || app.mmpkManager.offlineMapExist ? qsTr("Clear cache") : qsTr("Refresh")
        updateMenu()
        if (menuPage.initX < 0) {
            menuPage.visible = true
            menuPage.transitionIn(transition.leftToRight)
        }
    }

    function hideMenu (callback) {
        if (!callback) callback = function () {}
        menuPage.onTransitionOutCompleted.connect(callback)
        menuPage.onTransitionInCompleted.connect(function () {
            menuPage.onTransitionOutCompleted.disconnect(callback)
        })
        hideMask();
        if (menuPage.initX >= 0) {
            menuPage.transitionOut(transition.rightToLeft)
        }
    }

    function units(num) {
        return num ? parseInt(num * AppFramework.displayScaleFactor) : 0
    }
}
