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
import QtQuick.Controls 2.2
import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import QtQuick.Layouts 1.3

import "components" as Components

Components.Page {
    id: aboutPage

    isDebug: false
    visible: false
    headerHeight: 50 * app.scaleFactor

    header: Rectangle {
        anchors.fill: parent
        color: app.headerBackgroundColor

        Text {
            id: titleText

            text: qsTr("About the App")
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
            source: "images/close.png"
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
                aboutPage.hide()
            }
        }
    }

    content: Pane {
        anchors.fill: parent
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: app.heightOffset
        background: Rectangle {
            color: app.pageBackgroundColor
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                mouse.accepted = false
            }
        }

        Flickable {
            anchors.fill: parent
            contentHeight: columnContainer.height
            clip: true


            ColumnLayout{
                id: columnContainer
                width: app.isPortrait ? Math.min(units(400), parent.width) : Math.min(units(600), parent.width)
                anchors.horizontalCenter: parent.horizontalCenter

                spacing: 0

                Rectangle{
                    Layout.preferredHeight: 30*app.scaleFactor
                    Layout.fillWidth: true
                    color: "transparent"
                }

                Image{
                    Layout.preferredHeight: 50*app.scaleFactor
                    Layout.preferredWidth: 50*app.scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    source: getAppIcon()
                    visible: source > ""
                }

                Rectangle{
                    Layout.preferredHeight: app.units(16)
                    Layout.fillWidth: true
                    color: "transparent"
                }

                Text {
                    text: app.info.title+" "+app.info.version
                    color: app.textColor
                    font {
                        pointSize: app.subtitleFontSize
                        bold: true
                        weight: Font.Bold
                        family: app.customTitleFont.name
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.preferredWidth: parent.width-app.units(16)
                    wrapMode: Text.Wrap
                }

                Rectangle{
                    visible: app.info.description>""
                    Layout.preferredHeight: app.units(16)
                    Layout.fillWidth: true
                    color: "transparent"
                }

                Text {
                    text: app.info.description
                    visible: app.info.description>""
                    textFormat: Text.StyledText
                    color: app.textColor
                    wrapMode: Text.Wrap
                    linkColor: app.linkColor

                    Layout.preferredWidth: parent.width-app.units(16)
                    anchors.horizontalCenter: parent.horizontalCenter
                    font {
                        pointSize: app.baseFontSize
                        family: app.customTextFont.name
                    }
                    onLinkActivated: {
                        linkColor = app.visitedLinkColor
                        webViewLoader.load(link)
                    }
                }

                Rectangle{
                    visible: app.info.licenseInfo>""
                    Layout.preferredHeight: app.units(16)
                    Layout.fillWidth: true
                    color: "transparent"
                }

                Text{
                    text: qsTr("Access and Use Constraints") + ":"
                    visible: app.info.licenseInfo>""
                    color: app.textColor
                    wrapMode: Text.Wrap
                    linkColor: app.linkColor

                    Layout.preferredWidth: parent.width-app.units(16)
                    anchors.horizontalCenter: parent.horizontalCenter
                    font {
                        bold: true
                        pointSize: app.baseFontSize
                        family: app.customTitleFont.name
                    }
                }

                Text {
                    text:app.info.licenseInfo
                    visible: app.info.licenseInfo>""
                    textFormat: Text.StyledText
                    color: app.textColor
                    wrapMode: Text.Wrap
                    linkColor: app.linkColor

                    Layout.preferredWidth: parent.width-app.units(16)
                    anchors.horizontalCenter: parent.horizontalCenter
                    font {
                        pointSize: app.baseFontSize
                        family: app.customTextFont.name
                    }
                    onLinkActivated: {
                        linkColor = app.visitedLinkColor
                        webViewLoader.load(link)
                    }
                }

                Rectangle{
                    visible: app.info.accessInformation>""
                    Layout.preferredHeight: app.units(16)
                    Layout.fillWidth: true
                    color: "transparent"
                }

                Text{
                    text: qsTr("Credits") + ":"                  
                    textFormat: Text.RichText
                    color: app.textColor
                    wrapMode: Text.Wrap
                    linkColor: app.linkColor

                    Layout.preferredWidth: parent.width-app.units(16)
                    anchors.horizontalCenter: parent.horizontalCenter
                    font {
                        bold: true
                        pointSize: app.baseFontSize
                        family: app.customTitleFont.name
                    }
                }

                Text {
                    text: app.info.accessInformation
                    visible: app.info.accessInformation>""
                    textFormat: Text.StyledText
                    color: app.textColor
                    wrapMode: Text.Wrap
                    linkColor: app.linkColor

                    Layout.preferredWidth: parent.width-20*app.scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter
                    font {
                        pointSize: app.baseFontSize
                        family: app.customTextFont.name
                    }
                    onLinkActivated: {
                        linkColor = app.visitedLinkColor
                        webViewLoader.load(link)
                    }
                }

                Rectangle{
                    visible: app.info.accessInformation>""
                    Layout.preferredHeight: app.units(16)
                    Layout.fillWidth: true
                    color: "transparent"
                }

                Text {
                    text: qsTr("Built using AppStudio for ArcGIS. Mapping API provided by Esri.");
                    textFormat: Text.StyledText
                    color: app.textColor
                    wrapMode: Text.Wrap
                    linkColor: app.linkColor

                    Layout.preferredWidth: parent.width-20*app.scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter
                    font {
                        pointSize: app.baseFontSize
                        family: app.customTextFont.name
                    }
                    onLinkActivated: {
                        linkColor = app.visitedLinkColor
                        webViewLoader.load(link)
                    }
                }

                Rectangle{
                    visible: app.info.version>""
                    Layout.preferredHeight: app.units(16)
                    Layout.fillWidth: true
                    color: "transparent"
                }

                Text{
                    text: qsTr("Version") + ":"
                    visible: app.info.version>""
                    textFormat: Text.RichText
                    color: app.textColor
                    wrapMode: Text.Wrap
                    linkColor: app.linkColor

                    Layout.preferredWidth: parent.width-20*app.scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter
                    font {
                        bold: true
                        pointSize: app.baseFontSize
                        family: app.customTitleFont.name
                    }
                }

                Text {
                    text: app.info.version
                    visible: app.info.version>""
                    textFormat: Text.StyledText
                    color: app.textColor
                    wrapMode: Text.Wrap
                    linkColor: app.linkColor

                    Layout.preferredWidth: parent.width-20*app.scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter
                    font {
                        pointSize: app.baseFontSize
                        family: app.customTextFont.name
                    }
                    onLinkActivated: {
                        linkColor = app.visitedLinkColor
                        webViewLoader.load(link)
                    }
                }

                Rectangle{
                    Layout.preferredHeight: app.units(16)
                    Layout.fillWidth: true
                    color: "transparent"
                }
            }

        }
    }

    function getAppIcon() {
        var resources = app.info.value("resources", {});
        var appIconPath = "", appIconFilePath = "";

        if (!resources) {
            resources = {};
        }

        if (resources.appIcon) {
            appIconPath = resources.appIcon;
        }

        //console.log("appIcon absolute path ", appIconPath, app.folder.filePath(appIconPath));

        var f = AppFramework.fileInfo(appIconPath)
        console.log(f.filePath, f.url, f.exists)

        if(f.exists) {
            appIconFilePath = "file:///" +app.folder.filePath(appIconPath);
        }

        return appIconFilePath;
    }

    Loader {
        id: webViewLoader

        anchors.fill: parent

        Component {
            id: webView

            Components.WebPage {
                id: webViewContent

                showHistory: false
                isDebug: false
                headerHeight: aboutPage.header.height
                headerColor: app.headerBackgroundColor

                onTransitionOutCompleted: {
                    visible = false
                }

                function load(url) {
                    visible = true
                    transitionIn(transition.bottomUp)
                    loadPage(url)
                }
            }
        }

        function load(url) {
            sourceComponent = webView
            item.load(url)
        }
    }

    onTransitionOutCompleted: {
        visible = false
    }

    function show () {
        visible = true
        transitionIn(transition.bottomUp)
    }

    function hide () {
        transitionOut(transition.topDown)
    }

}
