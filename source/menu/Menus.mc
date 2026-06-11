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
    // menu.addItem(
    //     new MenuItem(
    //         "Custom Nutrients",
    //         "",
    //         "custom_nutrients",
    //         {}
    //     )
    // );
    // menu.addItem(
    //     new MenuItem(
    //         "Water Containers",
    //         "",
    //         "water_containers",
    //         {}
    //     )
    // );

    // Create a new Menu2InputDelegate
    delegate = new MainMenuInputDelegate(menu); // a WatchUi.Menu2InputDelegate

    // Push the Menu2 View set up in the initializer
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
            {:enabled=>"On", :disabled=>"Off"}, // Sub-labels for states
            "glance_sync",                          // Event name for toggle changes
            Application.getApp().getProperty("glancesync"),                           // Initial state (true/false)
            null                                // Optional Icon
        )
    );
    menu.addItem(
        new MenuItem(
            "Sync Nutrients", 
            "Mobile | Quick Info",
            "sync_preferences",                          // Event name for toggle changes
            {}
        )
    );

    // Create a new Menu2InputDelegate
    delegate = new SyncOptionsDelegate(menu, item, event_name); // a WatchUi.Menu2InputDelegate

    // Push the Menu2 View set up in the initializer
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
            {:enabled=>"On", :disabled=>"Off"}, // Sub-labels for states
            "log_notification",                          // Event name for toggle changes
            Application.getApp().getProperty("log_notification"),                           // Initial state (true/false)
            null                                // Optional Icon
        )
    );

    // Create a new Menu2InputDelegate
    delegate = new GenericOptionsDelegate(menu, item, event_name); // a WatchUi.Menu2InputDelegate

    // Push the Menu2 View set up in the initializer
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
            {:enabled=>"On", :disabled=>"Off"}, // Sub-labels for states
            "view_calories",                          // Event name for toggle changes
            Application.getApp().getProperty("view_calories"),                           // Initial state (true/false)
            null                                // Optional Icon
        )
    );
    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Nutrition", 
            {:enabled=>"On", :disabled=>"Off"}, // Sub-labels for states
            "view_nutrition",                          // Event name for toggle changes
            Application.getApp().getProperty("view_nutrition"),                           // Initial state (true/false)
            null                                // Optional Icon
        )
    );
    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Nutrition Pie", 
            {:enabled=>"On", :disabled=>"Off"}, // Sub-labels for states
            "view_nutrition_pie",                          // Event name for toggle changes
            Application.getApp().getProperty("view_nutrition_pie"),                           // Initial state (true/false)
            null                                // Optional Icon
        )
    );
    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Nutrition Trends", 
            {:enabled=>"On", :disabled=>"Off"}, // Sub-labels for states
            "view_nutrition_trends",                          // Event name for toggle changes
            Application.getApp().getProperty("view_nutrition_trends"),                           // Initial state (true/false)
            null                                // Optional Icon
        )
    );
    // menu.addItem(
    //     new WatchUi.ToggleMenuItem(
    //         "Custom Nutrition", 
    //         {:enabled=>"On", :disabled=>"Off"}, // Sub-labels for states
    //         "view_custom_nutrition",                          // Event name for toggle changes
    //         Application.getApp().getProperty("view_custom_nutrition"),                           // Initial state (true/false)
    //         null                                // Optional Icon
    //     )
    // );
    

    if (System.getDeviceSettings().isTouchScreen) {
        menu.addItem(
            new WatchUi.ToggleMenuItem(
                "Hidratation", 
                {:enabled=>"On", :disabled=>"Off"}, // Sub-labels for states
                "view_hydration",                          // Event name for toggle changes
                Application.getApp().getProperty("view_hydration"),                           // Initial state (true/false)
                null                                // Optional Icon
            )
        );
    }
    if (System.getDeviceSettings().isTouchScreen) {
        menu.addItem(
            new WatchUi.ToggleMenuItem(
                "Weight", 
                {:enabled=>"On", :disabled=>"Off"}, // Sub-labels for states
                "view_weight",                          // Event name for toggle changes
                Application.getApp().getProperty("view_weight"),                           // Initial state (true/false)
                null                                // Optional Icon
            )
        );
    }
    menu.addItem(
        new WatchUi.ToggleMenuItem(
            "Weight Trends", 
            {:enabled=>"On", :disabled=>"Off"}, // Sub-labels for states
            "view_weight_trends",                          // Event name for toggle changes
            Application.getApp().getProperty("view_weight_trends"),                           // Initial state (true/false)
            null                                // Optional Icon
        )
    );

    // Create a new Menu2InputDelegate
    delegate = new ViewOptionsDelegate(menu, item, event_name); // a WatchUi.Menu2InputDelegate

    // Push the Menu2 View set up in the initializer
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

    // Create a new Menu2InputDelegate
    delegate = new GlanceDataMenuDelegate(menu, item, event_name); // a WatchUi.Menu2InputDelegate

    // Push the Menu2 View set up in the initializer
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

    // Create a new Menu2InputDelegate
    delegate = new WaterContainersDelegate(menu, item, event_name); // a WatchUi.Menu2InputDelegate

    // Push the Menu2 View set up in the initializer
    WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
    return true;
}

// function getCustomNutrientsMenu(parent, event_name) {
//     var menu = new WatchUi.Menu2({:title=>"Select Nutrient"});
//     var delegate;
//     var item = parent;

//     var interestNutrients = Application.getApp().getSparkyConnector().getInterestNutrients();
//     var mandatoryNutrients = Application.getApp().getSparkyConnector().getMandatoryNutrients();

//     for (var i = 0; i < interestNutrients.size(); i++) {
//         var nutrient = interestNutrients[i];
//         if (mandatoryNutrients.indexOf(nutrient) == -1) { // Only add if not mandatory
//             menu.addItem(
//                 new WatchUi.ToggleMenuItem(
//                     nutrient,
//                     {:enabled=>"On", :disabled=>"Off"}, // Sub-labels for states
//                     nutrient,                          // Event name for toggle changes
//                     true,                           // Initial state (true/false)
//                     null                                // Optional Icon
//                 )
//             );
//         }
//     }

//     // Create a new Menu2InputDelegate
//     delegate = new CustomNutrientsDelegate(menu, item, event_name); // a WatchUi.Menu2InputDelegate

//     // Push the Menu2 View set up in the initializer
//     WatchUi.pushView(menu, delegate, WatchUi.SLIDE_IMMEDIATE);
//     return true;
// }