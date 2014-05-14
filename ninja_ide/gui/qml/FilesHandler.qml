import QtQuick 1.1

Rectangle {
    id: root

    radius: 5
    color: "#202123"
    border.width: 1
    border.color: "gray"

    PropertyAnimation {
        id: showAnim
        target: root
        properties: "opacity"
        easing.type: Easing.InOutQuad
        to: 1
        duration: 300
    }

    signal open(string path, string tempFile)
    signal close(string path, string tempFile)
    signal hide

    function activateInput() {
        input.text = "";
        input.forceActiveFocus();
    }

    function show_animation() {
        root.opacity = 0;
        showAnim.running = true;
    }

    function open_item() {
        var item = listFiles.model.get(listFiles.currentIndex);
        var path = item.path;
        var tempFile = item.tempFile;
        root.open(path, tempFile);
    }

    function set_model(model) {
        listFiles.currentIndex = 0;
        for(var i = 0; i < model.length; i++) {
            listFiles.model.append(
                {"name": model[i][0],
                "path": model[i][1],
                "checkers": model[i][2],
                "modified": model[i][3],
                "tempFile": model[i][4],
                "itemVisible": true});
        }
    }

    function clear_model() {
        listFiles.model.clear();
    }

    function next_item() {
        for (var i = 0; i < listFiles.model.count; i++) {
            listFiles.incrementCurrentIndex();
            if (listFiles.model.get(listFiles.currentIndex).itemVisible) {
                break
            }
        }
    }

    function previous_item() {
        for (var i = 0; i < listFiles.model.count; i++) {
            listFiles.decrementCurrentIndex();
            if (listFiles.model.get(listFiles.currentIndex).itemVisible) {
                break
            }
        }
    }

    Rectangle {
        id: inputArea
        radius: 2
        color: "#2d2f31"
        height: 30
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }
        border.color: "black"
        border.width: 1
        smooth: true

        TextInput {
            id: input
            anchors {
                fill: parent
                margins: 4
            }
            focus: true
            clip: true
            color: "white"
            font.pixelSize: 18

            onTextChanged: {
                var firstValidItem = -1;
                for (var i = 0; i < listFiles.model.count; i++) {
                    var item = listFiles.model.get(i);
                    if (item.name.indexOf(input.text) == -1) {
                        item.itemVisible = false;
                    } else {
                        if (firstValidItem == -1) firstValidItem = i;
                        item.itemVisible = true;
                    }
                }
                listFiles.currentIndex = firstValidItem;
            }

            Keys.onDownPressed: {
                root.next_item();
            }
            Keys.onUpPressed: {
                root.previous_item();
            }
            Keys.onEnterPressed: {
                root.open_item();
            }
            Keys.onReturnPressed: {
                root.open_item();
            }
        }
    }

    Component {
        id: tabDelegate
        Rectangle {
            id: item
            visible: itemVisible
            width: parent.width
            property int defaultValues: checkers ? 70 : 60
            height: itemVisible ? defaultValues : 0
            property bool current: ListView.isCurrentItem
            color: item.current ? "#4182c4" : "#27292b"

            property string mainTextColor: item.current ? "white" : "#aaaaaa"
            property string mainTextModifiedColor: item.current ? "lightgreen" : "green"

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    var path = listFiles.model.get(index).path;
                    var tempFile = listFiles.model.get(index).tempFile;
                    root.open(path, tempFile);
                }
            }

            Rectangle {
                anchors.fill: imgClose
                anchors.margins: 2
                radius: width / 2
                color: "white"
            }

            Image {
                id: imgClose
                source: "img/delete-project.png"
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 7

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        var path = listFiles.model.get(index).path;
                        var tempFile = listFiles.model.get(index).tempFile;
                        //FIXME: when index == 0 then start removing the wrong items
                        if(index == 0) {
                            root.hide();
                        }
                        root.close(path, tempFile);
                        listFiles.model.remove(index);
                    }
                }
            }

            Column {
                id: col
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 10
                }
                Text {
                    anchors {
                        left: parent.left
                        right: parent.right
                        rightMargin: imgClose.width
                    }
                    color: modified ? mainTextModifiedColor : mainTextColor
                    font.pixelSize: 18
                    font.bold: true
                    text: name
                    elide: Text.ElideRight
                    font.italic: modified
                }
                Text {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    color: item.current ? "#aaaaaa" : "#555555"
                    elide: Text.ElideLeft
                    text: path
                }
            }
            Row {
                anchors {
                    right: parent.right
                    top: col.bottom
                    margins: 5
                }
                spacing: 10
                Repeater {
                    model: checkers
                    Text {
                        color: checker_color
                        text: checker_text
                        visible: checker_text.length > 0 ? true : false
                        font.pixelSize: 12
                    }
                }
            }
        }
    }

    ListView {
        id: listFiles
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            top: inputArea.bottom
            margins: 5
        }
        spacing: 2

        focus: true
        model: ListModel {}
        delegate: tabDelegate
        highlightMoveDuration: 200
    }
}
