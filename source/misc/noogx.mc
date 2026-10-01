import Toybox.Lang;
import Toybox.Math;
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
        var goalValue = 0;
        if (me.fill != null && me.fill > 0) {
            goalValue = Math.round(me.fill.toFloat()).toNumber();
        }
        var actualValue = 0;
        if (me.current != null && me.current >= 0) {
            actualValue = Math.round(me.current.toFloat()).toNumber();
        }
        dc.drawText(me.locationx, dc.getHeight()*0.08, Graphics.FONT_XTINY, goalValue, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(me.locationx, dc.getHeight()*0.76, Graphics.FONT_XTINY, actualValue, Graphics.TEXT_JUSTIFY_CENTER);
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
        dc.setPenWidth(me.strokeWidth);

        var total = 0.0;
        for (var i = 0; i < me.data.size(); i++) {
            var value = me.data[i];
            if (value != null && value > 0) {
                total += value.toFloat();
            }
        }

        if (total <= 0) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(me.centerX, me.centerY, me.radius, me.direction, me.startAngle.toNumber(), me.startAngle.toNumber() - 360);
            return;
        }

        // Each slice covers its share of the total, so the arcs always add up to
        // a complete 360 degree circle that reflects the ratio, regardless of how
        // the incoming values are rounded.
        var endAngle = me.startAngle.toFloat();
        var drewSlice = false;
        var lastSliceIndex = 0;
        var lastSliceStart = me.startAngle.toFloat();
        var lastDrawnEnd = me.startAngle.toFloat();
        for (var i = 0; i < me.data.size(); i++) {
            var value = me.data[i];
            if (value == null || value <= 0) {
                continue;
            }
            var sliceStart = endAngle;
            endAngle = sliceStart - value.toFloat() / total * 360.0;
            if (sliceStart.toNumber() == endAngle.toNumber()) {
                continue;
            }
            dc.setColor(colorList[i % colorList.size()], Graphics.COLOR_TRANSPARENT);
            dc.drawArc(me.centerX, me.centerY, me.radius, me.direction, sliceStart.toNumber(), endAngle.toNumber());
            drewSlice = true;
            lastSliceIndex = i;
            lastSliceStart = sliceStart;
            lastDrawnEnd = endAngle;
        }

        if (!drewSlice) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(me.centerX, me.centerY, me.radius, me.direction, me.startAngle.toNumber(), me.startAngle.toNumber() - 360);
            return;
        }

        // Close the last slice to the seam so integer rounding cannot leave a
        // hairline gap at the end of the circle.
        var seam = me.startAngle.toFloat() - 360.0;
        if (lastDrawnEnd != seam) {
            dc.setColor(colorList[lastSliceIndex % colorList.size()], Graphics.COLOR_TRANSPARENT);
            dc.drawArc(me.centerX, me.centerY, me.radius, me.direction, lastSliceStart.toNumber(), seam.toNumber());
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

        for (var j = 0; j < me.dataSets.size(); j++) {
            var set = me.dataSets[j];
            for (var i = 0; i < set.size(); i++) {
                var value = set[i];
                if (value == null) {
                    continue;
                }
                if (me.minYValue == null || value < me.minYValue) { me.minYValue = value; }
                if (me.maxYValue == null || value > me.maxYValue) { me.maxYValue = value; }
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

        // If no numeric range could be computed (empty / all-null series), skip
        // the spline: the grid + scale are still drawn by drawTable (0..100).
        // Never run (maxYValue - minYValue) when either bound is null.
        if (me.maxYValue == null || me.minYValue == null) {
            return;
        }

        var screenHeight = dc.getHeight();
        var screenWidth = dc.getWidth();
        
        var boxHeight = screenWidth*0.55;
        var boxTop = y - boxHeight/2;
        var boxBottom = y + boxHeight/2;

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        var startX = screenWidth * 0.23;
        var leap = (dc.getWidth() * 0.80 - dc.getWidth() * 0.23)/(trend.size()-1);

        var range = (me.maxYValue - me.minYValue).toFloat();
        if (range == 0) { range = 1.0; }

        var xSpacing = screenWidth.toFloat() / (trend.size() - 1);

        dc.setPenWidth(2);

        var track_x = startX;
        var datapoints = [];

        var y1 = -1;
        var y2 = -1;
        var x1 = -1;
        var x2 = -1;
        for (var i = 0; i < trend.size() - 1; i++) {
            if (trend[i] == null || trend[i+1] == null) {
                startX += leap;
                continue;
            }

            y1 = boxBottom - ((trend[i] - me.minYValue) / range * boxHeight);
            y2 = boxBottom - ((trend[i+1] - me.minYValue) / range * boxHeight);
            
            x1 = i * xSpacing;
            x2 = (i + 1) * xSpacing;


            datapoints.add([startX, y1]);
            startX += leap;
        }
        datapoints.add([startX, y2]);
        drawFluidTrend(dc, datapoints);
    }
}

class TableView {

}
