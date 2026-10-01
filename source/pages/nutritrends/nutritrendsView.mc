import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Timer;

class nutritrendsView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;
    private var multigraph;
    private var pageHint;

    private var trends = {};

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
        if (interestNutrients.size() >= 3) {
            multigraph = new MultiGraph([getColorForData(interestNutrients[0]), getColorForData(interestNutrients[1]), getColorForData(interestNutrients[2])]);
        }else{
            multigraph = new MultiGraph(null);
        }
        pageHint = new Rez.Drawables.nextButtonHint();

        writeLog("nutritrendsView:Init", "DONE", 10);
    }

    function onLayout(dc as Dc) as Void {
        WatchUi.requestUpdate();
        if (multigraph != null) {
            if (interestNutrients.size() >= 3) {
                multigraph.customize(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2, dc.getHeight()/2, [interestNutrients[0].substring(0, 1), interestNutrients[1].substring(0, 1), interestNutrients[2].substring(0, 1)]);
            }else{
                multigraph.customize(dc.getWidth()/2, dc.getHeight()/2, dc.getWidth()/2, dc.getHeight()/2, ["", "", ""]);
            }
        }
    }

    function onSparkyDataUpdated() as Void {
        if (interestNutrients.size() >= 3) {
            trends = _sparkyconnector.getMacroSetTrends([interestNutrients[0], interestNutrients[1], interestNutrients[2], "date"]);
        }
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            var interest = [];
            for (var i = 0; i < interestNutrients.size(); i++) {
                interest.add(interestNutrients[i]);
            }
            interest.add("date");
            trends = _sparkyconnector.getMacroSetTrends(interest);
            _sparkyconnector.fetchNutriTrends();
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if(_manager.hasSubView()){
            pageHint.draw(dc);
        }
        if(trends["date"] != null && trends["date"].size() >= 2 && interestNutrients.size() >= 3){
            drawHeader(dc, trends["date"]);
            var t0 = trends[interestNutrients[0]];
            var t1 = trends[interestNutrients[1]];
            var t2 = trends[interestNutrients[2]];
            if (t0 == null) { t0 = []; }
            if (t1 == null) { t1 = []; }
            if (t2 == null) { t2 = []; }
            multigraph.feedData([t0, t1, t2], trends["date"]);
        }else{
            multigraph.feedData([[], [], []], []);
        }
        multigraph.draw(dc);

    }

    private function drawHeader(dc, dates) {
        dc.setPenWidth(2);

        var startX = dc.getWidth() * 0.20;
        var leap = (dc.getWidth() - startX*2)/(trends["date"].size()-1);
        var barWidth = dc.getWidth()*0.03;

        dc.setColor(getColorForData(interestNutrients[0]), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(dc.getWidth()/2 - barWidth*6, dc.getWidth()*0.05, barWidth, dc.getFontHeight(Graphics.FONT_XTINY));
        
        dc.setColor(getColorForData(interestNutrients[1]), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(dc.getWidth()/2 - barWidth/2, dc.getWidth()*0.05, barWidth, dc.getFontHeight(Graphics.FONT_XTINY));

        dc.setColor(getColorForData(interestNutrients[2]), Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(dc.getWidth()/2 + barWidth*5.5, dc.getWidth()*0.05, barWidth, dc.getFontHeight(Graphics.FONT_XTINY));

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2 - barWidth*7, dc.getWidth()*0.05, Graphics.FONT_XTINY, interestNutrients[0].substring(0, 1).toUpper(), Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(dc.getWidth()/2 - barWidth*1.5, dc.getWidth()*0.05, Graphics.FONT_XTINY, interestNutrients[1].substring(0, 1).toUpper(), Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(dc.getWidth()/2 + barWidth*4.5, dc.getWidth()*0.05, Graphics.FONT_XTINY, interestNutrients[2].substring(0, 1).toUpper(), Graphics.TEXT_JUSTIFY_RIGHT);

    }

    function onHide() as Void {

    }
}
