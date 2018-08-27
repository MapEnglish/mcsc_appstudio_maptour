import QtQuick 2.3
import QtPositioning 5.2

PositionSource {

    property double latitude: isDebug ? 34.0562417 : position.coordinate.latitude
    property double longitude: isDebug ? -117.197864 : position.coordinate.longitude

    property bool isDebug: false
    property bool isLocationValid: latitude && longitude

    updateInterval: 10000

}
