import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Timer;

class waterView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;

    private var waterActual = 0;
    private var waterGoal = 0;
    private var waterContainers = [];
    private var waterContainerID = -1;

    private var waterglassImage = [];

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector;
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        writeLog("waterView:init", "DONE", 10);
    }

    function onLayout(dc as Dc) as Void {
        waterglassImage.add(WatchUi.loadResource(Rez.Drawables.WaterGlass0));
        waterglassImage.add(WatchUi.loadResource(Rez.Drawables.WaterGlass25));
        waterglassImage.add(WatchUi.loadResource(Rez.Drawables.WaterGlass50));
        waterglassImage.add(WatchUi.loadResource(Rez.Drawables.WaterGlass75));
        waterglassImage.add(WatchUi.loadResource(Rez.Drawables.WaterGlass100));

        if (Capabilities.HAS_TOUCH_HARDWARE) {
            var plusBtn = new WatchUi.Button({
                :stateDefault => new RoundIconButton({
                    :locX => 0, :locY => 0, 
                    :form => "-"
                }),
                :locX => dc.getWidth() * 0.15, :locY => dc.getHeight() * 0.275,
                :width => dc.getWidth()*0.1, :height => dc.getWidth()*0.1,
                :behavior => :onMinusPressed
            });
            var minusBtn = new WatchUi.Button({
                :stateDefault => new RoundIconButton({
                    :locX => 0, :locY => 0, 
                    :form => "+"
                }),
                :locX => dc.getWidth() * 0.80, :locY => dc.getHeight() * 0.275,
                :width => dc.getWidth()*0.1, :height => dc.getWidth()*0.1,
                :behavior => :onPlusPressed
            });

            var submitBtn = new WatchUi.Button({
                :stateDefault => new RectangleSubmitButton({
                    :locX => 0, :locY => 0, :color => Graphics.COLOR_BLUE
                }),
                :locX => 0, :locY => dc.getHeight() * 0.8,
                :width => dc.getWidth(), :height => dc.getHeight() * 0.2,
                :behavior => :onSubmitPressed
            });
            setLayout([plusBtn, minusBtn, submitBtn]);
        }

        WatchUi.requestUpdate();
    }

    function fetchWater(){
        var buffer = _sparkyconnector.getWaterConsumed();
        if (buffer != null){
            waterActual = buffer;
        }
        else{
            waterActual = 0;
        }
        buffer = _sparkyconnector.getWaterGoal();
        if (buffer != null){
            waterGoal = buffer;
        }
        buffer = _sparkyconnector.getWaterContainers();
        if (buffer != null){
            waterContainers = buffer;
        }
        buffer = _sparkyconnector.getPrimaryWaterContainerID();
        if (buffer != null){
            waterContainerID = buffer;
        }
    }

    function onSparkyDataUpdated() as Void {
        fetchWater();
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            fetchWater();
            _sparkyconnector.fetchHydration();
            _sparkyconnector.fetchWaterContainers();
        }
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        View.onUpdate(dc);

        var centerX = dc.getWidth() / 2;
        var fontHeight = Graphics.getFontHeight(Graphics.FONT_SMALL);

        drawHeader(dc, dc.getHeight() * 0.4);

        drawWater(dc, centerX, dc.getHeight() * 0.5);
        drawlWaterContainer(dc, centerX, dc.getHeight() * 0.7);
    }

    private function drawHeader(dc, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.setPenWidth(2);
        var step = 0;
        if (waterGoal > 0 && waterActual >= 0) {
            var ratio = waterActual.toFloat() / waterGoal.toFloat();
            step = (ratio * 4).toNumber();
            if (step < 0) {
                step = 0;
            }
        }
        if (waterglassImage.size() > 0 && step > waterglassImage.size() - 1) {
            step = waterglassImage.size() - 1;
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight()*0.9 - dc.getFontHeight(Graphics.FONT_SMALL) / 2, Graphics.FONT_SMALL, "NEXT", Graphics.TEXT_JUSTIFY_CENTER);

        if (waterglassImage.size() > 0) {
            var x = (dc.getWidth() - waterglassImage[step].getWidth()) / 2;
            var y = dc.getHeight()*0.25 - waterglassImage[step].getHeight() / 2;
            dc.drawBitmap(x, y, waterglassImage[step]);
        }
    }

    private function drawWater(dc, centerX, y) {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);

        var waterText = "--";
        if (waterGoal != null && waterGoal > 0) {
            if (waterActual < 0) {
                waterText = Lang.format("$1$ / $2$", ["--", waterGoal]);
            } else {
                waterText = Lang.format("$1$ / $2$", [waterActual, waterGoal]);
            }
        }
        dc.drawText(centerX, y, Graphics.FONT_SMALL, waterText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawlWaterContainer(dc, centerX, y) {
        var height = dc.getHeight() * 0.1;
        var width = dc.getWidth() * 0.8;
        var container = {
            "name" => "cup",
            "volume" => "250",
            "unit" => "ml",
            "id" => -1
        };
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(centerX - width/2, y-height/2, width, height, 5);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

        if (waterContainerID >= 0 && waterContainerID < waterContainers.size()) {
            container = waterContainers[waterContainerID];
        }
        
        var nameStr = container["name"].toString();
        if (nameStr.length() > 8) {
            nameStr = nameStr.substring(0, 8)+"...";
        }
        var volStr = container["volume"].toString();
        if (volStr.length() > 4) {
            volStr = volStr.substring(0, 4);
        }

        dc.drawText(centerX, y - dc.getFontHeight(Graphics.FONT_TINY)/2, Graphics.FONT_TINY, volStr+" "+container["unit"]+" / "+nameStr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {

    }

    function changeWaterContainer(direction) as Lang.Boolean {
        writeLog("waterView:changeWaterContainer", "Changing container in direction: " + direction, 10);

        if (waterContainers == null || waterContainers.size() == 0) {
            waterContainerID = -1;
            writeLog("waterView:changeWaterContainer", "No containers available", 10);
            return true;
        }

        if (waterContainerID < 0 || waterContainerID >= waterContainers.size()) {
            waterContainerID = 0;
            WatchUi.requestUpdate();
            return true;
        }

        var newIndex = waterContainerID + direction;

        if (newIndex >= waterContainers.size()) {
            newIndex = 0;
        } 
        else if (newIndex < 0) {
            newIndex = waterContainers.size() - 1;
        }

        waterContainerID = newIndex;

        WatchUi.requestUpdate();
        return true;
    }

    function getWaterContainer() as Object or Null {
        if (waterContainers == null || waterContainers.size() == 0) {
            return null;
        }
        if (waterContainerID < 0 || waterContainerID >= waterContainers.size()) {
            return null;
        }
        return waterContainers[waterContainerID]["id"];
    }
}
