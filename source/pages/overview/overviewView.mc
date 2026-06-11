import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Timer;

class overviewView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;

    private var caloriesActual = 0;
    private var caloriesGoal = -1;

    private var calorieImage;

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector; // Assuming sparkyconnector is the SparkConnect instance
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        writeLog("overviewView:Init", "DONE", 10);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        calorieImage = WatchUi.loadResource(Rez.Drawables.Calories);
        WatchUi.requestUpdate();
    }

    function onSparkyDataUpdated() as Void {
        caloriesActual = _sparkyconnector.getCaloriesConsumed();
        caloriesGoal = _sparkyconnector.getCaloriesGoal();
        WatchUi.requestUpdate();
    }

    // Called when this View is brought to the foreground
    function onShow() as Void {
        // Sync data when view is shown
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            caloriesActual = _sparkyconnector.getCaloriesConsumed();
            caloriesGoal = _sparkyconnector.getCaloriesGoal();
            _sparkyconnector.fetchNutrition(null);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear screen with a black background
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();


        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var fontHeight = Graphics.getFontHeight(Graphics.FONT_SMALL);

        // Draw header with user name and date
        drawHeader(dc, centerX);

        // Draw calorie information
        drawCalories(dc, centerX, dc.getHeight() * 0.6);
    }

    private function drawHeader(dc, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.setPenWidth(2);

        var x = (dc.getWidth() - calorieImage.getWidth()) / 2;
        var y = dc.getHeight()*0.30 - calorieImage.getHeight()/ 2;

        // Draw the bitmap: drawBitmap(x, y, bitmapResource)
        dc.drawBitmap(x, y, calorieImage);
        
    }

    private function drawCalories(dc, centerX, y) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // var calorieText = Lang.format("$1$ / $2$", [caloriesActual, caloriesGoal]);
        dc.fillRoundedRectangle(centerX - dc.getWidth()*0.75/2, y - dc.getHeight()*0.20/2, dc.getWidth()*0.75, dc.getHeight()*0.20, 10);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, y-dc.getFontHeight(Graphics.FONT_MEDIUM)/2, Graphics.FONT_MEDIUM, caloriesActual + "/" + caloriesGoal, Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, y+dc.getFontHeight(Graphics.FONT_MEDIUM)/2+dc.getFontHeight(Graphics.FONT_SMALL)/2, Graphics.FONT_SMALL, "kcal", Graphics.TEXT_JUSTIFY_CENTER);
        
        // Percentage of goal
        var percentage = 0;
        if (caloriesGoal and caloriesGoal > 0) {
            percentage = (caloriesActual * 100) / caloriesGoal;
            if (percentage > 100) {
                percentage = 100;
            }
        }

        // Progress bar
        drawProgressBar(dc, centerX, y + 65, percentage);
    }

    private function drawProgressBar(dc, centerX, y, percentage) {
        var radius = centerX - 5; // 5 pixel margin from edge

        var background_color = Graphics.COLOR_DK_GRAY;
        var foreground_color = Graphics.COLOR_RED;

        if (percentage <= 75) {
            foreground_color = Graphics.COLOR_GREEN;
        }else if (percentage > 75 && percentage <= 95) {
            foreground_color = Graphics.COLOR_YELLOW;
        } else {
            foreground_color = Graphics.COLOR_RED;
        }

        // 1. Draw a background track (optional, light gray)
        dc.setPenWidth(dc.getWidth() * 0.06); // Thickness of the arc
        dc.setColor(background_color, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(centerX, centerX, radius);

        // 2. Draw a background track (optional, light gray)
        if (percentage > 0) {
            var angleAmount = percentage.toNumber() * 360 / 100;
            var startAngle = 90;
            var endAngle = angleAmount + 90; 
            // writeLog("overviewView:drawProgressBar", "Percentage: " + percentage + ", Angle: " + angleAmount + ", Drawing arc from " + startAngle + " to " + endAngle, 10);
            dc.setColor(foreground_color, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(centerX, centerX, radius, Graphics.ARC_COUNTER_CLOCKWISE, startAngle, endAngle);
        }
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
