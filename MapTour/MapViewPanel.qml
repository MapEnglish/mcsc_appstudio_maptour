import QtQuick 2.5
import QtQuick.Controls 1.1
import QtQuick.Controls 2.2 as NewControls
import QtPositioning 5.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQuick.Window 2.0
import QtQuick.Controls.Styles 1.4

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0

import "components" as Components

NewControls.Pane {
    id: panel

    property real defaultMargin: app.units(16)
    property real midSizeThreshold: app.units(600)
    property real maxHeight: parent.height - 2 * defaultMargin
    property bool panelThreshold: !app.isSmallScreen //(app.width >= midSizeThreshold) //&& !app.isPortrait
    property color backgroundColor: Qt.lighter(app.pageBackgroundColor) //panelThreshold ? "#FAFAFA" : "#000000"
    property color pictureBackgroundColor: backgroundColor  //panelThreshold ? "#FAFAFA" : "transparent"
    property color headerBackgroundColor: Qt.darker(backgroundColor, 1.1)//panelThreshold ? "#E8E8E8" : "transparent"
    property color baseTextColor: photoMode || panelMode ? app.textColor : "#FFFFFF"
    property color iconColor: baseTextColor //panelThreshold ? baseTextColor : "#FFFFFF"
    property color labelBackgroundColor: "transparent"

    property bool showDetails: true
    property bool isZooming: false

    padding: 0
    bottomPadding: (!panelThreshold || photoMode || (!app.isPortrait && !panelThreshold))? app.heightOffset : 0

    property alias screenSize: screenSizeState
    Item {
        id: screenSizeState

        states: [
            State {
                name: "SMALLSIZE_THRESHOLD"
                when: panelThreshold

                PropertyChanges {
                    target: panel
                    width: parent.width < 800 ? 0.45 * parent.width : 0.33 * parent.width
                    height: parent.height - 2 * banner.height - app.heightOffset
                    anchors {
                        bottom: panel.parent.bottom
                        //margins: panel.defaultMargin
                        //topMargin: 0.5 * panel.defaultMargin + bannerHeight
                        leftMargin: app.isIphoneX && !app.isPortrait ? app.widthOffset : 0.5 * panel.defaultMargin
                        bottomMargin: app.height > maxHeight ? app.height - maxHeight : panel.defaultMargin
                    }
                }

                PropertyChanges {
                    target: tourPage
                    panelMode: true
                }

                PropertyChanges {
                    target: buttonBar
                    visible: true
                }

                PropertyChanges {
                    target: banner
                    height: app.headerHeight
                }

                PropertyChanges {
                    target: sortButton
                    visible: true
                }

                PropertyChanges {
                    target: infoButton
                    visible: true
                }

                PropertyChanges {
                    target: menuButton
                    visible: true
                }
            }
        ]
    }

    Connections {
        target: tourPage //parent

        onPhotoModeChanged: {
            isPhotoFullScreen = photoMode && panelThreshold
        }
    }

    onPanelThresholdChanged: {
        isPhotoFullScreen = photoMode && panelThreshold
        if (isPhotoFullScreen) {
            featuresList.expand()
        }
    }

    visible: tourItemsListModel.count > 0 && (mapMode || photoMode || (panelThreshold && mapMode)) ? true : false

    anchors {
        left: parent.left
        //right: parent.right
        bottom: parent.bottom
        //margins: panelThreshold ? app.units(20) : 0
    }

    height: photoMode ? (parent.height - banner.height) : parent.height/3
    width: parent.width

    background: Rectangle {
        color: backgroundColor
    }
    //color: app.headerBackgroundColor

    //--------------------------

    Rectangle {
        id: delegateHeader

        width: (photoMode || panelMode) ? parent.width : featuresList.delegateWidth
        height: (photoMode || panelMode) ? bannerHeight : 0.8*bannerHeight
        z: 10
        anchors {
            top: featuresListDelegate.top
            horizontalCenter: parent.horizontalCenter
        }
        color: (photoMode || panelMode) ? headerBackgroundColor : "transparent"
        Rectangle {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width
            height: parent.height
            visible: !photoMode && !panelMode
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#66000000";}
                GradientStop { position: 1.0; color: "#22000000";}
            }
        }
        MouseArea {
            anchors.fill: parent
            preventStealing: true
        }

        Item {
            opacity: (showDetails && visible)? 1 : 0
            Behavior on opacity {
                OpacityAnimator {
                    duration: 100
                }
            }
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: photoMode ? app.widthOffset : 0
            }
            height: 35 * app.scaleFactor
            width: 35 * app.scaleFactor

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                Image {
                    id: expandButton

                    visible: (!panelThreshold) || photoMode
                    source: photoMode ? "images/close.png" : "images/back-left.png"
                    rotation: photoMode ? 270 : 90
                    height: 30* app.scaleFactor
                    width: 30* app.scaleFactor
                    anchors.centerIn: parent
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log(" **** expand button clicked : " + currentPhotoIndex);
                            if(showDetails) {
                                featuresList.expand()
                                if (mapViewPanel.screenSize.state === "" && panelThreshold) {
                                    mapViewPanel.screenSize.state = "SMALLSIZE_THRESHOLD"
                                    app.width = app.width - 0.01 // trigger the resizing of the panel (since state change is not trigerring it)
                                    app.width = app.width + 0.01
                                }
                            }
                        }
                    }
                }

                ColorOverlay {
                    anchors.fill: source
                    source: expandButton
                    color: iconColor
                    rotation: source.rotation
                    visible: source.visible
                }
            }

        }

        Rectangle {
            id: itemCountBackground
            opacity: (showDetails && visible)? 1 : 0

            Behavior on opacity {
                OpacityAnimator {
                    duration: 100
                }
            }
            anchors {
                centerIn: parent
            }
            color: "transparent"
            height: 35 * app.scaleFactor
            width: leftButton.width + rightButton.width + itemCountBanner.contentWidth + 20*AppFramework.displayScaleFactor

            GridLayout {
                columns: 3
                anchors {
                    centerIn: parent
                }

                Item {
                    id: leftButton

                    Layout.preferredHeight: 36 * app.scaleFactor
                    Layout.preferredWidth: 36 * app.scaleFactor
                    Layout.rightMargin: 10
                    opacity: currentPhotoIndex > 0 ? 1 : 0.3

                    Image {
                        id: leftButtonImg
                        source: "images/back-left.png"
                        anchors.fill: parent
                    }

                    ColorOverlay {
                        anchors.fill: leftButtonImg
                        source: leftButtonImg
                        color: iconColor
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if(showDetails) {
                                featuresList.goLeft()
                            }
                        }
                    }
                }

                Text {
                    id: itemCountBanner
                    font.family: app.customTitleFont.name
                    text: {
                        var index = currentPhotoIndex < 0 ? 0 : currentPhotoIndex
                        return (index+1) + strings.kOf + featuresList.count
                    }

                    color: baseTextColor
                    font {
                        pointSize: app.baseFontSize
                    }
                }

                Item {
                    id: rightButton

                    Layout.preferredHeight: 36 * app.scaleFactor
                    Layout.preferredWidth: 36 * app.scaleFactor
                    Layout.leftMargin: 10
                    rotation: 180
                    opacity: currentPhotoIndex < featuresList.count-1 ? 1 : 0.3

                    Image {
                        id: rightButtonImg
                        source: "images/back-left.png"
                        anchors.fill: parent
                    }

                    ColorOverlay {
                        anchors.fill: rightButtonImg
                        source: rightButtonImg
                        color: iconColor
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if(showDetails) {
                                featuresList.goRight()
                            }
                        }
                    }
                }
            }
        }

    }

    function closePhoto () {
        featuresList.expand()
        if (mapViewPanel.screenSize.state === "" && mapViewPanel.panelThreshold) {
            mapViewPanel.screenSize.state = "SMALLSIZE_THRESHOLD"
            app.width = app.width - 0.01 // trigger the resizing of the panel (since state change is not trigerring it)
            app.width = app.width + 0.01
        }
    }

    //----------------------
    property alias featuresList: featuresList
    ListView {
        id: featuresList

        anchors.fill: parent
        anchors.topMargin:  (photoMode || panelMode) ? delegateHeader.height : 0
        spacing: 0
        orientation: ListView.Horizontal
        height: panel.height

        //visible: mapMode || photoMode

        //interactive: true

        focus: true
        clip: true

        snapMode: ListView.SnapOneItem
        preferredHighlightBegin: 0;
        preferredHighlightEnd: 0  //this line means that the currently highlighted item will be central in the view
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true  //updates the current index property to match the currently highlighted item
        highlightResizeDuration: 10
        highlightResizeVelocity: 2000
        highlightMoveVelocity: 2000
        highlightMoveDuration: 10

        currentIndex: -1

        //key board support
        Keys.onLeftPressed: {
            console.log("left key pressed");
            if (currentIndex > 0 ) {
                currentIndex = currentIndex-1;
            }
            //onGraphicClickHandler(currentIndex);
            onPhotoClickHandler(currentIndex)
        }
        Keys.onRightPressed: {
            console.log("right key pressed");
            if (currentIndex < count) {
                currentIndex = currentIndex+1;
            }
            //onGraphicClickHandler(currentIndex);
            onPhotoClickHandler(currentIndex)
        }
        Keys.onEnterPressed: {
            console.log("enter key pressed ", currentIndex);
            //onGraphicClickHandler(currentIndex);
            onPhotoClickHandler(currentIndex)
        }

        Keys.onReturnPressed: {
            console.log("return key pressed ", currentIndex);
            //onGraphicClickHandler(currentIndex);
            onPhotoClickHandler(currentIndex)
        }

        //---------------------

        model:tourItemsListModel

        //----------------------

        function goRight () {
            var index = currentPhotoIndex
            console.log(" **** right arrow Clicked : " + index);
            if (index < featuresList.count-1) {
                featuresList.positionViewAtIndex(index+1,ListView.Center);
                featuresList.currentIndex = index+1;
                //onGraphicClickHandler(index+1);
                onPhotoClickHandler(index+1)
            }
        }

        function goLeft () {
            var index = currentPhotoIndex
            console.log(" **** left arrow clicked : " + index);
            if(index > 0) {
                featuresList.positionViewAtIndex(index-1,ListView.Center);
                featuresList.currentIndex = index-1;
                //onGraphicClickHandler(index-1);
                onPhotoClickHandler(index-1)
            }
        }

        function expand() {
            photoMode = !photoMode
            featuresList.positionViewAtIndex(currentPhotoIndex,ListView.Center);
            featuresList.currentIndex = currentPhotoIndex;
            //onGraphicClickHandler(currentPhotoIndex);
            onPhotoClickHandler(currentIndex)
        }

        property int delegateWidth: (function(){
            var value = 100;

            if(photoMode || panelMode) {
                value = Math.min(parent.width, 1024*app.scaleFactor)
            } else {
                value = isSmallScreen ? parent.width : featuresList.height*1.5
            }

            return value;
        })();

        Component {
            id: featuresListDelegate

            Rectangle {
                id: itemOuterBox

                color: backgroundColor
                height: featuresList.height
                width: featuresList.delegateWidth
                clip: true

                Rectangle {
                    id: photoFrame

                    property bool supportsRotation: true

                    Behavior on scale { NumberAnimation { duration: 200 } }
                    Behavior on rotation { NumberAnimation { duration: 200 } }
                    Behavior on x { NumberAnimation { duration: 200 } }
                    Behavior on y { NumberAnimation { duration: 200 } }

                    width: parent.width
                    height: panelMode ? (9/16) * parent.width : (photoMode ? itemOuterBox.height * (app.isSmallScreen ? 4/7 : 8/9) : itemOuterBox.height - 3*app.scaleFactor)
                    color: pictureBackgroundColor
                    scale: 1
                    smooth: true
                    antialiasing: true

                    Image {
                        id: itemImage

                        anchors.fill: parent
                        asynchronous: true
                        source: app.tourManager.networkCacheManager.cache((photoMode || panelMode) ? (is_video ? thumb_url : pic_url) : thumb_url, "", null)
                        smooth: true
                        fillMode: (photoMode) ? Image.PreserveAspectFit : Image.PreserveAspectCrop

                        onStatusChanged: if (itemImage.status == Image.Error) itemImage.source = "images/placeholder.jpg"

                        // -------- label ------------
                        Rectangle {
                            anchors {
                                left: itemImage.left
                                top: itemImage.top
                                topMargin: 3*app.scaleFactor
                                leftMargin: 3*app.scaleFactor
                            }
                            visible: !photoMode && !app.isSmallScreen && !panelMode
                            radius: 2*app.scaleFactor
                            height: cardItemNumber.contentHeight + 4*app.scaleFactor
                            width: cardItemNumber.contentWidth + 8*app.scaleFactor

                            color: app.customRenderer?pageHelper.getColorName(icon_color): "#000000"
                            opacity: 0.9;
                            z:1

                            Text {
                                id: cardItemNumber
                                text: index + 1
                                color: baseTextColor
                                anchors {
                                    centerIn: parent
                                }
                                font {
                                    pointSize: app.baseFontSize
                                }
                                font.family: app.customTextFont.name
                            }
                        }
                        // -------- label ------------

                        PinchArea {
                            id: pinchArea

                            property real minScale: 1
                            property real maxScale: 4
                            property bool enableRotation: false

                            anchors.fill: parent
                            //visible: photoMode && !is_video //&& imageZoom.checked
                            enabled: photoMode && !is_video
                            pinch.target: photoFrame
                            pinch.minimumRotation: enableRotation ? -360 : 0
                            pinch.maximumRotation: enableRotation ? 360 : 0
                            pinch.minimumScale: minScale
                            pinch.maximumScale: maxScale
                            pinch.dragAxis: Pinch.XAndYAxis
                            //pinch.minimumX: -Math.abs(itemOuterBox.width - photoFrame.scale * itemImage.sourceSize.width)/2
                            //pinch.maximumX: +Math.abs(itemOuterBox.width - photoFrame.scale * itemImage.sourceSize.width)/2
                            pinch.minimumX: -Math.abs(itemImage.width - photoFrame.scale * itemImage.width)/2
                            pinch.maximumX: +Math.abs(itemImage.width - photoFrame.scale * itemImage.width)/2
                            pinch.minimumY: -Math.abs(itemImage.height - photoFrame.scale * itemImage.height)/2
                            pinch.maximumY: +Math.abs(itemImage.height - photoFrame.scale * itemImage.height)/2

                            onSmartZoom: {
                                if (pinch.scale > 0) {
                                    photoFrame.rotation = 0;
                                    photoFrame.scale = Math.min(itemOuterBox.width, itemOuterBox.height) / Math.max(itemImage.sourceSize.width, itemImage.sourceSize.height) * 0.85
                                    photoFrame.x = itemOuterBox.x + (itemOuterBox.width - photoFrame.width) / 2
                                    photoFrame.y = itemOuterBox.y + (itemOuterBox.height - photoFrame.height) / 2
                                } else {
                                    photoFrame.rotation = pinch.previousAngle
                                    photoFrame.scale = pinch.previousScale
                                    photoFrame.x = pinch.previousCenter.x - photoFrame.width / 2
                                    photoFrame.y = pinch.previousCenter.y - photoFrame.height / 2
                                }
                            }

                            onPinchFinished: {
                                if(scale<minScale) photoFrame.scale=minScale;
                                photoFrame.rotation = Math.round(photoFrame.rotation/90)*90
                            }

                            SwipeArea {
                                id: swipeArea

                                enableDrag: (photoFrame.scale > pinchArea.minScale) || (photoFrame.x !== 0) || (photoFrame.y !== 0)

                                anchors.fill: parent
                                drag.target: photoFrame
                                drag.axis:  !enableDrag ? Drag.None : Drag.XAndYAxis
                                drag.minimumX: -Math.abs(itemImage.width - photoFrame.scale * itemImage.width)/2
                                drag.maximumX: +Math.abs(itemImage.width - photoFrame.scale * itemImage.width)/2
                                drag.minimumY: -Math.abs(itemImage.height - photoFrame.scale * itemImage.height)/2
                                drag.maximumY: +Math.abs(itemImage.height - photoFrame.scale * itemImage.height)/2
                                scrollGestureEnabled: false

                                onWheel: {
                                    if (wheel.modifiers & Qt.ControlModifier) {
                                        photoFrame.rotation += wheel.angleDelta.y / 120 * 5
                                        if (Math.abs(photoFrame.rotation) < 4)
                                            photoFrame.rotation = 0
                                    } else {
                                        photoFrame.rotation += wheel.angleDelta.x / 120;
                                        if (Math.abs(photoFrame.rotation) < 0.6)
                                            photoFrame.rotation = 0
                                        var scaleBefore = photoFrame.scale;
                                        var currentScale = photoFrame.scale + photoFrame.scale * wheel.angleDelta.y / 120 / 10
                                        if (currentScale > pinchArea.maxScale) {
                                            photoFrame.scale = pinchArea.maxScale
                                        } else if (currentScale < pinchArea.minScale) {
                                            photoFrame.scale = pinchArea.minScale
                                        } else {
                                            photoFrame.scale = currentScale
                                        }

                                    }
                                }

                                onClicked: {
                                    if (!panelThreshold && (index === currentPhotoIndex) && !photoMode) {
                                        photoMode = true
                                        return
                                    }

                                    console.log(" **** Photo Clicked : " + index );
                                    featuresList.positionViewAtIndex(index,ListView.Center );
                                    featuresList.currentIndex = index;
                                    //onGraphicClickHandler(index);
                                    onPhotoClickHandler(index)

                                    if(photoMode) {
                                        showDetails = !showDetails

                                        //console.log("isPhotoFullScreen", isPhotoFullScreen)
                                    }

                                    if (panelMode) {
                                        photoMode = true
                                        mapViewPanel.screenSize.state = ""
                                    }
                                }

                                onDoubleClicked: {
                                    console.log(" %%%% Photo Double Clicked : " + index);
                                    if (photoMode && !is_video) {
                                        var midScale = (pinchArea.maxScale - pinchArea.minScale)/2
                                        if (photoFrame.scale < midScale) {
                                            photoFrame.scale = Math.min(photoFrame.scale + midScale/2, pinchArea.maxScale)
                                        } else {
                                            photoFrame.scale = pinchArea.minScale
                                        }
                                        photoFrame.x = 0
                                        photoFrame.y = 0
                                    }
                                    console.log("Double clicked")
                                    //featuresList.positionViewAtIndex(index,ListView.Center);
                                    //featuresList.currentIndex = index;
                                }

                                onReleased: {
                                    if(scale<pinchArea.minScale) photoFrame.scale=pinchArea.minScale;
                                    photoFrame.rotation = Math.round(photoFrame.rotation/90)*90
                                }

                                onSwipe: {
                                    console.log("###Tourpage:: Swipe gesture : ", direction)
                                    if(direction === "up" && !panelThreshold) {
                                        //photoMode = true
                                    }

                                    if(direction === "down" && !panelThreshold) {
                                        //photoMode = false
                                    }
                                }
                            }
                        }

                        Rectangle {
                            id: itemTextBackground
                            anchors {
                                bottom: parent.bottom
                                left: parent.left
                            }
                            width: itemImage.width
                            height: title.contentHeight + app.units(10)
                            visible: !photoMode && app.isPortrait && app.isSmallScreen

                            gradient: Gradient {
                                GradientStop { position: 1.0; color: "#77000000";}
                                GradientStop { position: 0.0; color: "#22000000";}
                            }

                            Text {
                                id: title

                                font.family: app.customTitleFont.name
                                text: name
                                color: app.titleColor
                                textFormat: Text.StyledText
                                font.bold: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                maximumLineCount: photoMode ? 3 : 2
                                elide: Text.ElideNone
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                    margins: 8 * app.scaleFactor
                                }
                                font {
                                    pointSize: app.baseFontSize
                                }
                                width: parent.width
                                linkColor: app.linkColor

                                onLinkActivated: {
                                    app.openUrlInternally(link);
                                }
                            }
                        }

                    }

                    Image {
                        id: playVideoImage
                        anchors.centerIn: parent
                        visible: (photoMode || panelMode) && is_video
                        source: "images/video.png"
                        width: 100*app.scaleFactor
                        height: 100*app.scaleFactor
                        z:25
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var component = videoPageComponent,
                                        videoPage = component.createObject(tourPage)
                                videoPage.load(pic_url)
                            }
                        }
                    }

                    Text {
                        visible: (photoMode || panelMode) && is_video
                        text: strings.kOpenVideo
                        font.bold: true
                        font.family: app.customTextFont.name
                        color: baseTextColor

                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        anchors {
                            top: playVideoImage.bottom
                            topMargin: 15*app.scaleFactor
                        }
                        font {
                            pointSize: app.baseFontSize
                        }
                        wrapMode: Text.Wrap
                        textFormat: Text.StyledText
                        linkColor: app.linkColor

                    }

                    BusyIndicator {
                        visible: itemImage.status !== (Image.Ready || Image.Error)
                        anchors.centerIn: parent
                    }

                    Connections {
                        target: tourPage

                        onPhotoModeChanged: {
                            photoFrame.reset()
                        }
                    }

                    onScaleChanged: {
                        if (scale > pinchArea.minScale) {
                            isZooming = true
                        } else {
                            isZooming = false
                        }
                    }

                    Component.onCompleted: {
                        if (scale > pinchArea.minScale) {
                            isZooming = true
                        } else {
                            isZooming = false
                        }
                    }

                    function reset () {
                        scale = pinchArea.minScale
                        x = 0
                        y = 0
                    }
                }

                Rectangle {
                    id: descriptionArea

                    color: backgroundColor
                    visible: !isZooming

                    onVisibleChanged: {
                        if (visible) {
                            photoFrame.reset()
                        }
                    }

                    anchors {
                        left: parent.left
                        right: parent.right
                        //top: photoFrame.bottom
                        bottom: parent.bottom
                    }

                    height: itemOuterBox.height - photoFrame.height

                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true
                        onClicked: showDetails = !showDetails
                    }

                    Flickable {

                        anchors.fill: parent

                        MouseArea {
                            anchors.fill: parent
                            onWheel: {
                                wheel.accepted = false // set to true to prevent scrolling of map
                            }
                            propagateComposedEvents: true
                        }

                        interactive: !isPhotoFullScreen || (isPhotoFullScreen && flickableDescription.hasAudio)
                        //contentHeight: panelThreshold ? flickableDescription.contentHeight + directionLabels.height + app.units(80) : app.units(80)
                        contentHeight: flickableDescription.height + directionLabels.height + audioPlayer.height + app.units(80)
                        clip: true

                        Item {
                            anchors.fill: parent
                            //--------------

                            ColumnLayout {
                                id: pictureText

                                Behavior on opacity {
                                    OpacityAnimator {
                                        duration: 100
                                    }
                                }

                                opacity: showDetails ? 1 : 0
                                visible: opacity

                                width: parent.width //Math.min(parent.width, app.units(800))
                                //height: parent.height
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 0
                                Layout.bottomMargin: 20*app.scaleFactor

                                Rectangle {
                                    id: directionLabels

                                    visible: !isPhotoFullScreen
                                    Layout.preferredWidth: Math.min(parent.width, app.units(800))
                                    Layout.preferredHeight: 28*app.scaleFactor
                                    color: "transparent"

                                    DistanceLabel {
                                        id: distanceLabel
                                        visible: app.showDistance && app.canUseDistance && (photoMode || panelMode)
                                        showDistanceIcon: true
                                        useThreshold: false
                                        distanceComputed: distance
                                        radius: 2 * app.scaleFactor
                                        height: 20*app.scaleFactor
                                        textBackgroundColor: labelBackgroundColor
                                        textColor: baseTextColor
                                        opacity: 0.6
                                        fontPointSize: app.subscriptFontSize
                                        anchors {
                                            left: parent.left
                                            verticalCenter: parent.verticalCenter
                                            leftMargin: app.units(4)
                                            right: undefined
                                        }
                                    }

                                    AddressLabel {
                                        address: location
                                        visible: (photoMode || panelMode)
                                        height: 20*app.scaleFactor
                                        width: parent.width - distanceLabel.width
                                        radius: 2 * app.scaleFactor
                                        textBackgroundColor: labelBackgroundColor
                                        textColor: baseTextColor
                                        opacity: 0.6
                                        fontPointSize: app.subscriptFontSize

                                        anchors {
                                            right: parent.right
                                            verticalCenter: parent.verticalCenter
                                            rightMargin: app.units(4)
                                        }
                                    }
                                }

                                Rectangle {
                                    id: itemNameBackground

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: itemName.contentHeight + 10
                                    Layout.leftMargin: app.units(4)
                                    color: "transparent"

                                    Text {
                                        id: itemName

                                        font.family: app.customTitleFont.name
                                        text: name
                                        color: baseTextColor
                                        textFormat: Text.StyledText
                                        //font.bold: (photoMode || panelMode)
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        maximumLineCount: 2
                                        elide: Text.ElideNone
                                        anchors {
                                            centerIn: parent
                                        }
                                        font {
                                            pointSize: app.baseFontSize
                                            bold: true
                                        }
                                        width: Math.min(parent.width, app.units(800)) - 2 * app.units(4)
                                        //horizontalAlignment: photoMode && !app.isSmallScreen ? Text.AlignHCenter : undefined
                                        verticalAlignment: Text.AlignVCenter
                                        linkColor: app.linkColor

                                        onLinkActivated: {
                                            app.openUrlInternally(link);
                                        }
                                    }
                                }

                                Text {
                                    id: flickableDescription

                                    property bool hasAudio: description.indexOf("<audio") > -1

                                    visible: !isPhotoFullScreen

                                    font.family: app.customTextFont.name
                                    text: {
                                        if (hasAudio) {
                                            return description.replace(/(<audio\b[^>][\s\S]+<\/audio>)/gi, "")
                                        } else {
                                            return description
                                        }
                                    }

                                    wrapMode: Text.Wrap
                                    textFormat: Text.StyledText
                                    Layout.fillWidth: true
                                    //visible: photoMode && description.length > 0
                                    font {
                                        pointSize: app.baseFontSize
                                    }
                                    Layout.margins: 8*app.scaleFactor
                                    color: baseTextColor
                                    linkColor: app.linkColor
                                    onLinkActivated: {
                                        app.openUrlInternally(link);
                                    }
                                }

                                Components.AudioPlayer {
                                    id: audioPlayer

                                    source: {
                                        if (flickableDescription.hasAudio) {
                                            var regex = /<source.*?src='(.*?)'/,
                                                    src = regex.exec(description)[1]
                                            return src
                                        } else {
                                            return ""
                                        }
                                    }
                                    primaryColor: Qt.lighter(app.headerBackgroundColor, 2.5)
                                    visible: description.indexOf("<audio") > -1
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: parent.width - app.units(16)
                                    Layout.bottomMargin: app.units(8)
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width
                                    color: "transparent"
                                }
                            }
                        } //--- item
                    } // ---- flickable
                }
                //------------ highlight -----------------
                Rectangle {
                    id: highlight
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: app.units(2)
                    color: app.selectColor
                    visible: (currentPhotoIndex === index) && (mapMode && !photoMode)
                }
                //---------- end highlight ----------------
            }
            //------ end of outerbox ---
        }
        delegate: featuresListDelegate

        onFlickEnded: {
            //console.log("flick ended at ", contentX, contentY  , indexAt(contentX, contentY));
            currentIndex = indexAt(contentX, contentY);
            //onGraphicClickHandler(currentIndex);
            onPhotoClickHandler(currentIndex)
        }
    }

    Component {
        id: videoPageComponent

        Components.WebPage {
            id: videoPage

            showHistory: false
            isDebug: false
            headerHeight: bannerHeight
            headerColor: app.headerBackgroundColor

            function load(url) {
                visible = true
                videoPage.transitionIn(videoPage.transition.bottomUp)
                loadPage(url)
            }

            onTransitionOutCompleted: {
                visible = false
                videoPage.destroy()
            }
        }
    }
}
