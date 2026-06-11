import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Timer;

class macroPieView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;

    private var pieChart;

    private var actual = {};
    private var percentages = {
        "protein" => 0,
        "carbs" => 0,
        "fat" => 0
    };

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector; // Assuming sparkyconnector is the SparkConnect instance
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        pieChart = new PieChart([getColorForData("protein"), getColorForData("carbs"), getColorForData("fat")]);
        writeLog("MacroPieView:Init", "DONE", 10);
    }

    function onLayout(dc as Dc) as Void {
        WatchUi.requestUpdate();
        pieChart.customize(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2, 90, dc.getWidth()*0.3, Graphics.ARC_CLOCKWISE);
    }

    function onSparkyDataUpdated() as Void {
        // writeLog("macroView:onSparkyDataUpdated", "Data received: " + data.toString(), 10);
        actual = _sparkyconnector.getMacroSetXDaysAgo(["protein", "carbs", "fat"], 0);
        calculatePercentages();
        WatchUi.requestUpdate();
    }

    // Called when this View is brought to the foreground
    function onShow() as Void {
        // Sync data when view is shown
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            actual = _sparkyconnector.getMacroSetXDaysAgo(["protein", "carbs", "fat"], 0);
            calculatePercentages();
            _sparkyconnector.fetchNutrition(null);
        }
    }

    private function calculatePercentages(){
        var calories = actual["protein"]*4 + actual["carbs"]*4 + actual["fat"]*7;
        if (calories != 0) {
            percentages["protein"] = (actual["protein"].toFloat()*4/calories*100).toNumber();
            percentages["carbs"] = (actual["carbs"].toFloat()*4/calories*100).toNumber();
            percentages["fat"] = (actual["fat"].toFloat()*7/calories*100).toNumber();

            pieChart.feedData([percentages["protein"], percentages["carbs"], percentages["fat"]]);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        // Draw header with user name and date
        drawHeader(dc);
        pieChart.draw(dc);

        if(_manager.hasSubView()){
            var pageHint = new Rez.Drawables.nextButtonHint();
            pageHint.draw(dc);
        }
    }

    private function drawHeader(dc){
        var calories = actual["protein"]*4 + actual["carbs"]*4 + actual["fat"]*7;
        var barWidth = dc.getWidth()*0.03;
        dc.setPenWidth(2);

        dc.setColor(getColorForData("protein"), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(dc.getWidth()/2 - barWidth/2, dc.getWidth()/2 - dc.getFontHeight(Graphics.FONT_XTINY)*2, barWidth, dc.getFontHeight(Graphics.FONT_XTINY));
        
        dc.setColor(getColorForData("carbs"), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(dc.getWidth()/2 - barWidth/2, dc.getWidth()/2 - dc.getFontHeight(Graphics.FONT_XTINY)*0.5, barWidth, dc.getFontHeight(Graphics.FONT_XTINY));

        dc.setColor(getColorForData("fat"), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(dc.getWidth()/2 - barWidth/2, dc.getWidth()/2 + dc.getFontHeight(Graphics.FONT_XTINY)*1, barWidth, dc.getFontHeight(Graphics.FONT_XTINY));

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2 - barWidth, dc.getWidth()/2 - dc.getFontHeight(Graphics.FONT_XTINY)*2, Graphics.FONT_XTINY, "protein", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(dc.getWidth()/2 - barWidth, dc.getWidth()/2 - dc.getFontHeight(Graphics.FONT_XTINY)*0.5, Graphics.FONT_XTINY, "carbs", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(dc.getWidth()/2 - barWidth, dc.getWidth()/2 + dc.getFontHeight(Graphics.FONT_XTINY)*1, Graphics.FONT_XTINY, "fat", Graphics.TEXT_JUSTIFY_RIGHT);

        dc.drawText(dc.getWidth()/2 + barWidth, dc.getWidth()/2 - dc.getFontHeight(Graphics.FONT_XTINY)*2, Graphics.FONT_XTINY, percentages["protein"].toString() + "%", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(dc.getWidth()/2 + barWidth, dc.getWidth()/2 - dc.getFontHeight(Graphics.FONT_XTINY)*0.5, Graphics.FONT_XTINY, percentages["carbs"].toString() + "%", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(dc.getWidth()/2 + barWidth, dc.getWidth()/2 + dc.getFontHeight(Graphics.FONT_XTINY)*1, Graphics.FONT_XTINY, percentages["fat"].toString() + "%", Graphics.TEXT_JUSTIFY_LEFT);

    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {

    }
}
