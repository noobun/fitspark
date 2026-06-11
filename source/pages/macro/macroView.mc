import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Timer;

class macroView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;

    private var goal = {};
    private var actual = {};
    private var yesterday = {};

    private var progressP;
    private var progressC;
    private var progressF;

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector; // Assuming sparkyconnector is the SparkConnect instance
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        progressP = new ProgressBar("p", getColorForData("protein"), Graphics.COLOR_DK_GRAY);
        progressC = new ProgressBar("c", getColorForData("carbs"), Graphics.COLOR_DK_GRAY);
        progressF = new ProgressBar("f", getColorForData("fat"), Graphics.COLOR_DK_GRAY);
        writeLog("macroView:Init", "DONE", 10);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        WatchUi.requestUpdate();
        progressP.customize(dc.getWidth()*0.25, dc.getHeight()*0.18, 1, dc.getWidth()*0.1, dc.getHeight()*0.55);
        progressC.customize(dc.getWidth()*0.5, dc.getHeight()*0.18, 1, dc.getWidth()*0.1, dc.getHeight()*0.55);
        progressF.customize(dc.getWidth()*0.75, dc.getHeight()*0.18, 1, dc.getWidth()*0.1, dc.getHeight()*0.55);
    }

    function onSparkyDataUpdated() as Void {
        actual = _sparkyconnector.getMacroSetXDaysAgo(["protein", "carbs", "fat"], 0);
        goal = _sparkyconnector.getMacroGoal(["protein", "carbs", "fat"]);
        yesterday = _sparkyconnector.getMacroSetXDaysAgo(["protein", "carbs", "fat"], 1);
        WatchUi.requestUpdate();
    }

    // Called when this View is brought to the foreground
    function onShow() as Void {
        // Sync data when view is shown
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            
            actual = _sparkyconnector.getMacroSetXDaysAgo(["protein", "carbs", "fat"], 0);
            goal = _sparkyconnector.getMacroGoal(["protein", "carbs", "fat"]);
            yesterday = _sparkyconnector.getMacroSetXDaysAgo(["protein", "carbs", "fat"], 1);

            _sparkyconnector.fetchNutrition(null);
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

        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        // Draw header with user name and date
        drawHeader(dc, centerX);

        drawNutrition(dc);
    }

    private function drawHeader(dc, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.setPenWidth(2);

        // dc.drawLine(0, centerX*2*0.9, dc.getWidth(), centerX*2*0.9); // Top border
        // dc.drawText(centerX, centerX*2*0.91, Graphics.FONT_XTINY, today, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawNutrition(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        drawMacro(dc, dc.getWidth()*0.25, "p", actual["protein"], goal["protein"], yesterday["protein"], Graphics.COLOR_BLUE);
        drawMacro(dc, dc.getWidth()*0.5, "c", actual["carbs"], goal["carbs"], yesterday["carbs"], Graphics.COLOR_ORANGE);
        drawMacro(dc, dc.getWidth()*0.75, "f", actual["fat"], goal["fat"], yesterday["fat"], Graphics.COLOR_YELLOW);
    }

    private function drawMacro(dc, x, name, actual, goal, yesterday, color) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var width = dc.getWidth()*0.1;
        var height = dc.getHeight()*0.55;
        var y = dc.getHeight()*0.18;
        if (goal > 0) {
            var fillHeight = (actual.toFloat() / goal.toFloat()) * height.toFloat();

            if (yesterday >= 0){
                var markerHeight = (yesterday.toFloat() / goal.toFloat()) * height.toFloat();
                if (markerHeight > height) {
                    markerHeight = height;
                }
                dc.setColor(color, Graphics.COLOR_TRANSPARENT);
                dc.fillPolygon([
                    [x-(width+4)/2-dc.getWidth()*0.04, y + (height - markerHeight)-dc.getWidth()*0.02], 
                    [x-(width+4)/2-dc.getWidth()*0.04, y + (height - markerHeight)+dc.getWidth()*0.02], 
                    [x-(width+4)/2, y + (height - markerHeight)]
                ]);
            }
        
            if (fillHeight > height) {
                fillHeight = height;
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            }
            dc.fillRoundedRectangle(x-(width+4)/2, y, width+4, height, 6);
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x-width/2, y + (height - fillHeight), width, fillHeight, 6);
        }else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(x-(width+4)/2, y, width+4, height, 6);
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (goal <=0) {
            goal = "TBD";
        }
        if (actual <0) {
            actual = "TBD";
        }
        dc.drawText(x, dc.getHeight()*0.08, Graphics.FONT_XTINY, goal.toNumber(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(x, dc.getHeight()*0.76, Graphics.FONT_XTINY, actual, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(x, dc.getHeight()*0.84, Graphics.FONT_XTINY, name, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {

    }

    function setData(data) as Lang.Boolean {
        // Pass data payload to view
        WatchUi.requestUpdate();
        return true;
    }
}
