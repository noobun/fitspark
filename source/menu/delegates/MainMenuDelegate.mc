import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;
using Toybox.Graphics;
using Toybox.Attention;
import Toybox.System;

class MainMenuInputDelegate extends WatchUi.Menu2InputDelegate {

    var menu;

    function initialize(menu_par) {
        Menu2InputDelegate.initialize();
        menu = menu_par;
    }

    function onSelect(item) {
        if("glancedata".equals(item.getId())){
            getGlanceDataMenu(item, "glancedata");
        }else if("sync_settings".equals(item.getId())){
            getSyncOptions(item, "sync_settings");
        }else if("view_settings".equals(item.getId())){
            getViewOptions(item, "view_settings");
        }else if("generic_options".equals(item.getId())){
            getGenericOptions(item, "generic_options");
        }else if("water_containers".equals(item.getId())){
            getWaterContainersMenu(item, "water_containers");
        }else{
            writeLog("MainMenuInputDelegate", "unknow option selected", 100);
        }
    }
}