import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 400
    height: 400

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    Column {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Bluetooth"
            color: "#ffffff"
            font.bold: true
            font.pixelSize: 22
        }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 140
            height: 36
            text: btManager.scanning ? "Scanning..." : "Scan"
            onClicked: {
                if (btManager.scanning) {
                    btManager.stopScan()
                } else {
                    btManager.startScan()
                }
            }
        }

        ListView {
            id: listView
            width: parent.width
            height: parent.height - 80
            clip: true
            model: btManager.devices

            delegate: Rectangle {
                width: listView.width
                height: 55
                color: "#161616"
                radius: 8
                border.color: modelData.Connected ? "#2ecc71" : (modelData.Paired ? "#3498db" : "#333333")
                border.width: 1

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: modelData.Name ? modelData.Name : modelData.Address
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 15
                        elide: Text.ElideRight
                        width: 180
                    }

                    Text {
                        text: modelData.Connected ? "Connected" : (modelData.Paired ? "Paired" : modelData.Address)
                        color: modelData.Connected ? "#2ecc71" : "#888888"
                        font.pixelSize: 11
                    }
                }

                Button {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: 70
                    height: 32
                    text: modelData.Connected ? "Drop" : "Pair"
                    onClicked: {
                        if (modelData.Connected) {
                            btManager.disconnectDevice(modelData.Address)
                        } else {
                            btManager.connectDevice(modelData.Address)
                        }
                    }
                }
            }
        }
    }

    // Modal PIN / Passkey Display Overlay
    Rectangle {
        id: pinModal
        anchors.fill: parent
        color: "#d9000000"
        visible: btManager.pinPromptVisible

        Rectangle {
            width: 280
            height: 200
            radius: 16
            color: "#1c1c1e"
            border.color: "#00d2ff"
            border.width: 2
            anchors.centerIn: parent

            Column {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Type on Keyboard:"
                    color: "#8e8e93"
                    font.pixelSize: 13
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: btManager.currentPin
                    color: "#00ff66"
                    font.family: "Monospace"
                    font.bold: true
                    font.pixelSize: 32
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "& press Enter"
                    color: "#00d2ff"
                    font.pixelSize: 13
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 90
                    height: 30
                    text: "Cancel"
                    onClicked: btManager.cancelPinPrompt()
                }
            }
        }
    }
}
