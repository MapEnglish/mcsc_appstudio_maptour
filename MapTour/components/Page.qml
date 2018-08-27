import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import ArcGIS.AppFramework 1.0
import QtGraphicalEffects 1.0

FocusScope {
    id: _root

    signal back()
    signal transitionInCompleted()
    signal transitionOutCompleted()

    property bool isDebug: true
    property int headerHeight: units(56)
    property int footerHeight: units(56)
    property int transitionType: transition.none
    property int transitionDuration: 200
    property alias transition: transition
    property int transitionXOffset: parent.width

    property Item header: Item {}
    property Item content: Item {}
    property Item footer: Item {}

    QtObject{
        id: transition
        property int none: -1
        property int leftToRight: 0
        property int rightToLeft: 1
        property int bottomUp: 2
        property int topDown: 3
        property int centerOut: 4
        property int centerIn: 5
        property int fadeIn: 6
        property int fadeOut: 7
    }

    function units(num) {
        return num ? num*AppFramework.displayScaleFactor : 0
    }

    width: parent.width
    height: parent.height
    x: 0
    y: 0

    clip: true

    Rectangle{
        anchors.fill: parent
        border.color: "pink"
        border.width: isDebug? 1:0
        ColumnLayout {
            id: layout
            anchors.fill: parent
            spacing: 0

            Rectangle{
                id: headerContainer
                Layout.fillWidth: true
                Layout.preferredHeight: headerHeight
                color: "transparent"
                border.color: "red"
                border.width: isDebug? 1:0
                children: [header]
            }

            Rectangle{
                id: contentContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                border.color: "pink"
                border.width: isDebug? 1:0
                children: [content]
                clip: true
                visible: true
            }

            Rectangle{
                id: footerContainer
                Layout.fillWidth: true
                Layout.preferredHeight: footerHeight
                color: "transparent"
                border.color: "pink"
                border.width: isDebug? 1:0
                children: [footer]
                visible: footer.visible
            }
        }

        HeaderShadow {
            source: headerContainer
        }
    }

    NumberAnimation {
        id: leftToRight_MoveIn
        target: _root
        property: "x"
        duration: _root.transitionDuration
        from:-transitionXOffset
        to:0
        easing.type: Easing.InOutQuad
        onStopped: {
            transitionInCompleted()
        }
    }

    NumberAnimation {
        id: rightToLeft_MoveIn
        target: _root
        property: "x"
        duration: _root.transitionDuration
        from: transitionXOffset
        to:0
        easing.type: Easing.InOutQuad
        onStopped: {
            transitionInCompleted()
        }
    }

    NumberAnimation {
        id: bottomUp_MoveIn
        target: _root
        property: "y"
        duration: _root.transitionDuration
        from:parent.height
        to:0
        easing.type: Easing.InOutQuad
        onStopped: {
            transitionInCompleted()
        }
    }

    NumberAnimation {
        id: topDown_MoveIn
        target: _root
        property: "y"
        duration: _root.transitionDuration
        from:-parent.height
        to:0
        easing.type: Easing.InOutQuad
        onStopped: {
            transitionInCompleted()
        }
    }

    ParallelAnimation{
        id: centerOut_MoveIn

        NumberAnimation {
            target: _root
            property: "x"
            duration: _root.transitionDuration
            from: parent.width/2
            to: 0
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: _root
            property: "y"
            duration: _root.transitionDuration
            from: parent.height/2
            to: 0
            easing.type: Easing.InOutQuad
        }


        NumberAnimation {
            target: _root
            property: "width"
            duration: _root.transitionDuration
            from: 0
            to: parent.width
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: _root
            property: "height"
            duration: _root.transitionDuration
            from: 0
            to: parent.height
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: _root
            property: "opacity"
            duration: _root.transitionDuration
            from: 0.0
            to: 1.0
            easing.type: Easing.InOutQuad
        }

        onStopped: {
            transitionInCompleted()
        }
    }

    NumberAnimation {
        id: leftToRight_MoveOut
        target: _root
        property: "x"
        duration: _root.transitionDuration
        from:0
        to:transitionXOffset
        easing.type: Easing.InOutQuad
        onStopped: {
            transitionOutCompleted()
        }
    }

    NumberAnimation {
        id: rightToLeft_MoveOut
        target: _root
        property: "x"
        duration: _root.transitionDuration
        from:0
        to:-transitionXOffset
        easing.type: Easing.InOutQuad
        onStopped: {
            transitionOutCompleted()
        }
    }

    NumberAnimation {
        id: bottomUp_MoveOut
        target: _root
        property: "y"
        duration: _root.transitionDuration
        from:0
        to:-parent.height
        easing.type: Easing.InOutQuad
        onStopped: {
            transitionOutCompleted()
        }
    }

    NumberAnimation {
        id: topDown_MoveOut
        target: _root
        property: "y"
        duration: _root.transitionDuration
        from:0
        to:parent.height
        easing.type: Easing.InOutQuad
        onStopped: {
            transitionOutCompleted()
        }
    }

    ParallelAnimation{
        id: centerIn_MoveOut

        NumberAnimation {
            target: _root
            property: "x"
            duration: _root.transitionDuration
            from: 0
            to: parent.width/2
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: _root
            property: "y"
            duration: _root.transitionDuration
            from: 0
            to: parent.height/2
            easing.type: Easing.InOutQuad
        }


        NumberAnimation {
            target: _root
            property: "width"
            duration: _root.transitionDuration
            from: parent.width
            to: 0
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: _root
            property: "height"
            duration: _root.transitionDuration
            from: parent.height
            to: 0
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: _root
            property: "opacity"
            duration: _root.transitionDuration
            from: 1.0
            to: 0.0
            easing.type: Easing.InOutQuad
        }
        onStopped: {
            transitionOutCompleted()
        }
    }

    NumberAnimation {
        id: fadeIn_MoveIn
        target: _root
        property: "opacity"
        duration: _root.transitionDuration
        from: 0.0
        to: 1.0
        easing.type: Easing.InOutQuad
    }

    NumberAnimation {
        id: fadeOut_MoveOut
        target: _root
        property: "opacity"
        duration: _root.transitionDuration
        from: 1.0
        to: 0.0
        easing.type: Easing.InOutQuad
    }

    function transitionIn(transition){
        switch(transition){
        case 0:
            leftToRight_MoveIn.start();
            break;
        case 1:
            rightToLeft_MoveIn.start();
            break;
        case 2:
            bottomUp_MoveIn.start();
            break;
        case 3:
            topDown_MoveIn.start();
            break;
        case 4:
            centerOut_MoveIn.start();
            break;
        case 6:
            fadeIn_MoveIn.start()
            break;
        }

    }

    function transitionOut(transition){
        switch(transition){
        case 0:
            leftToRight_MoveOut.start();
            break;
        case 1:
            rightToLeft_MoveOut.start();
            break;
        case 2:
            bottomUp_MoveOut.start();
            break;
        case 3:
            topDown_MoveOut.start();
            break;
        case 5:
            centerIn_MoveOut.start();
            break;
        case 7:
            fadeOut_MoveOut.start();
            break;
        }
    }



    Component.onCompleted: {
        transitionIn(transitionType)
    }

    focus: true
}
