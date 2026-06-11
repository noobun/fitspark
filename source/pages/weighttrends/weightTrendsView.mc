import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Timer;

class weightTrendsView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;

    private var weightHistory = {};
    private var multigraph;

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        multigraph = new MultiGraph([getColorForData("weight")]);
        _manager = manager;
        _sparkyconnector = sparkyconnector; // Assuming sparkyconnector is the SparkConnect instance
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        writeLog("weightView:Init", "DONE", 10);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        WatchUi.requestUpdate();
        multigraph.customize(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2, dc.getHeight()/2, ["w"]);
    }

    function onSparkyDataUpdated() as Void {
        weightHistory = _sparkyconnector.getWeightHistory();
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            weightHistory = _sparkyconnector.getWeightHistory();
            _sparkyconnector.fetchWeightHistory(7);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear screen with a black background
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if(_manager.hasSubView()){
            var pageHint = new Rez.Drawables.nextButtonHint();
            pageHint.draw(dc);
        }

        var dates = [];
        var trend = [];
        for (var i = 7; i >= 0; i--) {
            var dateKey = getDateXDaysAgo(i);
            if (weightHistory[dateKey] != null) {
                dates.add(dateKey);
                trend.add(weightHistory[dateKey]);
                // if (trend.size() >= 2){
                //     if (trend[7-i-1] == -1){
                //         trend[7-i-1] = trend[trend.size()-1];
                //     }
                // }
            }
        }

        drawHeader(dc, trend);

        multigraph.feedData([trend], dates);
        multigraph.draw(dc);
    }

    private function drawHeader(dc, trend){
        var weightAverage = getAverage(trend);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() * 0.01, Graphics.FONT_SYSTEM_XTINY, "avg", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() * 0.08, Graphics.FONT_SYSTEM_TINY, weightAverage.format("%.1f").toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {

    }
}
