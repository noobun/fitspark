import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;
using Toybox.Graphics;
using Toybox.Attention;
import Toybox.System;

class GlanceDataMenuDelegate extends WatchUi.Menu2InputDelegate {

    var menu;
    var parent;
    var inner_event_type;

    function initialize(menu_par, ex_item, event_type) {
        Menu2InputDelegate.initialize();
        menu = menu_par;
        parent=ex_item;
        inner_event_type = event_type;
    }

    function onSelect(item) {
        writeLog("GlanceDataMenuDelegate", "Selected Item for "+inner_event_type+": "+item.getId(), 100);
        if("calories".equals(item.getId())){
            Properties.setValue(inner_event_type, 0);
        }else if("protein".equals(item.getId())){
            Properties.setValue(inner_event_type, 1);
        }else if("carbs".equals(item.getId())){
            Properties.setValue(inner_event_type, 2);
        }else if("fat".equals(item.getId())){
            Properties.setValue(inner_event_type, 3);
        }else if("water".equals(item.getId())){
            Properties.setValue(inner_event_type, 4);
        }else{
            writeLog("GlanceDataMenuDelegate", "selection error", 100);

        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

}

class SyncOptionsDelegate extends WatchUi.Menu2InputDelegate {

    var menu;
    var parent;
    var inner_event_type;

    function initialize(menu_par, ex_item, event_type) {
        Menu2InputDelegate.initialize();
        menu = menu_par;
        parent=ex_item;
        inner_event_type = event_type;
    }

    function onSelect(item) {
        writeLog("SyncOptionsDelegate", "Selected Item for "+inner_event_type+": "+item.getId(), 100);
        var id = item.getId();
        if (item instanceof WatchUi.ToggleMenuItem) {
            var newState = item.isEnabled();
            if (id.equals("glance_sync")) {
                Properties.setValue("glancesync", newState);
            }else if (id.equals("persist_data")) {
                Properties.setValue("persist_data", newState);
            }else{
                writeLog("SyncOptionsDelegate:onSelect", "No valid item selected: "+id, 100);
            }

        } else if (item instanceof WatchUi.MenuItem) {
            if (id.equals("sparkyfithost")) {
                writeLog("SyncOptionsDelegate:onSelect", "sparkyfithost", 100);
                if (WatchUi has :TextPicker) {
                    writeLog("SyncOptionsDelegate:onSelect", "sparkyfithost textpicker", 100);
                    WatchUi.pushView(
                        new WatchUi.TextPicker(Properties.getValue("sparkyfithost")),
                        new AgentEditTextPicker("sparkyfithost", item),
                        WatchUi.SLIDE_LEFT
                    );
                }
            }else if (id.equals("apikey")) {
                if (WatchUi has :TextPicker) {
                    WatchUi.pushView(
                        new WatchUi.TextPicker(Properties.getValue("apikey")),
                        new AgentEditTextPicker("apikey", item),
                        WatchUi.SLIDE_LEFT
                    );
                }
            } else if (id.equals("sync_preferences")) {
                Application.getApp().getSparkyConnector().fetchPreferences();
                WatchUi.showToast("Sync Nutri.", {
                    :icon => WatchUi.loadResource(Rez.Drawables.positiveCheckToastIcon)
                });
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            }else{
                writeLog("SyncOptionsDelegate:onSelect", "No valid item selected: "+id, 100);
            }
        }
    }

}

class ViewOptionsDelegate extends WatchUi.Menu2InputDelegate {

    var menu;
    var parent;
    var inner_event_type;

    function initialize(menu_par, ex_item, event_type) {
        Menu2InputDelegate.initialize();
        menu = menu_par;
        parent=ex_item;
        inner_event_type = event_type;
    }

    function onSelect(item) {
        writeLog("ViewOptionsDelegate", "Selected Item for "+inner_event_type+": "+item.getId(), 100);
        if (item instanceof WatchUi.ToggleMenuItem) {
            var id = item.getId();
            var newState = item.isEnabled();
            
            if (id.equals("view_calories")) {
                Properties.setValue("view_calories", newState);
            }else if (id.equals("view_nutrition")) {
                Properties.setValue("view_nutrition", newState);
            }else if (id.equals("view_calories_breakdown")) {
                Properties.setValue("view_calories_breakdown", newState);
            }else if (id.equals("view_nutrition_trends")) {
                Properties.setValue("view_nutrition_trends", newState);
            }else if (id.equals("view_custom_nutrition")) {
                Properties.setValue("view_custom_nutrition", newState);
            }else if (id.equals("view_hydration")) {
                Properties.setValue("view_hydration", newState);
            }else if (id.equals("view_weight")) {
                Properties.setValue("view_weight", newState);
            }else if (id.equals("view_weight_trends")) {
                Properties.setValue("view_weight_trends", newState);
            }else{
                writeLog("ViewOptionsDelegate", "Unknown toggle option: "+id, 100);
            }
        }
    }

}

class GenericOptionsDelegate extends WatchUi.Menu2InputDelegate {

    var menu;
    var parent;
    var inner_event_type;

    function initialize(menu_par, ex_item, event_type) {
        Menu2InputDelegate.initialize();
        menu = menu_par;
        parent=ex_item;
        inner_event_type = event_type;
    }

    function onSelect(item) {
        writeLog("GenericOptionsDelegate", "Selected Item for "+inner_event_type+": "+item.getId(), 100);
        if (item instanceof WatchUi.ToggleMenuItem) {
            var id = item.getId();
            var newState = item.isEnabled();

            if (id.equals("log_notification")) {
                Properties.setValue("log_notification", newState);
                if (newState) {
                    Application.getApp().scheduleDailyNotification(
                        Properties.getValue("log_notification_hour_utc"),
                        00
                    );
                }else{
                    Background.deleteTemporalEvent();
                }
            }else{
                writeLog("GenericOptionsDelegate", "Unknown toggle option: "+id, 100);
            }
        }
    }
}

class WaterContainersDelegate extends WatchUi.Menu2InputDelegate {

    var menu;
    var parent;
    var inner_event_type;

    function initialize(menu_par, ex_item, event_type) {
        Menu2InputDelegate.initialize();
        menu = menu_par;
        parent=ex_item;
        inner_event_type = event_type;
    }

    function onSelect(item) {
        writeLog("WaterContainersDelegate", "Selected Item for "+inner_event_type+": "+item.getId(), 100);
        Properties.setValue("water_container_id", item.getId());
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}