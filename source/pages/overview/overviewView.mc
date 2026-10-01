import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Math;
import Toybox.Timer;

class overviewView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;

    private var caloriesActual = 0;
    private var caloriesGoal = 0;

    private var calorieImage;

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector;
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        writeLog("overviewView:Init", "DONE", 10);
    }

    function onLayout(dc as Dc) as Void {
        calorieImage = WatchUi.loadResource(Rez.Drawables.Calories);
        WatchUi.requestUpdate();
    }

    function onSparkyDataUpdated() as Void {
        caloriesActual = _sparkyconnector.getCaloriesConsumed();
        caloriesGoal = _sparkyconnector.getCaloriesGoal();
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            caloriesActual = _sparkyconnector.getCaloriesConsumed();
            caloriesGoal = _sparkyconnector.getCaloriesGoal();
            _sparkyconnector.fetchNutrition(null);
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();


        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var fontHeight = Graphics.getFontHeight(Graphics.FONT_SMALL);

        drawHeader(dc, centerX);

        drawCalories(dc, centerX, dc.getHeight() * 0.6);
    }

    private function drawHeader(dc, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.setPenWidth(2);

        var x = (dc.getWidth() - calorieImage.getWidth()) / 2;
        var y = dc.getHeight()*0.30 - calorieImage.getHeight()/ 2;

        dc.drawBitmap(x, y, calorieImage);
        
    }

    private function drawCalories(dc, centerX, y) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.fillRoundedRectangle(centerX - dc.getWidth()*0.75/2, y - dc.getHeight()*0.20/2, dc.getWidth()*0.75, dc.getHeight()*0.20, 10);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        var actualValue = 0;
        if (caloriesActual != null && caloriesActual > 0) {
            actualValue = Math.round(caloriesActual.toFloat()).toNumber();
        }
        var goalValue = 0;
        if (caloriesGoal != null && caloriesGoal > 0) {
            goalValue = Math.round(caloriesGoal.toFloat()).toNumber();
        }
        var calorieText = actualValue + "/" + goalValue;
        dc.drawText(centerX, y-dc.getFontHeight(Graphics.FONT_MEDIUM)/2, Graphics.FONT_MEDIUM, calorieText, Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, y+dc.getFontHeight(Graphics.FONT_MEDIUM)/2+dc.getFontHeight(Graphics.FONT_SMALL)/2, Graphics.FONT_SMALL, "kcal", Graphics.TEXT_JUSTIFY_CENTER);
        
        var percentage = 0;
        if (goalValue > 0 && actualValue > 0) {
            percentage = (actualValue * 100) / goalValue;
            if (percentage > 100) {
                percentage = 100;
            }
        }

        drawProgressBar(dc, centerX, y + 65, percentage);
    }

    private function drawProgressBar(dc, centerX, y, percentage) {
        var radius = centerX - 5;

        var background_color = Graphics.COLOR_DK_GRAY;
        var foreground_color = Graphics.COLOR_RED;

        if (percentage <= 75) {
            foreground_color = Graphics.COLOR_GREEN;
        }else if (percentage > 75 && percentage <= 95) {
            foreground_color = Graphics.COLOR_YELLOW;
        } else {
            foreground_color = Graphics.COLOR_RED;
        }

        dc.setPenWidth(dc.getWidth() * 0.06);
        dc.setColor(background_color, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(centerX, centerX, radius);

        if (percentage > 0) {
            var angleAmount = percentage.toNumber() * 360 / 100;
            var startAngle = 90;
            var endAngle = angleAmount + 90; 
            dc.setColor(foreground_color, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(centerX, centerX, radius, Graphics.ARC_COUNTER_CLOCKWISE, startAngle, endAngle);
        }
    }

    function onHide() as Void {

    }

    function setData(data) as Lang.Boolean {
        WatchUi.requestUpdate();
        return true;
    }
}
