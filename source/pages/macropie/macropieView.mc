import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Timer;
import Toybox.Math;

class macroPieView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;

    private var pieChart;
    private var pageHint;

    private var actual = {};
    private var percentages = {
        "protein" => 0,
        "carbs" => 0,
        "fat" => 0
    };

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector;
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        pieChart = new PieChart([getColorForData("protein"), getColorForData("carbs"), getColorForData("fat")]);
        pageHint = new Rez.Drawables.nextButtonHint();
        writeLog("MacroPieView:Init", "DONE", 10);
    }

    function onLayout(dc as Dc) as Void {
        WatchUi.requestUpdate();
        pieChart.customize(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2, 90, dc.getWidth()*0.3, Graphics.ARC_CLOCKWISE);
    }

    function onSparkyDataUpdated() as Void {
        actual = _sparkyconnector.getMacroSetXDaysAgo(["protein", "carbs", "fat"], 0);
        calculatePercentages();
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            actual = _sparkyconnector.getMacroSetXDaysAgo(["protein", "carbs", "fat"], 0);
            calculatePercentages();
            _sparkyconnector.fetchNutrition(null);
        }
    }

    private function calculatePercentages(){
        var protein = actual["protein"] != null ? actual["protein"] : 0;
        var carbs = actual["carbs"] != null ? actual["carbs"] : 0;
        var fat = actual["fat"] != null ? actual["fat"] : 0;
        var calories = protein*4 + carbs*4 + fat*9;
        if (calories == 0) {
            percentages["protein"] = 0;
            percentages["carbs"] = 0;
            percentages["fat"] = 0;
            pieChart.feedData([]);
            return;
        }

        var proteinPct = protein.toFloat()*4/calories*100;
        var carbsPct = carbs.toFloat()*4/calories*100;
        var fatPct = fat.toFloat()*9/calories*100;

        var proteinInt = Math.round(proteinPct).toNumber();
        var carbsInt = Math.round(carbsPct).toNumber();
        var fatInt = Math.round(fatPct).toNumber();

        // Keep the displayed percentages summing to exactly 100.
        var diff = 100 - (proteinInt + carbsInt + fatInt);
        if (diff != 0) {
            if (proteinPct >= carbsPct && proteinPct >= fatPct) {
                proteinInt += diff;
            } else if (carbsPct >= fatPct) {
                carbsInt += diff;
            } else {
                fatInt += diff;
            }
        }

        percentages["protein"] = proteinInt;
        percentages["carbs"] = carbsInt;
        percentages["fat"] = fatInt;

        pieChart.feedData([proteinPct, carbsPct, fatPct]);
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        drawHeader(dc);
        pieChart.draw(dc);

        if(_manager.hasSubView()){
            pageHint.draw(dc);
        }
    }

    private function drawHeader(dc){
        var protein = actual["protein"] != null ? actual["protein"] : 0;
        var carbs = actual["carbs"] != null ? actual["carbs"] : 0;
        var fat = actual["fat"] != null ? actual["fat"] : 0;
        var calories = protein*4 + carbs*4 + fat*9;
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

    function onHide() as Void {

    }
}
