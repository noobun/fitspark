import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Timer;
using Toybox.Math;

class custommacrotrendsView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;
    
    private var page = 0;
    private var itemPerPage = 7;

    private var macroActual = {};
    private var macroGoal = {};
    private var macroList = [];

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector; // Assuming sparkyconnector is the SparkConnect instance
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        writeLog("custommacrotrendsView:Init", "DONE", 10);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        WatchUi.requestUpdate();
        if (System.getDeviceSettings().isTouchScreen) {
            var submitBtn = new WatchUi.Button({
                :stateDefault => new RectangleSubmitButton({
                    :locX => 0, :locY => 0, :color => Graphics.COLOR_BLUE
                }),
                :locX => 0, :locY => dc.getHeight() * 0.8,
                :width => dc.getWidth(), :height => dc.getHeight() * 0.2,
                :behavior => :onSubmitPressed
            });
            // Add it to the view's layout
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
        //writeLog("custommacrotrendsView:onSparkyDataUpdated", "Trend data: " + trends.toString(), 10);
        WatchUi.requestUpdate();
    }

    // Called when this View is brought to the foreground
    function onShow() as Void {
        // Sync data when view is shown
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            sync();
            _sparkyconnector.fetchNutrition(null);
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        View.onUpdate(dc);

        if(_manager.hasSubView()){
            var pageHint = new Rez.Drawables.nextButtonHint();
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

        // Safety cap: Never let the loop look past the end of the dynamic list
        if (endIdx > macroList.size()) {
            endIdx = macroList.size();
        }
        for (var i = startIdx; i < endIdx; i++) {
            var macro = macroList[i];
            var actualValue = actual[macro];
            var goalValue = goal[macro];
            var text = macro + ": " + actualValue.toNumber().toString() + " / " + goalValue.toString();
            dc.drawText(dc.getWidth() * 0.5, dc.getHeight() * 0.2 + i%itemPerPage * dc.getFontHeight(Graphics.FONT_XTINY), Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_CENTER);
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

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {

    }

    function nextPage() as Void {
        page += 1;
        if (page > Math.ceil(macroList.size()/itemPerPage)){
            page = 0;
        }
    }
}
