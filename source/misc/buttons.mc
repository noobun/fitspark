import Toybox.Lang;
import Toybox.WatchUi;
using WatchUi as Ui;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;
using Toybox.Graphics;
using Toybox.Attention;
using Toybox.Math;

class RoundIconButton extends WatchUi.Drawable {
    private var _form;
    private var _locX=0;
    private var _locY=0;

    function initialize(params) {
        Drawable.initialize(params);
        _form = params.get(:form); // true for +, false for -
        _locX = params.get(:locX);
        _locY = params.get(:locY);
    }

    function draw(dc) {
        var diameter = dc.getWidth()*0.06;

        var width = _locX + diameter;
        var height = _locY + diameter;
        
        // 1. Draw Rounded Rectangle Background
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        // fillRoundedRectangle(x, y, width, height, radius)
        dc.fillCircle(_locX+diameter/2, _locY+diameter/2, diameter/2);

        // 2. Draw the Icon (White)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        
        var centerX = locX + (width / 2);
        var centerY = locY + (height / 2);
        var size = dc.getWidth()*0.06; // length of the lines

        if (_form.equals("+") || _form.equals("-")) {
            dc.drawLine(centerX - size, centerY, centerX + size, centerY);
            // Vertical line (only for plus)
            if (_form.equals("+")) {
                dc.drawLine(centerX, centerY - size, centerX, centerY + size);
            }
        }else if (_form.equals(">") || _form.equals("<")) {
            var offset = size * 0.5;
            if (_form.equals(">")) {
                // Draw > shape
                dc.drawLine(centerX - offset, centerY - offset, centerX + offset, centerY);
                dc.drawLine(centerX + offset, centerY, centerX - offset, centerY + offset);
            } else {
                // Draw < shape
                dc.drawLine(centerX + offset, centerY - offset, centerX - offset, centerY);
                dc.drawLine(centerX - offset, centerY, centerX + offset, centerY + offset);
            }
        }else{
            writeLog("RoundIconButton:draw", "Unknown form: "+_form, 100);
        }

        
    }
}

class RoundSubmitButton extends WatchUi.Drawable {
    private var _locX=0;
    private var _locY=0;


    function initialize(params) {
        Drawable.initialize(params);
        _locX = params.get(:locX);
        _locY = params.get(:locY);
    }

    function draw(dc) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // Horizontal line (common to both)
        dc.drawText(_locX, _locY-dc.getFontHeight(Graphics.FONT_MEDIUM), Graphics.FONT_MEDIUM, "SUBMIT", Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class RectangleSubmitButton extends WatchUi.Drawable {
    private var locX;
    private var locY;
    private var color = Graphics.COLOR_GREEN;

    function initialize(params) {
        Drawable.initialize(params);
        locX = params[:locX];
        locY = params[:locY];
        color = params.get(:color);
    }

    function draw(dc) {
        // Draw green rectangle
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, dc.getHeight()*0.8, dc.getWidth(), dc.getHeight() - dc.getHeight()*0.8);
        
        // Draw white SUBMIT text
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - dc.getFontHeight(Graphics.FONT_MEDIUM) / 2, Graphics.FONT_MEDIUM, "SUBMIT", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
