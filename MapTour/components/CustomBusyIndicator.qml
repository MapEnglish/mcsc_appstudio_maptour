import QtQuick 2.4
import QtQuick.Window 2.0
import QtQuick.Controls 1.3 as Controls
import QtQuick.Controls.Styles 1.3 as Styles
import ArcGIS.AppFramework 1.0


Item {
    id: root
    property color color: "white"
    property color busyColor: "darkorange"
    property int radius: units(4)
    property alias backGroundContainer: container

    width: units(72)
    height: width

    visible: false
    anchors.centerIn: parent
    z:111

    Rectangle {
        id: container
        color: root.color
        radius: root.radius
        anchors.fill: parent
    }

    function units(num) {
        return num? num*AppFramework.displayScaleFactor : num
    }

    Controls.ProgressBar {
        id: progressBar

        property color color: root.busyColor

        property real dashThickness: units(3)

        width: root.width/2
        height: root.width/2

        anchors.centerIn: parent

        indeterminate: true

        style: Styles.ProgressBarStyle {
            id: progressBarStyle

            progress: Item {
                anchors.fill: parent

                Canvas {
                    id: canvas

                    property int ratio: Screen.devicePixelRatio

                    width: parent.width * ratio
                    height: parent.height * ratio
                    anchors.centerIn: parent

                    scale: 1/ratio

                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    renderStrategy: Canvas.Threaded
                    antialiasing: true
                    onPaint: drawSpinner();

                    opacity:  visible ? 1.0 : 0

                    Behavior on opacity {
                        PropertyAnimation {
                            duration: 800
                        }
                    }

                    Connections {
                        target: control
                        onColorChanged: canvas.requestPaint()
                        onValueChanged: canvas.requestPaint()
                        onDashThicknessChanged: canvas.requestPaint()
                        onIndeterminateChanged:
                        {
                            if(control.indeterminate)
                            {
                                internal.arcEndPoint = 0
                                internal.arcStartPoint = 0
                                internal.rotate = 0
                            }

                            canvas.requestPaint();
                        }
                    }

                    QtObject {
                        id: internal

                        property real arcEndPoint: 0
                        onArcEndPointChanged: canvas.requestPaint();

                        property real arcStartPoint: 0
                        onArcStartPointChanged: canvas.requestPaint();

                        property real rotate: 0
                        onRotateChanged: canvas.requestPaint();

                        property real longDash: 3 * Math.PI / 2
                        property real shortDash: 19 * Math.PI / 10
                    }

                    NumberAnimation {
                        target: internal
                        properties: "rotate"
                        from: 0
                        to: 2 * Math.PI
                        loops: Animation.Infinite
                        running: control.indeterminate && canvas.visible
                        easing.type: Easing.Linear
                        duration: 3000
                    }

                    SequentialAnimation {
                        running: control.indeterminate && canvas.visible
                        loops: Animation.Infinite

                        ParallelAnimation {
                            NumberAnimation {
                                target: internal
                                properties: "arcEndPoint"
                                from: 0
                                to: internal.longDash
                                easing.type: Easing.InOutCubic
                                duration: 800
                            }

                            NumberAnimation {
                                target: internal
                                properties: "arcStartPoint"
                                from: internal.shortDash
                                to: 2 * Math.PI - 0.001
                                easing.type: Easing.InOutCubic
                                duration: 800
                            }
                        }

                        ParallelAnimation {
                            NumberAnimation {
                                target: internal
                                properties: "arcEndPoint"
                                from: internal.longDash
                                to: 2 * Math.PI - 0.001
                                easing.type: Easing.InOutCubic
                                duration: 800
                            }

                            NumberAnimation {
                                target: internal
                                properties: "arcStartPoint"
                                from: 0
                                to: internal.shortDash
                                easing.type: Easing.InOutCubic
                                duration: 800
                            }
                        }
                    }

                    function drawSpinner() {
                        var ctx = canvas.getContext("2d");
                        ctx.reset();
                        ctx.clearRect(0, 0, canvas.width, canvas.height);
                        ctx.strokeStyle = control.color
                        ctx.lineWidth = control.dashThickness * canvas.ratio
                        ctx.lineCap = "butt";

                        ctx.translate(canvas.width / 2, canvas.height / 2);
                        ctx.rotate(control.indeterminate ? internal.rotate : currentProgress * (3 * Math.PI / 2));

                        ctx.arc(0, 0, Math.max(0, Math.min(canvas.width, canvas.height) / 2 - ctx.lineWidth),
                                control.indeterminate ? internal.arcStartPoint : 0,
                                                        control.indeterminate ? internal.arcEndPoint : currentProgress * (2 * Math.PI),
                                                                                false);

                        ctx.stroke();
                    }
                }
            }

            property Component panel: Item{
                implicitWidth: backgroundLoader.implicitWidth
                implicitHeight: backgroundLoader.implicitHeight

                Item {
                    width: parent.width
                    height: parent.height
                    transformOrigin: Item.TopLeft

                    Rectangle {
                        id: backgroundLoader
                        implicitWidth: control.width
                        implicitHeight: control.height
                        color: "transparent"
                    }

                    Loader {
                        sourceComponent: progressBarStyle.progress
                        anchors.topMargin: padding.top
                        anchors.leftMargin: padding.left
                        anchors.rightMargin: padding.right
                        anchors.bottomMargin: padding.bottom

                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        width: parent.width - padding.left - padding.right
                    }
                }
            }
        }
    }

}
