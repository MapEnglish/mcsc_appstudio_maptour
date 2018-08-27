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

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.4

import ArcGIS.AppFramework.Controls 1.0

import "components" as Components

Rectangle {
    signal signInClicked(string tourId)

    color: app.headerBackgroundColor

    AnimatedImage {
        anchors.fill: parent
        source: app.landingpageBackground
        fillMode: Image.PreserveAspectCrop
        visible: source > ""
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#77000000";}
            GradientStop { position: 1.0; color: "#00000000";}
        }
    }

    Text {
        id: titleText

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: app.height/10
        }

        font.family: app.customTitleFont.name

        text: app.info.title
        font {
            //pointSize: 60
            pointSize: app.titleFontSize * 1.4
        }
        color: app.titleColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Text {
        id: subtitleText
        anchors {
            left: parent.left
            right: parent.right
            top: titleText.bottom
            margins: 5*app.scaleFactor
            topMargin: 30*app.scaleFactor
        }

        font.family: app.customTitleFont.name

        text: app.info.snippet
        font {
            pointSize: app.subtitleFontSize
        }
        color: app.subtitleColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    Button {
        id: signInButton

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 60 * app.scaleFactor
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
            }
        }
        height: implicitHeight < app.units(56) ? app.units(56) : undefined // set minHeight = 64, otherwise let it scale by content height which is the default behavior
        width: Math.min(0.5 * parent.width, app.units(250))
        text: qsTr("Get Started")

        MouseArea{
            anchors.fill: parent
            onClicked: {
                signInClicked("");
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

//    ImageButton {

//        anchors {
//            right: parent.right
//            bottom: parent.bottom
//            margins: 5 * app.scaleFactor
//        }

//        checkedColor : "transparent"
//        pressedColor : "transparent"
//        hoverColor : "transparent"
//        glowColor : "transparent"

//        height: 30 * app.scaleFactor
//        width: 30 * app.scaleFactor

//        source: "images/info.png"

//        visible: app.showDescriptionOnStartup

//        onClicked: {
//            aboutPage.show()
//        }

//    }

    AboutPage {
        id: aboutPage
    }

    Connections {
        target: app

        onUrlParametersChanged: {
            if (app.urlParameters.hasOwnProperty("appid")) {
                signInClicked(app.urlParameters.appid)
            }
        }
    }

    Component.onCompleted: {
        signInButtonAnimation.start()
    }

}
