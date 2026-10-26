/*
 * =====================================================================
 * Part of the AsteroidOS Custom Software Suite
 * Architecture, Engine & UI Engineering by Gemini (Google)
 * Co-Developed & Tested on-device by DarkwingDuck13
 *
 * Platform: AsteroidOS (Linux / Qt6 / OpenEmbedded / TicWatch Pro)
 * =====================================================================
 */

import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 400
    height: 400

    // Native AsteroidOS Purple/Indigo Faceted Background (Settings Style!)
    FacetedBackground { anchors.fill: parent }

    Flickable {
        anchors.fill: parent
        anchors.margins: 30
        contentWidth: width
        contentHeight: contentCol.height
        clip: true

        Column {
            id: contentCol
            width: parent.width
            spacing: 16

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Bluetooth"
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 24
            }

            // ==========================================
            // SECTION 1: PAIRED DEVICES
            // ==========================================
            Text {
                text: "PAIRED DEVICES"
                color: "#ffffff"
                opacity: 0.6
                font.bold: true
                font.pixelSize: 13
                visible: btManager.pairedDevices.length > 0
            }

            Repeater {
                model: btManager.pairedDevices
                delegate: Item {
                    width: contentCol.width
                    height: 64

                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 110

                        Text {
                            text: modelData.Name ? modelData.Name : modelData.Address
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 16
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: modelData.Connected ? "Connected" : "Disconnected"
                            color: "#ffffff"
                            opacity: modelData.Connected ? 0.9 : 0.5
                            font.pixelSize: 13
                        }
                    }

                    // Two Circular Wireframe Action Buttons (Asteroid OS Parity)
                    Row {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 12

                        // Connect / Disconnect Toggle Button
                        Rectangle {
                            width: 46
                            height: 46
                            radius: 23
                            color: linkBtnMouse.pressed ? "#40ffffff" : "transparent"
                            border.color: "#ffffff"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: modelData.Connected ? "\u25A0" : "\u25B6" // Solid stop or play
                                color: "#ffffff"
                                font.pixelSize: modelData.Connected ? 16 : 18
                            }

                            MouseArea {
                                id: linkBtnMouse
                                anchors.fill: parent
                                onClicked: {
                                    btManager.buzz(35);
                                    if (modelData.Connected) {
                                        btManager.disconnectDevice(modelData.Address);
                                    } else {
                                        btManager.connectDevice(modelData.Address);
                                    }
                                }
                            }
                        }

                        // Forget Button (Circular Wireframe ✕)
                        Rectangle {
                            width: 46
                            height: 46
                            radius: 23
                            color: forgetBtnMouse.pressed ? "#40ffffff" : "transparent"
                            border.color: "#ffffff"
                            border.width: 2

                            Text {
                                anchors.centerIn: parent
                                text: "\u2715"
                                color: "#ffffff"
                                font.pixelSize: 18
                            }

                            MouseArea {
                                id: forgetBtnMouse
                                anchors.fill: parent
                                onClicked: {
                                    btManager.buzz(45);
                                    btManager.forgetDevice(modelData.Address);
                                }
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 6 }

            // ==========================================
            // SECTION 2: NEARBY DEVICES & SCAN TRIGGER
            // ==========================================
            Row {
                width: parent.width
                spacing: 10

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "NEARBY DEVICES"
                    color: "#ffffff"
                    opacity: 0.6
                    font.bold: true
                    font.pixelSize: 13
                    width: parent.width - 55
                }

                // Circular Wireframe Refresh/Scan Button
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: scanBtnMouse.pressed ? "#40ffffff" : "transparent"
                    border.color: "#ffffff"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: btManager.scanning ? "\u25A0" : "\u27F3" // Stop square or circular refresh
                        color: "#ffffff"
                        font.pixelSize: 20
                    }

                    MouseArea {
                        id: scanBtnMouse
                        anchors.fill: parent
                        onClicked: {
                            btManager.buzz(35);
                            if (btManager.scanning) {
                                btManager.stopScan();
                            } else {
                                btManager.startScan();
                            }
                        }
                    }
                }
            }

            Repeater {
                model: btManager.availableDevices
                delegate: Item {
                    width: contentCol.width
                    height: 58

                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 60

                        Text {
                            text: modelData.Name ? modelData.Name : modelData.Address
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 15
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: modelData.Address
                            color: "#ffffff"
                            opacity: 0.5
                            font.pixelSize: 11
                        }
                    }

                    // Circular (+) Pair Button (Matching Asteroid OS Image 3!)
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 46
                        height: 46
                        radius: 23
                        color: pairBtnMouse.pressed ? "#40ffffff" : "transparent"
                        border.color: "#ffffff"
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 24
                        }

                        MouseArea {
                            id: pairBtnMouse
                            anchors.fill: parent
                            onClicked: {
                                btManager.buzz(45);
                                btManager.pairDevice(modelData.Address);
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 40 }
        }
    }

    // ==========================================
    // MODAL PASSKEY / PIN OVERLAY
    // ==========================================
    Rectangle {
        id: pinModal
        anchors.fill: parent
        color: "#eb000000"
        visible: btManager.pinPromptVisible
        z: 99

        Rectangle {
            width: 260
            height: 210
            radius: 130
            color: "#160926"
            border.color: "#ffffff"
            border.width: 2
            anchors.centerIn: parent

            Column {
                anchors.centerIn: parent
                spacing: 10
                width: parent.width - 30

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "TYPE ON KEYBOARD"
                    color: "#ffffff"
                    opacity: 0.7
                    font.bold: true
                    font.pixelSize: 12
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: btManager.currentPin
                    color: "#ffffff"
                    font.family: "Monospace"
                    font.bold: true
                    font.pixelSize: 34
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "& press Enter"
                    color: "#ffffff"
                    opacity: 0.6
                    font.pixelSize: 13
                }

                // Circular Wireframe Cancel Button (✕)
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 48
                    height: 48
                    radius: 24
                    color: cancelPinMouse.pressed ? "#40ffffff" : "transparent"
                    border.color: "#ffffff"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "\u2715"
                        color: "#ffffff"
                        font.pixelSize: 20
                    }

                    MouseArea {
                        id: cancelPinMouse
                        anchors.fill: parent
                        onClicked: {
                            btManager.buzz(20);
                            btManager.cancelPinPrompt();
                        }
                    }
                }
            }
        }
    }
}
