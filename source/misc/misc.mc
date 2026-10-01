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
    var dx = x2 - x1;
    var dy = y2 - y1;
    var distance = Math.sqrt(dx * dx + dy * dy);
    
    var stepLength = dotLength + gapLength;
    var steps = (distance / stepLength).toNumber();
    
    var ux = dx / distance;
    var uy = dy / distance;

    for (var i = 0; i <= steps; i++) {
        var startX = x1 + (i * stepLength * ux);
        var startY = y1 + (i * stepLength * uy);
        
        var endX = startX + (dotLength * ux);
        var endY = startY + (dotLength * uy);
        
        dc.drawLine(startX, startY, endX, endY);
    }
}

function drawFluidTrend(dc, dataPoints) {
    if (dataPoints.size() < 2) { return; }

    var precision = 4;
    var lastX = null;
    var lastY = null;

    for (var i = 0; i < dataPoints.size() - 1; i++) {
        var p0 = (i == 0) ? dataPoints[i] : dataPoints[i - 1];
        var p1 = dataPoints[i];
        var p2 = dataPoints[i + 1];
        var p3 = (i + 2 < dataPoints.size()) ? dataPoints[i + 2] : dataPoints[i + 1];

        for (var j = 0; j <= precision; j++) {
            var t = j.toFloat() / precision;
            
            var x = 0.5 * ((2 * p1[0]) + (-p0[0] + p2[0]) * t + (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * (t*t) + (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * (t*t*t));
            var y = 0.5 * ((2 * p1[1]) + (-p0[1] + p2[1]) * t + (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * (t*t) + (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * (t*t*t));

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

    var moment = Gregorian.moment({:year=>year, :month=>month, :day=>day});
    
    var info = Gregorian.info(moment, Time.FORMAT_MEDIUM);
    
    return info.day_of_week.substring(0, 1);
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
    var normalized = dataType.toLower();

    var aliasMap = {
        "calories" => "calories",
        "protein" => "protein",
        "carbs" => "carbs",
        "carbohydrates" => "carbs",
        "fat" => "fat",
        "fat_total" => "fat",
        "saturated" => "saturated",
        "saturated_fat" => "saturated",
        "trans" => "trans",
        "trans_fat" => "trans",
        "sugars" => "sugars",
        "added_sugar" => "sugars",
        "fiber" => "fiber",
        "dietary_fiber" => "fiber",
        "cholesterol" => "cholesterol",
        "sodium" => "sodium",
        "potassium" => "potassium",
        "calcium" => "calcium",
        "iron" => "iron",
        "magnesium" => "magnesium",
        "vitamin" => "vitamin",
        "water" => "water",
        "weight" => "weight",
    };

    var colorMap = {
        "calories" => Graphics.COLOR_GREEN,
        "protein" => Graphics.COLOR_BLUE,
        "carbs" => Graphics.COLOR_ORANGE,
        "fat" => Graphics.COLOR_YELLOW,
        "saturated" => Graphics.COLOR_RED,
        "trans" => Graphics.COLOR_RED,
        "sugars" => Graphics.COLOR_PINK,
        "fiber" => Graphics.COLOR_GREEN,
        "cholesterol" => Graphics.COLOR_RED,
        "sodium" => Graphics.COLOR_LT_GRAY,
        "potassium" => Graphics.COLOR_BLUE,
        "calcium" => Graphics.COLOR_BLUE,
        "iron" => Graphics.COLOR_BLUE,
        "magnesium" => Graphics.COLOR_BLUE,
        "vitamin" => Graphics.COLOR_BLUE,
        "water" => Graphics.COLOR_DK_BLUE,
        "weight" => Graphics.COLOR_GREEN,
    };

    if (aliasMap.hasKey(normalized)) {
        normalized = aliasMap.get(normalized);
    }

    if (colorMap.hasKey(normalized)) {
        return colorMap.get(normalized);
    }

    writeLog("GlanceView:getColorForData", "Unknown data type: " + dataType.toString(), 100);
    return Graphics.COLOR_LT_GRAY;
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
    
    if (size == 0) {
        return 0.0; 
    }
    
    var sum = 0.0;
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
