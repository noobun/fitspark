import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Application;
import Toybox.System;
import Toybox.Timer;

class weightView extends WatchUi.View {

    private var _sparkyconnector;
    private var _manager;

    private var weightActual = 0;

    private var scaleImage;
    private var _requestTimer;
    private var _requestCount = 0;

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        View.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector; // Assuming sparkyconnector is the SparkConnect instance
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
        }
        writeLog("weightView:Init", "DONE", 10);
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        scaleImage = WatchUi.loadResource(Rez.Drawables.Scale);

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
                    :locX => 0, :locY => 0, :color => Graphics.COLOR_GREEN
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

    function onSparkyDataUpdated() as Void {
        weightActual = _sparkyconnector.getWeight();
        WatchUi.requestUpdate();
    }

    function onShow() as Void {
        if (_sparkyconnector != null) {
            _sparkyconnector.setOnDataUpdatedCallback(method(:onSparkyDataUpdated));
            weightActual = _sparkyconnector.getWeight();
            _sparkyconnector.fetchWeight();
        }
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear screen with a black background
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        View.onUpdate(dc);

        if(_manager.hasSubView()){
            var pageHint = new Rez.Drawables.nextButtonHint();
            pageHint.draw(dc);
        }

        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;

        // Draw header with user name and date
        drawHeader(dc, centerX);

        // Draw weight information
        drawWeight(dc, centerX, dc.getHeight()*0.55);
    }

    private function drawHeader(dc, centerX) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.setPenWidth(2);
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);

        var x = (dc.getWidth() - scaleImage.getWidth()) / 2;
        var y = (dc.getHeight()/3 - scaleImage.getHeight()) / 2;

        // Draw the bitmap: drawBitmap(x, y, bitmapResource)
        dc.drawBitmap(x, y, scaleImage);
        
        // Draw SUBMIT button rectangle and text
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() - (dc.getHeight() - centerX*2*0.8) / 2 - dc.getFontHeight(Graphics.FONT_SMALL) / 2, Graphics.FONT_SMALL, "SUBMIT", Graphics.TEXT_JUSTIFY_CENTER);
    }

    private function drawWeight(dc, centerX, y) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var weightText = Lang.format("$1$", [weightActual.format("%.1f")]);

        dc.drawText(centerX, y - dc.getFontHeight(Graphics.FONT_NUMBER_HOT)/2, Graphics.FONT_NUMBER_HOT, weightText, Graphics.TEXT_JUSTIFY_CENTER);
        // dc.drawText(centerX, y + dc.getFontHeight(Graphics.FONT_NUMBER_HOT)/2-dc.getFontHeight(Graphics.FONT_XTINY), Graphics.FONT_XTINY, "kg", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onHide() as Void {

    }

    public function receiveWeightData(weight) as Void {
        weightActual = weight;
        WatchUi.requestUpdate();
    }

    public function getWeight() as Float {
        writeLog("weightView:getWeight", "Current weight: " + weightActual, 10);
        return weightActual;
    }
}
