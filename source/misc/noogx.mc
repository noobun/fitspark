import Toybox.Lang;
import Toybox.WatchUi;
using WatchUi as Ui;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;
using Toybox.Graphics;
using Toybox.Attention;
using Toybox.Math;

class ProgressBar {
    private var fill = 0;
    private var current = 0;
    private var progress = 0;
    private var name = "NA";

    private var fillColor = Graphics.COLOR_WHITE;
    private var backgroundColor = Graphics.COLOR_DK_GRAY;

    private var locationx;
    private var locationy;
    private var orientation;
    private var height;
    private var width;

    function initialize(name, fillColor, backgroundColor){
        me.fillColor = fillColor;
        me.backgroundColor = backgroundColor;
        me.name = name;
    }

    function defineFill(fill){
        me.fill = fill;
    }

    function setCurrent(value){
        me.current = value;
        me.progress = ((me.current.toFloat() / me.fill.toFloat())*100).toNumber();
    }

    function customize(x, y, orientation, height, width){
        me.locationy = y;
        me.locationx = x;
        me.orientation = orientation;
        me.height = height;
        me.width = width;
    }

    function draw(dc, intermediate) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var width = me.width;
        var height = me.height;
        var y = me.locationy;
        var goal;
        var actual;
        if (me.fill > 0) {
            var fillHeight = (me.current.toFloat() / me.fill.toFloat()) * height.toFloat();

            for(var i = 0; i < intermediate.size(); i++){
                var inter = intermediate[i];
                var interHeight = (inter.toFloat() / me.fill.toFloat()) * height.toFloat();
                if (interHeight > height) {
                    interHeight = height;
                }
                dc.setColor(me.fillColor, Graphics.COLOR_TRANSPARENT);
                dc.fillPolygon([
                    [me.locationx-(me.width+4)/2-dc.getWidth()*0.04, y + (height - interHeight)-dc.getWidth()*0.02], 
                    [me.locationx-(me.width+4)/2-dc.getWidth()*0.04, y + (height - interHeight)+dc.getWidth()*0.02], 
                    [me.locationx-(me.width+4)/2, y + (height - interHeight)]
                ]);
            }
        
            if (fillHeight > me.height) {
                fillHeight = me.height;
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(me.backgroundColor, Graphics.COLOR_TRANSPARENT);
            }
            dc.fillRoundedRectangle(me.locationx-(me.width+4)/2, me.locationy, me.width+4, me.height, 6);
            dc.setColor(me.fillColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(me.locationx-me.width/2, me.locationy + (me.height - fillHeight), me.width, fillHeight, 6);
        }else {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(me.locationx-(me.width+4)/2, me.locationy, me.width+4, me.height, 6);
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (me.fill <=0) {
            goal = "TBD";
        }else{
            goal = me.fill;
        }
        if (me.current <0) {
            actual = "TBD";
        }else{
            actual = me.current;
        }
        dc.drawText(me.locationx, dc.getHeight()*0.08, Graphics.FONT_XTINY, goal.toNumber(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(me.locationx, dc.getHeight()*0.76, Graphics.FONT_XTINY, actual, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(me.locationx, dc.getHeight()*0.84, Graphics.FONT_XTINY, me.name, Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class PieChart {
    
    private var data = [];

    private var colorList = [
        Graphics.COLOR_BLUE,
        Graphics.COLOR_DK_GREEN,
        Graphics.COLOR_DK_RED
    ];

    private var centerX;
    private var centerY;
    private var radius;
    private var startAngle;
    private var strokeWidth;
    private var direction;

    function initialize(colorList){
        if (colorList != null) {
            me.colorList = colorList;
        }
    }

    function feedData(dataList){
        me.data = dataList;
    }

    function customize(centerX, centerY, radius, startAngle, strokeWidth, direction){
        me.centerX = centerX;
        me.centerY = centerY;
        me.radius = radius;
        me.startAngle = startAngle;
        me.strokeWidth = strokeWidth;
        me.direction = direction;
    }

    function draw(dc) {
        var startAngle = me.startAngle;
        var endAngle = me.startAngle;

        dc.setPenWidth(me.strokeWidth);

        for (var i = 0; i < me.data.size(); i++) {
            var dataPoint = me.data[i];
            dc.setColor(colorList[i % colorList.size()], Graphics.COLOR_TRANSPARENT);
            if (i == me.data.size() - 1) {
                // To avoid gaps due to rounding errors, make the last slice end at the start angle
                endAngle = me.startAngle;
            } else {
                endAngle = (startAngle - (dataPoint.toFloat()/100*360)).toNumber();
            }
            dc.drawArc(me.centerX, me.centerY, me.radius, me.direction, startAngle, endAngle);
            startAngle=endAngle;
        }

        if (me.data.size() == 0) {
            // Draw empty circle if no data
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(me.centerX, me.centerY, me.radius, me.direction, 0, 360);
        }
    }
}

class MultiGraph {
    private var dataSets = [];
    private var xaxys = [];

    private var colorList = [
        Graphics.COLOR_BLUE,
        Graphics.COLOR_DK_GREEN,
        Graphics.COLOR_DK_RED
    ];

    private var centerX;
    private var centerY;
    private var width;
    private var height;
    private var legend = [];

    private var maxYValue = null;
    private var minYValue = null;

    function initialize(colorList){
        if (colorList != null) {
            me.colorList = colorList;
        }
    }

    function feedData(yaxys, xaxys){
        me.dataSets = yaxys;
        me.xaxys = xaxys;
        calculateMinMax();
    }

    function calculateMinMax(){
        me.maxYValue = null;
        me.minYValue = null;

        for (var j = 0; j < dataSets.size(); j++) {
            var set = dataSets[j];
            for (var i = 0; i < set.size(); i++) {
                var value = set[i];
                if (minYValue == null || value < minYValue) { minYValue = value; }
                if (maxYValue == null || value > maxYValue) { maxYValue = value; }
            }
        }
    }

    function customize(centerX, centerY, width, height, legend){
        me.centerX = centerX;
        me.centerY = centerY;
        me.width = width;
        me.height = height;
        me.legend = legend;
    }

    function draw(dc) {
        drawTable(dc, me.xaxys);
        if (me.legend.size() == me.dataSets.size() and me.colorList.size() == me.dataSets.size()) {
            drawLegend(dc);
        }
        for (var i = 0; i < me.dataSets.size(); i++) {
            var set = me.dataSets[i];
            drawTrend(dc, set, me.centerY, me.colorList[i % me.colorList.size()]);
        }
    }

    function drawLegend(dc){
        var startX = dc.getWidth() * 0.20;
        var barWidth = dc.getWidth()*0.03;

        for (var i = 0; i < me.legend.size(); i++) {
            var item = me.legend[i];
            
        }
    }

    function drawTable(dc, xaxys){
        // Overwrite if no data
        if(xaxys.size() == 0){
            xaxys = [getDateXDaysAgo(0),getDateXDaysAgo(1),getDateXDaysAgo(2),getDateXDaysAgo(3),getDateXDaysAgo(4)];
        }
        var startX = dc.getWidth() * 0.20;
        var leap = xaxys.size() != 1?(dc.getWidth() - startX*2)/(xaxys.size()-1):(dc.getWidth() - startX*2);

        for (var i = 0; i < xaxys.size(); i++) {
            var point = xaxys[i];
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(1);
            
            var shortDate = formatShortDate(point);
            if (i != 0) {
                drawDottedLine(dc, startX, dc.getHeight() * 0.23, startX, dc.getHeight() * 0.78, 5, 5);
            }

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(startX, dc.getHeight() * 0.80, Graphics.FONT_SYSTEM_XTINY, shortDate, Graphics.TEXT_JUSTIFY_CENTER);
            startX += leap;
        }
        
        if (me.minYValue != null && me.maxYValue != null){
            drawScale(dc, me.minYValue, me.maxYValue);
        }
        else{
            drawScale(dc, 0, 100);
        }
    }

    function drawScale(dc, min, max) {
        var scaleSteps = 5;
        var stepValue = ((max - min) / scaleSteps);
        var startY = dc.getHeight() * 0.50 + dc.getHeight()*0.55/2;
        var stepY = (dc.getHeight() * 0.55) / scaleSteps;

        dc.setPenWidth(1);

        for (var i = 0; i <= scaleSteps; i++) {
            var y = startY - i * stepY;
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            drawDottedLine(dc, dc.getWidth() * 0.23, y, dc.getWidth() * 0.80, y, 5, 5);
            var valueLabel = Lang.format("$1$", [(min + i * stepValue).toFloat().format("%.1f")]);
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(dc.getWidth() * 0.25, y-dc.getFontHeight(Graphics.FONT_SYSTEM_XTINY)/2, Graphics.FONT_SYSTEM_XTINY, valueLabel, Graphics.TEXT_JUSTIFY_RIGHT);
        }
    }

    function drawTrend(dc, trend, y, color) {
        if (trend.size() < 2) { return; }

        // 1. Define the Box (0.25 of screen height)
        var screenHeight = dc.getHeight();
        var screenWidth = dc.getWidth();
        
        var boxHeight = screenWidth*0.55;
        var boxTop = y - boxHeight/2; // Centered vertically
        var boxBottom = y + boxHeight/2;

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        var startX = screenWidth * 0.23;
        var leap = (dc.getWidth() * 0.80 - dc.getWidth() * 0.23)/(trend.size()-1);

        // Prevent division by zero if all values are the same
        var range = (me.maxYValue - me.minYValue).toFloat();
        if (range == 0) { range = 1.0; }

        // 3. Calculate horizontal spacing
        var xSpacing = screenWidth.toFloat() / (trend.size() - 1);

        // 4. Draw the lines
        dc.setPenWidth(2);

        var track_x = startX;
        var datapoints = [];

        var y1 = -1;
        var y2 = -1;
        var x1 = -1;
        var x2 = -1;
        for (var i = 0; i < trend.size() - 1; i++) {
            // Normalize current and next point
            // (val - min) / range gives a 0.0 to 1.0 multiplier
            y1 = boxBottom - ((trend[i] - me.minYValue) / range * boxHeight);
            y2 = boxBottom - ((trend[i+1] - me.minYValue) / range * boxHeight);
            
            x1 = i * xSpacing;
            x2 = (i + 1) * xSpacing;


            datapoints.add([startX, y1]);
            // datapoints.add([startX+leap, y2]);
            // dc.drawLine(startX, y1, startX+leap, y2);
            startX += leap;
        }
        datapoints.add([startX, y2]);
        drawFluidTrend(dc, datapoints);
    }
}

class TableView {

}