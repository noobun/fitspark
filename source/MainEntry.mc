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

    // This method fires exactly when your scheduled time arrives
    function onTemporalEvent() as Void {
        // Customize your system notification message here
        var notificationMessage = "SparkyFit: Time to log!";
        
        // This pushes a native system notification to the watch UI
        Background.requestApplicationWake(notificationMessage);
        
        if(Application.getApp().getProperty("log_notification")){
            Application.getApp().scheduleDailyNotification(
                Properties.getValue("log_notification_hour_utc"),
                00
            );
        }

        // Always exit the background process properly to release memory
        Background.exit(null);
    }
}

class MainEntry extends Application.AppBase {
    var manager;
    var sparkyconnector;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
  
    }

    // CRITICAL: Tells the OS what to run when the background process wakes up
    function getServiceDelegate() as [System.ServiceDelegate] {
        return [ new DailyNotificationServiceDelegate() ];
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        if (sparkyconnector != null) {
             sparkyconnector.saveToStorage();
        }
    }

    function onBackgroundData(data) {
        writeLog("MainEntry:OnBackgroundData", data, 100);
    }

    // Return the initial view of your application here
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
    function scheduleDailyNotification(targetHour as Integer, targetMinute as Integer) as Void {
        if (Toybox.System has :ServiceDelegate) {
            
            var now = Time.now();
            var todayInfo = Gregorian.info(now, Time.FORMAT_MEDIUM);
            
            // Build the components for today at the targeted hour/minute
            var targetOptions = {
                :year   => todayInfo.year,
                :month  => todayInfo.month,
                :day    => todayInfo.day,
                :hour   => targetHour,
                :minute => targetMinute,
                :second => 0
            };
            
            var targetMoment = Gregorian.moment(targetOptions);
            
            // If the targeted time has already passed today, schedule it for tomorrow
            if (targetMoment.lessThan(now)) {
                var oneDay = new Time.Duration(Gregorian.SECONDS_PER_DAY);
                targetMoment = targetMoment.add(oneDay);
            }
            
            // Enforce Garmin's 5-minute guardrail rule
            var timeFromNow = targetMoment.subtract(now).value();
            if (timeFromNow < 300) { 
                // If it's less than 5 minutes away, push it to tomorrow 
                // or handle it immediately in the foreground.
                var oneDay = new Time.Duration(Gregorian.SECONDS_PER_DAY);
                targetMoment = targetMoment.add(oneDay);
            }

            // Register the event with the OS
            Background.registerForTemporalEvent(targetMoment);
            System.println("Daily notification scheduled successfully!");
        } else {
            System.println("Backgrounding not supported on this device.");
        }
    }
}