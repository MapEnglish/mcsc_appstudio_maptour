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
    id: learnMorePage

    property var pageData: {"description":"", "modified":""}

    isDebug: false
    visible: false
    headerHeight: 50 * app.scaleFactor

    header: Rectangle {
        anchors.fill: parent
        color: app.headerBackgroundColor

        Text {
            id: titleText

            text: qsTr("Learn More")
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
                learnMorePage.hide()
            }
        }
    }

    content: Pane {
        anchors.fill: parent
        padding: 0
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

                property bool hasTitle: false
                property bool hasSnippet: false
                property bool hasDescription: false

                Layout.fillHeight: true

                Connections {
                    target: learnMorePage
                    onPageDataChanged: {
                        if (typeof learnMorePage.pageData.title !== "undefined") {
                            columnContainer.hasTitle = pageData.title>""
                        } else {
                            columnContainer.hasTitle = false
                        }

                        if (typeof learnMorePage.pageData.snippet !== "undefined") {
                            columnContainer.hasSnippet = pageData.snippet>""
                        } else {
                            columnContainer.hasSnippet = false
                        }

                        if (typeof learnMorePage.pageData.description !== "undefined") {
                            columnContainer.hasDescription = pageData.description>""
                        } else {
                            columnContainer.hasDescription = false
                        }
                    }
                }

                width: app.isPortrait ? Math.min(units(400), parent.width) : Math.min(units(600), parent.width)

                spacing: app.units(5)

                Image{
                    Layout.fillWidth: true
                    Layout.topMargin: app.units(30)
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    source: getThumbnail() || ""
                    visible: source > ""
                }

                Rectangle{
                    visible: columnContainer.hasTitle
                    Layout.preferredHeight: 20*app.scaleFactor
                    Layout.fillWidth: true
                    color: "transparent"
                }

                Text {
                    text: columnContainer.hasTitle ? pageData.title : ""
                    visible: columnContainer.hasTitle
                    color: app.textColor
                    font.pointSize: app.baseFontSize
                    font.bold: true
                    font.family: app.customTitleFont.name
                    anchors.horizontalCenter: parent.horizontalCenter
                    Layout.preferredWidth: parent.width-20*app.scaleFactor
                    wrapMode: Text.Wrap
                }

                Text {
                    text: columnContainer.hasSnippet ? pageData.snippet : ""
                    visible: columnContainer.hasSnippet
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
                        webViewLoader.load(link)
                    }
                }

                Rectangle{
                    visible: columnContainer.hasSnippet
                    Layout.preferredHeight: 20*app.scaleFactor
                    Layout.fillWidth: true
                    color: "transparent"
                }

                Text{
                    text: qsTr("Description") + ":"
                    visible: columnContainer.hasDescription
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
                    text: pageData.description
                    visible: columnContainer.hasDescription
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
                        webViewLoader.load(link)
                    }
                }

                Rectangle{
                    visible: columnContainer.hasDescription
                    Layout.preferredHeight: 20*app.scaleFactor
                    Layout.fillWidth: true
                    color: "transparent"
                }

                Text{
                    text: qsTr("Last updated") + ":"
                    visible: pageData.modified>""
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
                    id: dateText

                    text: capitalizeFirstLetter(qsTr("%1 %2 %3").arg(new Date(pageData.modified).toLocaleDateString(Qt.locale)).arg(qsTr("by")).arg(pageData.owner))
                    visible: pageData.modified>""
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
                        webViewLoader.load(link)
                    }

                    function capitalizeFirstLetter(string) {
                        return string.charAt(0).toUpperCase() + string.slice(1);
                    }
                }

                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle{
                    visible: pageData.modified>""
                    Layout.preferredHeight: 20*app.scaleFactor
                    Layout.fillWidth: true
                    color: "transparent"
                }
            }
        }
    }

    function getThumbnail() {
        var urlFormat = "%1/sharing/rest/content/items/%2/info/%3",
            urlPrefix = ""
        if (typeof pageData.largeThumbnail !== "undefined") {
            if (pageData.largeThumbnail) {
                return app.tourManager.networkCacheManager.cache(urlFormat.arg(app.portalUrl).arg(pageData.id).arg(pageData.largeThumbnail))
            }
        }
        return app.tourManager.networkCacheManager.cache(pageData.thumbnailUrl)
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
                headerHeight: learnMorePage.header.height
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

    Component.onDestruction: {
        //console.log("Page destroyed!")
    }

    function show (results) {
        learnMorePage.pageData = results
        visible = true
        transitionIn(transition.bottomUp)
    }

    function hide () {
        transitionOut(transition.topDown)
    }

}
