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
        if (changed && text != null) {
            var trimmed = trimEntryWhitespace(text.toString());
            if (trimmed.length() > 0) {
                Properties.setValue(agent, trimmed);
                item.setSubLabel(trimmed);
            } else {
                writeLog("AgentEditTextPicker:onTextEntered", "Ignoring blank text entry", 100);
            }
        }
        return true;
    }

    function trimEntryWhitespace(value as String) as String {
        var start = 0;
        var end = value.length();
        while (start < end && isWhitespaceChar(value.substring(start, start + 1))) {
            start++;
        }
        while (end > start && isWhitespaceChar(value.substring(end - 1, end))) {
            end--;
        }
        return (end > start) ? value.substring(start, end) : "";
    }

    function isWhitespaceChar(chunk as String) as Boolean {
        return chunk.equals(" ") || chunk.equals("\t") || chunk.equals("\n");
    }

    function onCancel() {
        writeLog("AgentEditTextPicker", "Canceled", 100);
        return false;
    }
}