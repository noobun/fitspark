import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Timer;

class macrotrendsView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;
    private var multigraph;

    private var trends = {};

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        _manager = manager;
        multigraph = new MultiGraph([getColorForData("protein"), getColorForData("carbs"), getColorForData("fat")]);
        _sparkyconnector = sparkyconnector; // Assuming sparkyconnector is the SparkConnect instance
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        writeLog("macroView:Init", "DONE", 10);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        WatchUi.requestUpdate();
        multigraph.customize(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2, dc.getHeight()/2, ["p", "c", "f"]);
    }

    function onSparkyDataUpdated() as Void {
        trends = _sparkyconnector.getMacroSetTrends(["protein", "carbs", "fat", "date"]);
        //writeLog("macrotrendsView:onSparkyDataUpdated", "Trend data: " + trends.toString(), 10);
        WatchUi.requestUpdate();
    }

    // Called when this View is brought to the foreground
    function onShow() as Void {
        // Sync data when view is shown
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            trends = _sparkyconnector.getMacroSetTrends(["protein", "carbs", "fat", "date"]);
            _sparkyconnector.fetchNutriTrends();
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if(_manager.hasSubView()){
            var pageHint = new Rez.Drawables.nextButtonHint();
            pageHint.draw(dc);
        }
        // Draw header with user name and date
        if(trends["date"] != null){
            if(trends["date"].size() >= 2){
                drawHeader(dc, trends["date"]);
                multigraph.feedData([trends["protein"], trends["carbs"], trends["fat"]], trends["date"]);
                multigraph.draw(dc);
                // drawNutrition(dc, trends);
            }
        }

    }

    private function drawHeader(dc, dates) {
        dc.setPenWidth(2);

        // dc.drawLine(0, dc.getHeight() * 0.25 + dc.getHeight()*0.18/2 + dc.getHeight()*0.07/2, dc.getWidth(), dc.getHeight() * 0.25 + dc.getHeight()*0.18/2 + dc.getHeight()*0.07/2);
        // dc.drawLine(0, dc.getHeight() * 0.5 + dc.getHeight()*0.18/2 + dc.getHeight()*0.07/2, dc.getWidth(), dc.getHeight() * 0.5 + dc.getHeight()*0.18/2  + dc.getHeight()*0.07/2);
    
        var startX = dc.getWidth() * 0.20;
        var leap = (dc.getWidth() - startX*2)/(trends["date"].size()-1);
        var barWidth = dc.getWidth()*0.03;

        dc.setColor(getColorForData("protein"), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(dc.getWidth()/2 - barWidth*6, dc.getWidth()*0.05, barWidth, dc.getFontHeight(Graphics.FONT_XTINY));
        
        dc.setColor(getColorForData("carbs"), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(dc.getWidth()/2 - barWidth/2, dc.getWidth()*0.05, barWidth, dc.getFontHeight(Graphics.FONT_XTINY));

        dc.setColor(getColorForData("fat"), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(dc.getWidth()/2 + barWidth*5.5, dc.getWidth()*0.05, barWidth, dc.getFontHeight(Graphics.FONT_XTINY));

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2 - barWidth*7, dc.getWidth()*0.05, Graphics.FONT_XTINY, "P", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(dc.getWidth()/2 - barWidth*1.5, dc.getWidth()*0.05, Graphics.FONT_XTINY, "C", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(dc.getWidth()/2 + barWidth*4.5, dc.getWidth()*0.05, Graphics.FONT_XTINY, "F", Graphics.TEXT_JUSTIFY_RIGHT);
        

        // for (var i = 0; i < dates.size(); i++) {
        //     var date = dates[i];
        //     dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        //     dc.setPenWidth(1);
            
        //     var shortDate = formatShortDate(date);
        //     if (i != 0) {
        //         drawDottedLine(dc, startX, dc.getHeight() * 0.23, startX, dc.getHeight() * 0.78, 5, 5);
        //     }

        //     dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        //     dc.drawText(startX, dc.getHeight() * 0.80, Graphics.FONT_SYSTEM_XTINY, shortDate, Graphics.TEXT_JUSTIFY_CENTER);
        //     startX += leap;
        // }
    }

    // private function drawNutrition(dc, trends) {
    //     var min = null;
    //     var max = null;
    //     var macroLists = [trends[:protein], trends[:carbs], trends[:fat]];

    //     for (var j = 0; j < macroLists.size(); j++) {
    //         var macroTrend = macroLists[j];
    //         for (var i = 0; i < macroTrend.size(); i++) {
    //             var value = macroTrend[i];
    //             if (min == null || value < min) { min = value; }
    //             if (max == null || value > max) { max = value; }
    //         }
    //     }

    //     if (min == null || max == null) { return; }

    //     drawScale(dc, min, max);

    //     drawMacroSection(dc, trends[:protein], Graphics.COLOR_BLUE, min, max);
    //     drawMacroSection(dc, trends[:carbs], Graphics.COLOR_ORANGE, min, max);
    //     drawMacroSection(dc, trends[:fat], Graphics.COLOR_YELLOW, min, max);
    // }

    // function drawScale(dc, min, max) {
    //     var scaleSteps = 5;
    //     var stepValue = ((max - min) / scaleSteps);
    //     var startY = dc.getHeight() * 0.50 + dc.getHeight()*0.55/2;
    //     var stepY = (dc.getHeight() * 0.55) / scaleSteps;

    //     dc.setPenWidth(1);

    //     for (var i = 0; i <= scaleSteps; i++) {
    //         var y = startY - i * stepY;
    //         dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    //         drawDottedLine(dc, dc.getWidth() * 0.23, y, dc.getWidth() * 0.80, y, 5, 5);
    //         var valueLabel = Lang.format("$1$", [(min + i * stepValue).toFloat().format("%.1f")]);
    //         dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
    //         dc.drawText(dc.getWidth() * 0.20, y-dc.getFontHeight(Graphics.FONT_SYSTEM_XTINY)/2, Graphics.FONT_SYSTEM_XTINY, valueLabel, Graphics.TEXT_JUSTIFY_CENTER);
    //     }
    // }

    // function drawMacroSection(dc, trend, color, globalMin, globalMax) {
    //     if (trend.size() < 2) { return; }

    //     // 1. Define the Box (0.25 of screen height)
    //     var screenHeight = dc.getHeight();
    //     var screenWidth = dc.getWidth();

    //     var boxMidLine = screenHeight * 0.50;
    //     var boxHeight = screenHeight * 0.55;
    //     var boxTop = boxMidLine - boxHeight/2;
    //     var boxBottom = boxMidLine + boxHeight/2;

    //     dc.setColor(color, Graphics.COLOR_TRANSPARENT);

    //     var startX = screenWidth * 0.22;
    //     var leap = (screenWidth - startX*2)/(trend.size()-1);

    //     // 2. Use global min and max for normalization
    //     var min = globalMin;
    //     var max = globalMax;

    //     // Prevent division by zero if all values are the same
    //     var range = (max - min).toFloat();
    //     if (range == 0) { range = 1.0; }

    //     // 3. Calculate horizontal spacing
    //     var xSpacing = screenWidth.toFloat() / (trend.size() - 1);

    //     // 4. Draw the lines
    //     dc.setPenWidth(2);

    //     var track_x = startX;
    //     var datapoints = [];

    //     var y1 = -1;
    //     var y2 = -1;
    //     var x1 = -1;
    //     var x2 = -1;
    //     for (var i = 0; i < trend.size() - 1; i++) {
    //         // Normalize current and next point
    //         // (val - min) / range gives a 0.0 to 1.0 multiplier
    //         y1 = boxBottom - ((trend[i] - min) / range * boxHeight);
    //         y2 = boxBottom - ((trend[i+1] - min) / range * boxHeight);
            
    //         x1 = i * xSpacing;
    //         x2 = (i + 1) * xSpacing;


    //         datapoints.add([startX, y1]);
    //         // datapoints.add([startX+leap, y2]);
    //         // dc.drawLine(startX, y1, startX+leap, y2);
    //         startX += leap;
    //     }
    //     datapoints.add([startX, y2]);
    //     drawFluidTrend(dc, datapoints);
    // }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {

    }
}
