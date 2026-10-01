import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Communications;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Time.Gregorian;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:background)
class DailyNotificationServiceDelegate extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() as Void {
        var notificationMessage = "SparkyFit: Time to log!";
        
        Background.requestApplicationWake(notificationMessage);
        
        if(Application.getApp().getProperty("log_notification")){
            Application.getApp().scheduleDailyNotification(
                Properties.getValue("log_notification_hour_utc"),
                00
            );
        }

        Background.exit(null);
    }
}

class MainEntry extends Application.AppBase {
    var manager;
    var sparkyconnector;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
  
    }

    (:background)
    function getServiceDelegate() as [System.ServiceDelegate] {
        return [ new DailyNotificationServiceDelegate() ];
    }

    function onStop(state as Dictionary?) as Void {
        if (sparkyconnector != null) {
             sparkyconnector.saveToStorage();
        }
    }

    function onBackgroundData(data) {
        writeLog("MainEntry:OnBackgroundData", data, 100);
    }

    function getInitialView(){
        sparkyconnector = new SparkConnect();
        manager = new ViewManager(sparkyconnector);
        return manager.getCurrentPage();
    }

    function onAppUpdate(){
        
    }

    function onAppInstall(){

    }

    function getSparkyConnector() {
        return sparkyconnector;
    }

    (:glance) function getGlanceView() {
        sparkyconnector = new SparkConnect();
        var glanceView = new OverviewGlanceView(sparkyconnector);
        return [ glanceView, new OverviewGlanceDelegate(glanceView) ];
    }  

    (:background) 
    function scheduleDailyNotification(targetHour, targetMinute) as Void {
        if (Toybox.System has :ServiceDelegate) {
            try {
                var hour = 0;
                if (targetHour instanceof Number) {
                    hour = targetHour % 24;
                } else if (targetHour instanceof String) {
                    var parsedHour = targetHour.toNumber();
                    if (parsedHour != null) {
                        hour = parsedHour % 24;
                    }
                }
                if (hour < 0) {
                    hour = 0;
                }

                var minute = 0;
                if (targetMinute instanceof Number) {
                    minute = targetMinute % 60;
                } else if (targetMinute instanceof String) {
                    var parsedMinute = targetMinute.toNumber();
                    if (parsedMinute != null) {
                        minute = parsedMinute % 60;
                    }
                }
                if (minute < 0) {
                    minute = 0;
                }

                var now = Time.now();
                var todayInfo = Gregorian.info(now, Time.FORMAT_MEDIUM);

                var targetOptions = {
                    :year   => todayInfo.year,
                    :month  => todayInfo.month,
                    :day    => todayInfo.day,
                    :hour   => hour,
                    :minute => minute,
                    :second => 0
                };

                var targetMoment = Gregorian.moment(targetOptions);

                if (targetMoment.lessThan(now)) {
                    var oneDay = new Time.Duration(Gregorian.SECONDS_PER_DAY);
                    targetMoment = targetMoment.add(oneDay);
                }

                var timeFromNow = targetMoment.subtract(now).value();
                if (timeFromNow < 300) {
                    var oneDay = new Time.Duration(Gregorian.SECONDS_PER_DAY);
                    targetMoment = targetMoment.add(oneDay);
                }

                Background.registerForTemporalEvent(targetMoment);
                System.println("Daily notification scheduled at " + hour.toString() + ":" + minute.toString());
            } catch (ex) {
                System.println("scheduleDailyNotification failed: " + ex.getErrorMessage());
            }
        } else {
            System.println("Backgrounding not supported on this device.");
        }
    }
}