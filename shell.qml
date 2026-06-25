import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: root

    PanelWindow {
        id: window

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        exclusiveZone: 0
        color: "transparent"

        // Fullscreen dark overlay mask
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.4)
        }

        // Pulsing glow border
        Rectangle {
            id: glowEffect
            anchors.fill: body
            anchors.margins: -6
            radius: body.radius + 2
            color: "transparent"
            border.width: 4
            border.color: "#feffed"
            opacity: 0.8

            SequentialAnimation on opacity {
                running: true
                loops: Animation.Infinite
                NumberAnimation { to: 0.2; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 0.8; duration: 800; easing.type: Easing.InOutQuad }
            }
        }

        // Main OSD Panel
        Rectangle {
            id: body
            x: (parent.width - width) / 2
            y: -height

            width: parent.width * 0.90
            height: parent.height * 0.50
            radius: 16

            Behavior on y {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutCubic
                }
            }

            color: Qt.rgba(0.05, 0.05, 0.07, 0.94)
            border.width: 2
            border.color: "#7f7e52"

            Column {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20

                // Centered title
                Text {
                    width: parent.width
                    text: "Workspace Overview"
                    color: "#cfd699"
                    font.pixelSize: 24
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                ListView {
                    id: workspaceList
                    width: parent.width
                    height: parent.height - 70
                    orientation: ListView.Horizontal
                    spacing: 16
                    clip: true

                    model: Hyprland.workspaces

                    delegate: Rectangle {
                        id: workspaceCard

                        visible: modelData.id > 0
                        width: visible ? 240 : 0
                        height: visible ? parent.height - 10 : 0
                        radius: 10

                        color: modelData.id === Hyprland.focusedWorkspace.id
                        ? Qt.rgba(207/255, 214/255, 153/255, 0.18)   // Light #cfd699 tint for focused
                        : Qt.rgba(255, 255, 255, 0.02)

                        border.color: modelData.id === Hyprland.focusedWorkspace.id
                        ? "#cfd699"
                        : "#575742"
                        border.width: modelData.id === Hyprland.focusedWorkspace.id ? 2 : 1

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                let targetWorkspace = modelData
                                body.y = -body.height
                                delayTrigger.targetWs = targetWorkspace
                                delayTrigger.start()
                            }
                        }

                        Rectangle {
                            id: badge
                            width: 32; height: 32; radius: 6
                            x: 12; y: 12
                            color: modelData.id === Hyprland.focusedWorkspace.id ? "#cfd699" : "#313244"

                            Text {
                                anchors.centerIn: parent
                                text: modelData.id
                                color: modelData.id === Hyprland.focusedWorkspace.id ? "#11111b" : "#cdd6f4"
                                font.bold: true
                                font.pixelSize: 14
                            }
                        }

                        Column {
                            anchors.top: badge.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 12
                            spacing: 6

                            Text {
                                text: "Windows:"
                                color: "#a6adc8"
                                font.pixelSize: 11
                                font.bold: true
                            }

                            Repeater {
                                model: modelData.toplevels

                                delegate: Rectangle {
                                    width: parent.width
                                    height: 26
                                    color: Qt.rgba(255, 255, 255, 0.04)
                                    radius: 4
                                    border.color: Qt.rgba(255, 255, 255, 0.08)

                                    Text {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        anchors.verticalCenter: parent.verticalCenter

                                        text: modelData.appId ? modelData.appId : (modelData.title ? modelData.title : "Unknown App")
                                        color: "#cdd6f4"
                                        font.pixelSize: 12
                                        font.family: "monospace"
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Delay trigger for workspace switch + close
        Timer {
            id: delayTrigger
            property var targetWs: null
            interval: 400
            repeat: false
            onTriggered: {
                if (targetWs) targetWs.activate()
                    Qt.quit()
            }
        }

        // External toggle monitor
        Timer {
            id: externalToggleMonitor
            interval: 200
            running: true
            repeat: true

            property string flagPath: "/tmp/overview_exit_flag"

            onTriggered: {
                if (Qt.fileExists ? Qt.fileExists(flagPath) : false) {
                    externalToggleMonitor.running = false
                    body.y = -body.height
                    deferredShutdown.start()
                }
            }
        }

        // Clean shutdown
        Timer {
            id: deferredShutdown
            interval: 400
            repeat: false
            onTriggered: Qt.quit()
        }

        // Initial slide-in animation
        Timer {
            interval: 50
            running: true
            repeat: false
            onTriggered: {
                body.y = (window.height - body.height) / 2
            }
        }
    }
}
