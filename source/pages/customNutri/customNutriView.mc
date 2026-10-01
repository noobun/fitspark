import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Math;
import Toybox.Timer;
using Toybox.Math;

class customNutriView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;

    private var page = 0;
    private var itemPerPage = 7;
    private var pageHint;

    private var macroActual = {};
    private var macroGoal = {};
    private var macroList = [];

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector;
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        pageHint = new Rez.Drawables.nextButtonHint();
        writeLog("customNutriView:Init", "DONE", 10);
    }

    function onLayout(dc as Dc) as Void {
        WatchUi.requestUpdate();
        if (Capabilities.HAS_TOUCH_HARDWARE) {
            var submitBtn = new WatchUi.Button({
                :stateDefault => new RectangleSubmitButton({
                    :locX => 0, :locY => 0, :color => Graphics.COLOR_BLUE
                }),
                :locX => 0, :locY => dc.getHeight() * 0.8,
                :width => dc.getWidth(), :height => dc.getHeight() * 0.2,
                :behavior => :onSubmitPressed
            });
            setLayout([submitBtn]);
        }
    }

    function sync(){
        macroActual = _sparkyconnector.getMacrosXDaysAgo(0);
        macroGoal = _sparkyconnector.getGoals();
        macroList = _sparkyconnector.getInterestNutrients();
    }

    function onSparkyDataUpdated() as Void {
        sync();
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            sync();
            _sparkyconnector.fetchNutrition(null);
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        View.onUpdate(dc);

        if(_manager.hasSubView()){
            pageHint.draw(dc);
        }

        drawTable(dc, macroActual, macroGoal);
        drawHeader(dc, dc.getHeight() * 0.4);
    }

    private function drawTable(dc, actual, goal) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        
        if (macroList.size() == 0){
            dc.drawText(dc.getWidth() * 0.5, dc.getHeight() * 0.2, Graphics.FONT_XTINY, "Add custom nutrients\nin sparkyfitness for\nmobile summary", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var startIdx = page * itemPerPage;
        var endIdx = startIdx + itemPerPage; 

        if (startIdx >= macroList.size()) {
            page = 0;
            startIdx = 0;
            endIdx = startIdx + itemPerPage;
        }

        if (endIdx > macroList.size()) {
            endIdx = macroList.size();
        }
        for (var i = startIdx; i < endIdx; i++) {
            var macro = macroList[i];
            var actualValue = getSafeValue(actual, macro, 0);
            var goalValue = getSafeValue(goal, macro, 0);
            var text = macro + ": " + Math.round(actualValue.toFloat()).toNumber() + " / " + Math.round(goalValue.toFloat()).toNumber();
            dc.drawText(dc.getWidth() * 0.2, dc.getHeight() * 0.2 + i%itemPerPage * dc.getFontHeight(Graphics.FONT_XTINY), Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    private function drawHeader(dc, dates) {
        if (macroList.size() <= itemPerPage){
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        }else{
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(dc.getWidth() / 2, dc.getHeight()*0.9 - dc.getFontHeight(Graphics.FONT_SMALL) / 2, Graphics.FONT_SMALL, "NEXT", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {

    }

    function nextPage() as Void {
        var totalPages = Math.ceil(macroList.size() / itemPerPage.toFloat());
        if (totalPages <= 0) {
            totalPages = 1;
        }
        if (page >= totalPages - 1) {
            page = 0;
        } else {
            page += 1;
        }
    }
}
