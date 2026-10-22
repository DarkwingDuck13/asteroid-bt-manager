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

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.margins: 35
        contentWidth: contentCol.width
        contentHeight: contentCol.height
        clip: true

        Column {
            id: contentCol
            width: flick.width
            spacing: 12

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Bluetooth"
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 22
            }

            // --- SECTION 1: PAIRED DEVICES ---
            Text {
                text: "PAIRED DEVICES"
                color: "#00d2ff"
                font.bold: true
                font.pixelSize: 12
                visible: btManager.pairedDevices.length > 0
            }

            Repeater {
                model: btManager.pairedDevices
                delegate: Rectangle {
                    width: contentCol.width
                    height: 56
                    color: "#161616"
                    radius: 8
                    border.color: modelData.Connected ? "#2ecc71" : "#444444"
                    border.width: 1

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: modelData.Name ? modelData.Name : modelData.Address
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 14
                            elide: Text.ElideRight
                            width: 140
                        }

                        Text {
                            text: modelData.Connected ? "Connected" : "Disconnected"
                            color: modelData.Connected ? "#2ecc71" : "#888888"
                            font.pixelSize: 11
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        // Connect / Disconnect Toggle
                        Button {
                            width: 58
                            height: 32
                            text: modelData.Connected ? "Drop" : "Link"
                            onClicked: {
                                if (modelData.Connected) {
                                    btManager.disconnectDevice(modelData.Address)
                                } else {
                                    btManager.connectDevice(modelData.Address)
                                }
                            }
                        }

                        // Forget / Unpair Button
                        Button {
                            width: 32
                            height: 32
                            text: "✕"
                            palette.buttonText: "#ff4444"
                            onClicked: btManager.forgetDevice(modelData.Address)
                        }
                    }
                }
            }

            // --- SECTION 2: AVAILABLE / SCAN DEVICES ---
            Item { width: 1; height: 8 }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "NEARBY DEVICES"
                    color: "#888888"
                    font.bold: true
                    font.pixelSize: 12
                }

                Button {
                    width: 90
                    height: 30
                    text: btManager.scanning ? "Stop" : "Scan"
                    onClicked: {
                        if (btManager.scanning) {
                            btManager.stopScan()
                        } else {
                            btManager.startScan()
                        }
                    }
                }
            }

            Repeater {
                model: btManager.availableDevices
                delegate: Rectangle {
                    width: contentCol.width
                    height: 50
                    color: "#121212"
                    radius: 8
                    border.color: "#2a2a2a"
                    border.width: 1

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: modelData.Name ? modelData.Name : modelData.Address
                            color: "#dddddd"
                            font.pixelSize: 13
                            elide: Text.ElideRight
                            width: 160
                        }

                        Text {
                            text: modelData.Address
                            color: "#666666"
                            font.pixelSize: 10
                        }
                    }

                    Button {
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 55
                        height: 30
                        text: "Pair"
                        onClicked: btManager.pairDevice(modelData.Address)
                    }
                }
            }

            // Bottom breathing room for round display
            Item { width: 1; height: 30 }
        }
    }

    // Modal PIN Display
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
