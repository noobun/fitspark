import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Math;
import Toybox.Timer;

class nutriView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;

    private var pageHint;

    private var goal = {};
    private var actual = {};
    private var yesterday = {};

    private var progressObjects = [];
    private var progressC;
    private var progressF;

    private var interestNutrients = [];

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector;
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }

        interestNutrients = _sparkyconnector.getInterestNutrientsCured();
        if (interestNutrients.size() == 0) {
            interestNutrients = ["protein", "carbs", "fat"];
        }
        writeLog("nutriView:Init", "interestNutrients: " + interestNutrients.toString(), 10);

        var nutrientCount = interestNutrients.size();
        if (nutrientCount > 3) {
            nutrientCount = 3;
        }
        for (var i = 0; i < nutrientCount; i++){
            progressObjects.add(new ProgressBar(interestNutrients[i].substring(0, 1), getColorForData(interestNutrients[i]), Graphics.COLOR_DK_GRAY));
        }
        pageHint = new Rez.Drawables.nextButtonHint();
        writeLog("macroView:Init", "DONE", 10);
    }

    function onLayout(dc as Dc) as Void {
        var padding = 0.25;
        for (var i = 0; i < progressObjects.size(); i++){
            progressObjects[i].customize(dc.getWidth()*padding, dc.getHeight()*0.18, 1, dc.getWidth()*0.1, dc.getHeight()*0.55);
            padding += 0.25;
        }
    }

    function onSparkyDataUpdated() as Void {
        actual = _sparkyconnector.getMacroSetXDaysAgo(interestNutrients, 0);
        goal = _sparkyconnector.getMacroGoal(interestNutrients);
        yesterday = _sparkyconnector.getMacroSetXDaysAgo(interestNutrients, 1);
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            
            actual = _sparkyconnector.getMacroSetXDaysAgo(interestNutrients, 0);
            goal = _sparkyconnector.getMacroGoal(interestNutrients);
            yesterday = _sparkyconnector.getMacroSetXDaysAgo(interestNutrients, 1);

            _sparkyconnector.fetchNutrition(null);
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if(_manager.hasSubView()){
            pageHint.draw(dc);
        }

        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        drawHeader(dc, centerX);

        drawNutrition(dc);
    }

    private function drawHeader(dc, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.setPenWidth(2);

    }

    private function drawNutrition(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var padding = 0.25;
        for (var i = 0; i < progressObjects.size(); i++){
            drawMacro(dc, dc.getWidth()*padding, interestNutrients[i].substring(0,1), actual[interestNutrients[i]], goal[interestNutrients[i]], yesterday[interestNutrients[i]], getColorForData(interestNutrients[i]));
            padding += 0.25;
        }
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
        var goalLabel = 0;
        if (goal != null && goal > 0) {
            goalLabel = Math.round(goal.toFloat()).toNumber();
        }
        var actualLabel = 0;
        if (actual != null && actual >= 0) {
            actualLabel = Math.round(actual.toFloat()).toNumber();
        }
        dc.drawText(x, dc.getHeight()*0.08, Graphics.FONT_XTINY, goalLabel, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(x, dc.getHeight()*0.76, Graphics.FONT_XTINY, actualLabel, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(x, dc.getHeight()*0.84, Graphics.FONT_XTINY, name, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {

    }

    function setData(data) as Lang.Boolean {
        WatchUi.requestUpdate();
        return true;
    }
}
