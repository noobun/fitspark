import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
using WatchUi as Ui;
import Toybox.Application;
import Toybox.System;
import Toybox.Math;
using Toybox.Math;

(:glance)
class OverviewGlanceView extends WatchUi.GlanceView
{
    var slidingText;
    private var _sparkyconnector;
    private var data=0;
    private var sync=false;
    private var nutritionGoal = {
        :calories => 0,
        :protein => 0,
        :carbs => 0,
        :fat => 0,
        :water => 0
    };
    private var nutritionActual = {
        :calories => 0,
        :protein => 0,
        :carbs => 0,
        :fat => 0,
        :water => 0
    };
    private var left_padding = 0.05;

    function initialize(sparkyconnector) {
        _sparkyconnector = sparkyconnector;
        GlanceView.initialize(); 
        _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
    }

    function onLayout(dc){
        
    }

    function getCorrespondingData(data) {
        if (data == 0) {
            nutritionActual[:calories] = _sparkyconnector.getCaloriesConsumed();
            nutritionGoal[:calories] = _sparkyconnector.getCaloriesGoal();
        }else if (data == 1) {
            nutritionActual[:protein] = _sparkyconnector.getProteinConsumed();
            nutritionGoal[:protein] = _sparkyconnector.getProteinGoal();
        }else if (data == 2) {
            nutritionActual[:carbs] = _sparkyconnector.getCarbsConsumed();
            nutritionGoal[:carbs] = _sparkyconnector.getCarbsGoal();
        }else  if (data == 3) {
            nutritionActual[:fat] = _sparkyconnector.getFatsConsumed();
            nutritionGoal[:fat] = _sparkyconnector.getFatsGoal();
        }else if (data == 4) {
            nutritionActual[:water] = _sparkyconnector.getWaterConsumed();
            nutritionGoal[:water] = _sparkyconnector.getWaterGoal();
        } else {
            writeLog("GlanceView:onShow", "Unknown glance data: " + data.toString(), 100);
        }
    }

    function onSparkyDataUpdated() as Void {
        getCorrespondingData(data);
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        data = Application.getApp().getProperty("glancedata");
        sync = Application.getApp().getProperty("glancesync");
        getCorrespondingData(data);
        if (sync){
            writeLog("GlanceView:onShow", "Glance data: " + data.toString(), 100);
            if (data == 0 || data == 1 || data == 2 || data == 3) {
                _sparkyconnector.fetchNutrition(null);
            }else if (data == 4) {
                _sparkyconnector.fetchHydration();
            } else {
                writeLog("GlanceView:onShow", "Unknown glance data: " + data.toString(), 100);
            }
        }
    }

    function drawNutriTarget(dc, label as String, actual as Number, goal as Number, unit as String, color as Number) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var actualValue = 0;
        if (actual != null && actual >= 0) {
            actualValue = Math.round(actual.toFloat()).toNumber();
        }
        var goalValue = 0;
        if (goal != null && goal > 0) {
            goalValue = Math.round(goal.toFloat()).toNumber();
        }
        var nutritionText = Lang.format("$1$: $2$ / $3$ $4$", [label, actualValue, goalValue, unit]);
        dc.drawText(dc.getWidth()*left_padding, dc.getHeight()*0.15, Graphics.FONT_XTINY, nutritionText, Graphics.TEXT_JUSTIFY_LEFT);

        if (goalValue <= 0 || actual == null || actual < 0) {
            return;
        }

        var progressBarWidth = dc.getWidth() * 0.9;
        var progressBarHeight = dc.getHeight() * 0.2;
        var rawProgress = actual.toFloat() / goal;
        var progress = rawProgress;
        if (progress > 1.0) {
            progress = 1.0;
        }
        var filledWidth = progressBarWidth * progress;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(dc.getWidth()*left_padding, dc.getHeight()*0.22+dc.getFontHeight(Graphics.FONT_XTINY), progressBarWidth, progressBarHeight, 10);

        if(rawProgress > 1.0) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        }else {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        }

        dc.fillRoundedRectangle(dc.getWidth()*left_padding, dc.getHeight()*0.22+dc.getFontHeight(Graphics.FONT_XTINY), filledWidth, progressBarHeight, 10);
    }

    function onHide() as Void {
        writeLog("glanceView:onHide", "Cleanup", 100);
    }

    function onUpdate(dc) {
        if (data == 0) {
            drawNutriTarget(dc, "cal", nutritionActual[:calories], nutritionGoal[:calories], "kcal", getColorForData("calories"));
        }else if (data == 1) {
            drawNutriTarget(dc, "p", nutritionActual[:protein], nutritionGoal[:protein], "g", getColorForData("protein"));
        }else if (data == 2) {
            drawNutriTarget(dc, "c", nutritionActual[:carbs], nutritionGoal[:carbs], "g", getColorForData("carbs"));
        }else  if (data == 3) {
            drawNutriTarget(dc, "f", nutritionActual[:fat], nutritionGoal[:fat], "g", getColorForData("fat"));
        }else if (data == 4) {
            drawNutriTarget(dc, "w", nutritionActual[:water], nutritionGoal[:water], "ml", getColorForData("water"));
        } else {
            writeLog("GlanceView:onShow", "Unknown glance data: " + data.toString(), 100);
        }
    } 
}