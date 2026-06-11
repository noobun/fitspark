import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Lang;
import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
using WatchUi as Ui;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;
using Toybox.Graphics;
using Toybox.Attention;

(:glance)
class OverviewGlanceDelegate extends WatchUi.GlanceViewDelegate
{

    var _view as WatchUi.View;

    function initialize(glanceview) {
        GlanceViewDelegate.initialize();   
        _view = glanceview;    
    }

}