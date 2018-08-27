import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0



Popup {
    id: root

    property int defaultMargin: units(16)
    property color textColor: "#FFFFFF"
    property real heightOffset: app.heightOffset

    padding: 0
    Material.background: "#323232"

    width: Math.min(units(568), parent.width)
    height: message.lineCount * units(48) + heightOffset
    y: parent.height - root.height
    x: (parent.width - root.width)/2

    enter: Transition {
        NumberAnimation {
            property: "y"
            from: parent.height
            to: parent.height - root.height
            duration: 200
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "y"
            from: parent.height - root.height
            to: parent.height
            duration: 200
        }
    }

    BaseText {
        id: message

        anchors.centerIn: parent
        width: parent.width
        topPadding: 0
        bottomPadding: heightOffset
        leftPadding: defaultMargin
        rightPadding: defaultMargin
        color: textColor
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        maximumLineCount: 2
    }

    Timer {
        id: timer

        interval: 4000
        running: false
        repeat: false

        onTriggered: {
            close()
        }
    }

    onVisibleChanged: {
        if (!visible) {
            message.text = ""
        }
    }

    function show (text) {
        message.text = text
        root.open()
        root.visible = true
        timer.start()
    }

    function hide () {
        close()
    }

    function units (num) {
        return num ? num * AppFramework.displayScaleFactor : num
    }
}
