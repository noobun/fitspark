import Toybox.Lang;
import Toybox.WatchUi;
using WatchUi as Ui;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;
using Toybox.Graphics;
using Toybox.Attention;
using Toybox.Math;
using Toybox.Time.Gregorian;
using Toybox.Time;

function drawDottedLine(dc, x1, y1, x2, y2, dotLength, gapLength) {
    // 1. Calculate total distance between points
    var dx = x2 - x1;
    var dy = y2 - y1;
    var distance = Math.sqrt(dx * dx + dy * dy);
    
    // 2. Determine how many "steps" (dot + gap) fit in that distance
    var stepLength = dotLength + gapLength;
    var steps = (distance / stepLength).toNumber();
    
    // 3. Normalize the direction (unit vector)
    var ux = dx / distance;
    var uy = dy / distance;

    for (var i = 0; i <= steps; i++) {
        // Start of the dot
        var startX = x1 + (i * stepLength * ux);
        var startY = y1 + (i * stepLength * uy);
        
        // End of the dot (don't overshoot the final point)
        var endX = startX + (dotLength * ux);
        var endY = startY + (dotLength * uy);
        
        // Draw the segment
        // datapoints.add([startX, startY]);
        dc.drawLine(startX, startY, endX, endY);
    }
}

function drawFluidTrend(dc, dataPoints) {
    if (dataPoints.size() < 2) { return; }

    var precision = 4; // Number of segments between real data points
    var lastX = null;
    var lastY = null;

    for (var i = 0; i < dataPoints.size() - 1; i++) {
        // Define the 4 control points for the curve
        var p0 = (i == 0) ? dataPoints[i] : dataPoints[i - 1];
        var p1 = dataPoints[i];
        var p2 = dataPoints[i + 1];
        var p3 = (i + 2 < dataPoints.size()) ? dataPoints[i + 2] : dataPoints[i + 1];

        for (var j = 0; j <= precision; j++) {
            var t = j.toFloat() / precision;
            
            // Catmull-Rom Math
            var x = 0.5 * ((2 * p1[0]) + (-p0[0] + p2[0]) * t + (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * (t*t) + (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * (t*t*t));
            var y = 0.5 * ((2 * p1[1]) + (-p0[1] + p2[1]) * t + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * (t*t) + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * (t*t*t));

            // Draw line from the previous sub-point to this one
            if (lastX != null) {
                dc.drawLine(lastX, lastY, x, y);
            }
            
            lastX = x;
            lastY = y;
        }
    }
}

function formatShortDate(dateStr) {
    var year  = dateStr.substring(0, 4).toNumber();
    var month = dateStr.substring(5, 7).toNumber();
    var day   = dateStr.substring(8, 10).toNumber();

    // 2. Create Moment and get Info
    var moment = Gregorian.moment({:year=>year, :month=>month, :day=>day});
    
    // Use FORMAT_MEDIUM to get the string ("Mon")
    var info = Gregorian.info(moment, Time.FORMAT_MEDIUM);
    
    // 3. Return only the first character
    return info.day_of_week.substring(0, 1); // Returns "M"
}

function vibrateAttention() {
    var vibeData =
    [
        new Attention.VibeProfile(50, 250)
    ];
    Attention.vibrate(vibeData);
}

(:glance)
function getColorForData(dataType) {
    var colorMap = {
        "calories" => Graphics.COLOR_GREEN,
        "protein" => Graphics.COLOR_BLUE,
        "carbs" => Graphics.COLOR_ORANGE,
        "fat" => Graphics.COLOR_YELLOW,
        "water" => Graphics.COLOR_DK_BLUE,
        "weight" => Graphics.COLOR_GREEN,
    };
    if (!colorMap.hasKey(dataType)) {
        writeLog("GlanceView:getColorForData", "Unknown data type: " + dataType.toString(), 100);
        return Graphics.COLOR_GREEN; // Default to white if not found
    }
    return colorMap[dataType];
}

(:glance)
function getDateXDaysAgo(daysnr){
    var now = Time.now();
    var agoMoment = now.subtract(new Time.Duration(daysnr.toNumber() * 24 * 60 * 60));
    var info = Gregorian.info(agoMoment, Time.FORMAT_SHORT);
    var agoMomentOuput = Lang.format("$1$-$2$-$3$", [
        info.year,
        info.month.format("%02d"),
        info.day.format("%02d")
    ]);
    return agoMomentOuput;
}

(:glance)
function getDateXDaysNext(daysnr){
    var now = Time.now();
    var agoMoment = now.add(new Time.Duration(daysnr.toNumber() * 24 * 60 * 60));
    var info = Gregorian.info(agoMoment, Time.FORMAT_SHORT);
    var agoMomentOuput = Lang.format("$1$-$2$-$3$", [
        info.year,
        info.month.format("%02d"),
        info.day.format("%02d")
    ]);
    return agoMomentOuput;
}

function getAverage(array) {
    var size = array.size();
    
    // Handle empty array case to prevent division by zero
    if (size == 0) {
        return 0.0; 
    }
    
    var sum = 0.0; // Start with a Float to ensure precision
    for (var i = 0; i < size; i++) {
        if (array[i] != null) {
            sum += array[i];
        }
    }
    
    return sum / size;
}

(:glance)
function getSafeValue(payload, key, fallback){
    return payload.hasKey(key) ? payload.get(key) : fallback;
}