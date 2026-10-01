import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.System;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Communications;

(:glance)
public function getNow() as Lang.String {
    var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var dateString = Lang.format(
        "$1$:$2$:$3$ $4$.$5$.$6$",
        [
            today.hour,
            today.min,
            today.sec,
            today.day,
            today.month,
            today.year
        ]
    );

    return dateString;
}

(:glance)
var _writeLogThreshold = -1;

(:glance)
function _getWriteLogThreshold() as Number {
    if (_writeLogThreshold < 0) {
        var configured = Application.getApp().getProperty("logging");
        if (configured == null || !(configured instanceof Toybox.Lang.Number) || configured < 0) {
            configured = 1;
        }
        _writeLogThreshold = configured;
    }
    return _writeLogThreshold;
}

(:glance)
public function writeLog(component as String, message as String, level as Number) as Void {
    if (level < _getWriteLogThreshold()) {
        return;
    }
    System.println(level.toString() + " | " + getNow()+" "+component+" | "+message.toString());
}
