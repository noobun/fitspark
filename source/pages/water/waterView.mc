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
        _sparkyconnector = sparkyconnector; // Assuming sparkyconnector is the SparkConnect instance
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        writeLog("overviewView:Init", "DONE", 10);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        waterglassImage.add(WatchUi.loadResource(Rez.Drawables.WaterGlass0));
        waterglassImage.add(WatchUi.loadResource(Rez.Drawables.WaterGlass25));
        waterglassImage.add(WatchUi.loadResource(Rez.Drawables.WaterGlass50));
        waterglassImage.add(WatchUi.loadResource(Rez.Drawables.WaterGlass75));
        waterglassImage.add(WatchUi.loadResource(Rez.Drawables.WaterGlass100));

        if (System.getDeviceSettings().isTouchScreen) {
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
            // Add it to the view's layout
            setLayout([plusBtn, minusBtn, submitBtn]);
        }

        WatchUi.requestUpdate();
    }

    function fetchWater(){
        var buffer = _sparkyconnector.getWaterConsumed();
        if (buffer != null){
            waterActual = buffer;
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
        // writeLog("overviewView:onSparkyDataUpdated", "Data received: " + data.toString(), 10);
        fetchWater();
        WatchUi.requestUpdate();
    }

    // Called when this View is brought to the foreground
    function onShow() as Void {
        // Sync data when view is shown
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            fetchWater();
            _sparkyconnector.fetchHydration();
            _sparkyconnector.fetchWaterContainers();
        }
        // waterContainerID = Properties.getValue("water_container_id");
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear screen with a black background
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        View.onUpdate(dc);

        var centerX = dc.getWidth() / 2;
        // var centerY = dc.getHeight() / 2;
        var fontHeight = Graphics.getFontHeight(Graphics.FONT_SMALL);

        // Draw header with user name and date
        drawHeader(dc, dc.getHeight() * 0.4);

        // Draw water information
        drawWater(dc, centerX, dc.getHeight() * 0.5);
        drawlWaterContainer(dc, centerX, dc.getHeight() * 0.7);
    }

    private function drawHeader(dc, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.setPenWidth(2);
        // dc.drawText(centerX, centerX-dc.getFontHeight(Graphics.FONT_LARGE), Graphics.FONT_LARGE, "Water Intake", Graphics.TEXT_JUSTIFY_CENTER);
        var step = 0;
        if (waterGoal and waterActual and waterGoal > 0) {
            step = Math.ceil((waterActual.toFloat() / waterGoal.toFloat()) * 100 / 25.0).toNumber()-1;
            if (step < 0){
                step = 0;
            }
            // writeLog("waterView:drawHeader", "Water Actual: " + waterActual + " / Water Goal: " + waterGoal + " => Step: " + step, 10);
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight()*0.9 - dc.getFontHeight(Graphics.FONT_SMALL) / 2, Graphics.FONT_SMALL, "NEXT", Graphics.TEXT_JUSTIFY_CENTER);

        var x = (dc.getWidth() - waterglassImage[step].getWidth()) / 2;
        var y = dc.getHeight()*0.25 - waterglassImage[step].getHeight() / 2;
        // Draw the bitmap: drawBitmap(x, y, bitmapResource)
        
        dc.drawBitmap(x, y, waterglassImage[step]);
    }

    private function drawWater(dc, centerX, y) {
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);

        var waterText = Lang.format("$1$ / $2$", [waterActual != -1 ? waterActual : 0, waterGoal]);
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
        
        // Ensure displayed strings are not overly long
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

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {

    }

    function changeWaterContainer(direction) as Lang.Boolean {
        // Pass data payload to view
        writeLog("waterView:changeWaterContainer", "Changing container in direction: " + direction, 10);
        
        var newIndex = waterContainerID + direction;

        // Edge case: Right boundary (Moving past the last item)
        if (newIndex >= waterContainers.size()) {
            newIndex = 0;
        } 
        // Edge case: Left boundary (Moving past the first item)
        else if (newIndex < 0) {
            newIndex = waterContainers.size() - 1;
        }

        waterContainerID = newIndex;

        WatchUi.requestUpdate();
        return true;
    }

    function getWaterContainer() as Object {
        return waterContainers[waterContainerID]["id"]; // Assuming container IDs are 0-based in the array
    }
}
