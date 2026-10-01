import Toybox.Lang;
import Toybox.WatchUi;
using WatchUi as Ui;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;
using Toybox.Graphics;
using Toybox.Attention;

function getMainMenu() {
    var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.AppVersion)});
    var delegate;
    
    menu.addItem(
        new MenuItem(
            "Glance Data",
            "",
            "glancedata",
            {}
        )
    );
    menu.addItem(
        new MenuItem(
            "Sync Settings",
            "",
            "sync_settings",
            {}
        )
    );
    menu.addItem(
        new MenuItem(
            "View Settings",
            "",
            "view_settings",
            {}
        )
    );
    menu.addItem(
        new MenuItem(
            "Generic Options",
            "",
            "generic_options",
            {}
        )
    );

    delegate = new MainMenuInputDelegate(menu);

    WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    return true;
}


function getSyncOptions(parent, event_name) {
    var menu = new WatchUi.Menu2({:title=>"Sync Settings"});
    var delegate;
    var item = parent;

    menu.addItem(
        new MenuItem(
            "Host",
            Properties.getValue("sparkyfithost"),
            "sparkyfithost",
            {}
        )
    );
    menu.addItem(
        new MenuItem(
            "API KEY",
            "****",
            "apikey",
            {}
        )
    );
    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Glance Sync", 
            {:enabled=>"On", :disabled=>"Off"},
            "glance_sync",
            Application.getApp().getProperty("glancesync"),
            null
        )
    );
    menu.addItem(
        new MenuItem(
            "Sync Nutrients", 
            "Mobile | Summary",
            "sync_preferences",
            {}
        )
    );
    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Cache Data",
            {:enabled=>"On", :disabled=>"Off"},
            "persist_data",
            Application.getApp().getProperty("persist_data"),
            null
        )
    );

    delegate = new SyncOptionsDelegate(menu, item, event_name);

    WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    return true;
}

function getGenericOptions(parent, event_name) {
    var menu = new WatchUi.Menu2({:title=>"Generic Options"});
    var delegate;
    var item = parent;

    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Log Notification", 
            {:enabled=>"On", :disabled=>"Off"},
            "log_notification",
            Application.getApp().getProperty("log_notification"),
            null
        )
    );

    delegate = new GenericOptionsDelegate(menu, item, event_name);

    WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    return true;
}

function getViewOptions(parent, event_name) {
    var menu = new WatchUi.Menu2({:title=>"View Settings"});
    var delegate;
    var item = parent;

    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Calories", 
            {:enabled=>"On", :disabled=>"Off"},
            "view_calories",
            Application.getApp().getProperty("view_calories"),
            null
        )
    );
    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Nutrition", 
            {:enabled=>"On", :disabled=>"Off"},
            "view_nutrition",
            Application.getApp().getProperty("view_nutrition"),
            null
        )
    );
    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Nutrition Trends", 
            {:enabled=>"On", :disabled=>"Off"},
            "view_nutrition_trends",
            Application.getApp().getProperty("view_nutrition_trends"),
            null
        )
    );
    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Cal. Breakdown", 
            {:enabled=>"On", :disabled=>"Off"},
            "view_calories_breakdown",
            Application.getApp().getProperty("view_calories_breakdown"),
            null
        )
    );
    

    if (Capabilities.HAS_TOUCH_HARDWARE) {
        menu.addItem(
            new WatchUi.ToggleMenuItem(
                "Hidratation", 
                {:enabled=>"On", :disabled=>"Off"},
                "view_hydration",
                Application.getApp().getProperty("view_hydration"),
                null
            )
        );
    }
    if (Capabilities.HAS_TOUCH_HARDWARE) {
        menu.addItem(
            new WatchUi.ToggleMenuItem(
                "Weight", 
                {:enabled=>"On", :disabled=>"Off"},
                "view_weight",
                Application.getApp().getProperty("view_weight"),
                null
            )
        );
    }
    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Weight Trends", 
            {:enabled=>"On", :disabled=>"Off"},
            "view_weight_trends",
            Application.getApp().getProperty("view_weight_trends"),
            null
        )
    );

    delegate = new ViewOptionsDelegate(menu, item, event_name);

    WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    return true;
}

function getGlanceDataMenu(parent, event_name) {
    var menu = new WatchUi.Menu2({:title=>"Select Data"});
    var delegate;
    var item = parent;

    menu.addItem(
        new MenuItem(
            "CALORIES",
            "",
            "calories",
            {}
        )
    );
    menu.addItem(
        new MenuItem(
            "PROTEIN",
            "",
            "protein",
            {}
        )
    );
    menu.addItem(
        new MenuItem(
            "CARBS",
            "",
            "carbs",
            {}
        )
    );
    menu.addItem(
        new MenuItem(
            "FATS",
            "",
            "fat",
            {}
        )
    );
    menu.addItem(
        new MenuItem(
            "WATER",
            "",
            "water",
            {}
        )
    );

    delegate = new GlanceDataMenuDelegate(menu, item, event_name);

    WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    return true;
}

function getWaterContainersMenu(parent, event_name) {
    var menu = new WatchUi.Menu2({:title=>"Select Container"});
    var delegate;
    var item = parent;

    var containers = Application.getApp().getSparkyConnector().getWaterContainers();

    var keys = containers.keys();
    for (var i = 0; i < keys.size(); i++) {
        var container = containers[keys[i]];
        menu.addItem(
            new MenuItem(
                container["name"],
                container["volume"].toString() + " ml",
                keys[i],
                {}
            )
        );
    }
    menu.addItem(
        new MenuItem(
            "Default",
            "250 ml",
            -1,
            {}
        )
    );

    delegate = new WaterContainersDelegate(menu, item, event_name);

    WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    return true;
}




