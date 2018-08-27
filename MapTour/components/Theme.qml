import QtQuick 2.3
import QtQuick.Controls 1.0
import ArcGIS.AppFramework 1.0

//pragma Singleton

QtObject {
    id: theme
    function units(num) {
        return num ? num*AppFramework.displayScaleFactor : 0
    }

    property real scaleFactor: AppFramework.displayScaleFactor

    // Dialog
    property int fontTitleSize: 20
    property int fontSubheaderSize: 16
    property int fontBodySize: 14
    property int fontCaptionSize: 10

    property color colorTitle: "#de000000"
    property color colorBody: "#de000000"
    property color colorButtonText: "#0079c1"
    property color colorButtonBorder: "#0079c1"
    property color colorButtonFilling: "#ffffff"
    property color colorDialogMask: "#80000000"
    property color colorDialogBack: "#ffffff"
    property color colorInk: "#190079c1"
    property color colorInkFocus: "#320079c1"
    property color colorProgress: "#0079c1"
    property color colorProgressBackground: "#f8f8f8"
    property color colorProgressBorder:"#efefef"
    property color colorToastText: "#ffffff"

    property string fontFamily: "AvenirNext-Medium"

}
