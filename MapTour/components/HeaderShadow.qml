import QtQuick 2.3
import QtGraphicalEffects 1.0

DropShadow {
    horizontalOffset: 1
    verticalOffset: app.units(2)
    radius: 8.0
    samples: 17
    color: "#80000000"
    smooth: true
    visible: source.visible
    cached: true
}
