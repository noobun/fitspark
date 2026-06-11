import Toybox.Lang;
import Toybox.WatchUi;
using WatchUi as Ui;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;
using Toybox.Graphics;
using Toybox.Attention;
import Toybox.System;

class AgentEditTextPicker extends WatchUi.TextPickerDelegate {

    var agent;
    var item;

    function initialize(agent_id, ex_item) {
        TextPickerDelegate.initialize();
        agent = agent_id;
        item=ex_item;
    }

    function onTextEntered(text, changed) {
        var lastText = text;
        Properties.setValue(agent, lastText);
        item.setSubLabel(lastText);

        return changed;
    }

    function onCancel() {
        writeLog("AgentEditTextPicker", "Canceled", 100);
        return false;
    }
}