import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons
import "Model.js" as Model

Panel {
  id: root
  moduleName: "agnibha.diskspace"
  ipcTarget: "agnibha.diskspace"
  manageIpc: true

  property var disks: []
  property real worstPct: 0

  function refresh() {
    if (!dfProc.running) dfProc.running = true
  }

  Process {
    id: dfProc
    command: ["df", "-B1", "--output=source,fstype,size,used,avail,target"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        root.disks = Model.parseDisks(text)
        root.worstPct = Model.worstPercent(root.disks)
      }
    }
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  onOpenedChanged: if (opened) refresh()

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰋊"
    slotSize: Style.bar.statusSlot
    tooltipText: "Disk Space"
    active: root.worstPct >= 85
    onPressed: function(b) { root.toggle() }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(panelColumn.implicitHeight, Style.space(560))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: panelColumn
        anchors.fill: parent
        spacing: Style.space(14)

        // ---- Hero Header ----
        Item {
          width: parent.width
          implicitHeight: Math.max(heroIcon.implicitHeight, heroLabels.implicitHeight)

          Text {
            id: heroIcon
            textFormat: Text.PlainText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "󰋊"
            color: root.bar ? root.bar.foreground : Color.foreground
            font.family: root.bar ? root.bar.fontFamily : ""
            font.pixelSize: Style.font.display
          }

          Column {
            id: heroLabels
            anchors.left: heroIcon.right
            anchors.leftMargin: Style.space(14)
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              text: "Disk Space"
              color: root.bar ? root.bar.foreground : Color.foreground
              font.family: root.bar ? root.bar.fontFamily : ""
              font.pixelSize: Style.font.title
              font.bold: true
              elide: Text.ElideRight
              width: parent.width
            }

            Text {
              textFormat: Text.PlainText
              text: root.disks.length + (root.disks.length === 1 ? " DRIVE" : " DRIVES")
              color: Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.4)
              font.family: root.bar ? root.bar.fontFamily : ""
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.2
              width: parent.width
            }
          }
        }

        PanelSeparator {
          foreground: root.bar ? root.bar.foreground : Color.foreground
        }

        // ---- Disk List ----
        Repeater {
          model: root.disks

          Column {
            required property var modelData
            required property int index
            width: panelColumn.width
            spacing: Style.space(6)

            // Disk name + percent
            Item {
              width: parent.width
              implicitHeight: diskNameCol.implicitHeight

              Column {
                id: diskNameCol
                anchors.left: parent.left
                anchors.right: diskPctLabel.left
                anchors.rightMargin: Style.space(8)
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                  textFormat: Text.PlainText
                  text: modelData.name
                  color: root.bar ? root.bar.foreground : Color.foreground
                  font.family: root.bar ? root.bar.fontFamily : ""
                  font.pixelSize: Style.font.body
                  font.bold: true
                  elide: Text.ElideRight
                  width: parent.width
                }

                Text {
                  textFormat: Text.PlainText
                  text: modelData.mount + "  •  " + modelData.fstype
                  color: Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.3)
                  font.family: root.bar ? root.bar.fontFamily : ""
                  font.pixelSize: Style.font.caption
                  elide: Text.ElideRight
                  width: parent.width
                }
              }

              Text {
                id: diskPctLabel
                textFormat: Text.PlainText
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(modelData.percent) + "%"
                color: modelData.percent >= 85 ? Color.error
                     : modelData.percent >= 70 ? Color.warning
                     : (root.bar ? root.bar.foreground : Color.foreground)
                font.family: root.bar ? root.bar.fontFamily : ""
                font.pixelSize: Style.font.title
                font.bold: true
              }
            }

            // Usage bar (simple Rectangle-based)
            Rectangle {
              width: parent.width
              height: Style.space(6)
              radius: height / 2
              color: Style.hoverFillFor(
                root.bar ? root.bar.foreground : Color.foreground,
                Color.accent
              )

              Rectangle {
                width: parent.width * (modelData.percent / 100)
                height: parent.height
                radius: parent.radius
                color: modelData.percent >= 85 ? Color.error
                     : modelData.percent >= 70 ? Color.warning
                     : Color.accent
              }
            }

            // Stats row
            Row {
              width: parent.width
              spacing: Style.space(16)

              Column {
                spacing: 1
                Text {
                  textFormat: Text.PlainText
                  text: "USED"
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  color: Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.4)
                }
                Text {
                  textFormat: Text.PlainText
                  text: modelData.usedStr
                  font.pixelSize: Style.font.body
                  color: root.bar ? root.bar.foreground : Color.foreground
                }
              }

              Column {
                spacing: 1
                Text {
                  textFormat: Text.PlainText
                  text: "FREE"
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  color: Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.4)
                }
                Text {
                  textFormat: Text.PlainText
                  text: modelData.freeStr
                  font.pixelSize: Style.font.body
                  color: root.bar ? root.bar.foreground : Color.foreground
                }
              }

              Column {
                spacing: 1
                Text {
                  textFormat: Text.PlainText
                  text: "TOTAL"
                  font.pixelSize: Style.font.caption
                  font.bold: true
                  color: Qt.darker(root.bar ? root.bar.foreground : Color.foreground, 1.4)
                }
                Text {
                  textFormat: Text.PlainText
                  text: modelData.totalStr
                  font.pixelSize: Style.font.body
                  color: root.bar ? root.bar.foreground : Color.foreground
                }
              }
            }

            // Separator between disks (except after the last one)
            PanelSeparator {
              visible: index < root.disks.length - 1
              foreground: root.bar ? root.bar.foreground : Color.foreground
            }
          }
        }
      }
    }
  }
}
