import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Communications;

class ViewManager {

    private var viewStack as Array = [];

    private var currentLevel = 0;
    private var currentSubLevel = 0;

    var requester;
    var sparkyconnector;

    function initialize(sparkyconnectorapi) {
        writeLog("ViewManager:initialize", "View Manager Init", 10);
        sparkyconnector = sparkyconnectorapi;
        configureViews();
    }

    function configureViews(){
        var indexview = -1;
        var weight_indexview = 0;
        var macro_indexview = 0;

        var sections = {
            "calories" => false,
            "nutrition" => false,
            "hydration" => false,
            "weight" => false,
        };

        viewStack = [];

        if (Application.getApp().getProperty("view_calories")) {
            if (sections["calories"] == false) {
                indexview++;
                viewStack.add([]);
                sections["calories"] = true;
            }
            viewStack[indexview].add(
                {"view" => new overviewView(self, sparkyconnector, 0, 0)}
            );
            viewStack[indexview][0]["del"] = new overviewDelegate(self, sparkyconnector, 0, 0);
        }
        if (Application.getApp().getProperty("view_nutrition")) {
            if (sections["nutrition"] == false) {
                indexview++;
                viewStack.add([]);
                sections["nutrition"] = true;
            }
            viewStack[indexview].add(
                {"view" => new macroView(self, sparkyconnector, indexview, macro_indexview)}
            );
            viewStack[indexview][macro_indexview]["del"] = new macroDelegate(self, sparkyconnector, indexview, macro_indexview);
            macro_indexview += 1;
        }
        if (Application.getApp().getProperty("view_nutrition_pie")){
            if (sections["nutrition"] == false) {
                indexview++;
                viewStack.add([]);
                sections["nutrition"] = true;
            }
            viewStack[indexview].add(
                {"view" => new macroPieView(self, sparkyconnector, indexview, macro_indexview)}
            );
            viewStack[indexview][macro_indexview]["del"] = new macroPieDelegate(self, sparkyconnector, indexview, macro_indexview);
            macro_indexview += 1;
        }
        if (Application.getApp().getProperty("view_nutrition_trends")){
            if (sections["nutrition"] == false) {
                indexview++;
                viewStack.add([]);
                sections["nutrition"] = true;
            }
            viewStack[indexview].add(
                {"view" => new macrotrendsView(self, sparkyconnector, indexview, macro_indexview)}
            );
            viewStack[indexview][macro_indexview]["del"] = new macrotrendsDelegate(self, sparkyconnector, indexview, macro_indexview);
            macro_indexview += 1;
        }
        if (Application.getApp().getProperty("view_custom_nutrition") && System.getDeviceSettings().isTouchScreen){
            if (sections["nutrition"] == false) {
                indexview++;
                viewStack.add([]);
                sections["nutrition"] = true;
            }
            viewStack[indexview].add(
                {"view" => new custommacrotrendsView(self, sparkyconnector, indexview, macro_indexview)}
            );
            viewStack[indexview][macro_indexview]["del"] = new custommacrotrendsDelegate(self, sparkyconnector, indexview, macro_indexview);
            macro_indexview += 1;
        }
        
        
        if (Application.getApp().getProperty("view_hydration") && System.getDeviceSettings().isTouchScreen) {
            if (sections["hydration"] == false) {
                indexview++;
                viewStack.add([]);
                sections["hydration"] = true;
            }
            viewStack[indexview].add(
                {"view" => new waterView(self, sparkyconnector, indexview, 0)}
            );
            viewStack[indexview][0]["del"] = new waterDelegate(self, sparkyconnector, indexview, 0);
        }
        
        if (Application.getApp().getProperty("view_weight") && System.getDeviceSettings().isTouchScreen) {
            if (sections["weight"] == false) {
                indexview++;
                viewStack.add([]);
                sections["weight"] = true;
            }
            viewStack[indexview].add(
                {"view" => new weightView(self, sparkyconnector, indexview, weight_indexview)}
            );
            viewStack[indexview][weight_indexview]["del"] = new weightDelegate(self, sparkyconnector, indexview, weight_indexview);
            weight_indexview += 1;
        }
        if (Application.getApp().getProperty("view_weight_trends")) {
            if (sections["weight"] == false) {
                indexview++;
                viewStack.add([]);
                sections["weight"] = true;
            }
            viewStack[indexview].add(
                {"view" => new weightTrendsView(self, sparkyconnector, indexview, weight_indexview)}
            );
            viewStack[indexview][weight_indexview]["del"] = new weightTrendsDelegate(self, sparkyconnector, indexview, weight_indexview);
            weight_indexview += 1;
        }
    }

    function getViewNumber(){
        return viewStack.size();
    }

    function removeCurrentView(){
        viewStack.remove(viewStack[currentLevel]);
        self.movePage(-1);
    }

    function getCurrentPage() as Array{
        return [viewStack[currentLevel][currentSubLevel]["view"], viewStack[currentLevel][currentSubLevel]["del"]];
    }

    function getCurrentView() as WatchUi.View{
        return viewStack[currentLevel][currentSubLevel]["view"];
    }

    function getCurrentDelegate() as WatchUi.BehaviorDelegate{
        return viewStack[currentLevel][currentSubLevel]["del"];
    }

    function getViewByIndex(level, subLevel) as WatchUi.View{
        return viewStack[level][subLevel]["view"];
    }

    function getDelegateByIndex(level, subLevel) as WatchUi.BehaviorDelegate{
        return viewStack[level][subLevel]["del"];
    }

    function getViewIndex() as Number{
        return currentLevel;
    }

    function getSubViewIndex() as Number{
        return currentSubLevel;
    }

    function setView(level as Number, sublevel as Number) as Void{
        currentLevel = level;
        currentSubLevel = sublevel;
    }

    function hasSubView(){
        if(viewStack[currentLevel].size() > 1 ){
            return true;
        }else{
            return false;
        }
    }

    function movePage(direction as Number) as Void{
        // 1  -> Next Page
        // -1 -> Back Page

        currentSubLevel = 0;
        currentLevel = currentLevel+direction;
        if(currentLevel<0){
            currentLevel=viewStack.size()-1;
        }

        if(currentLevel > viewStack.size()-1){
            currentLevel = 0;
        }
        // writeLog("ViewManager", "Page: "+currentLevel.toString(), 100);
    }

    function moveSubPage(direction as Number) as Boolean{
        // 1  -> Next Page
        // -1 -> Back Page

        if((viewStack[currentLevel].size()-1)==0){
            // writeLog("ViewManager", "No Sublevels", 100);
            return false;
        }else{
            currentSubLevel = currentSubLevel+direction;
            if(currentSubLevel<0){
                currentSubLevel=viewStack[currentLevel].size()-1;
            }

            if(currentSubLevel > viewStack[currentLevel].size()-1){
                currentSubLevel = 0;
            }
            // writeLog("ViewManager", "SubPage: "+currentSubLevel.toString(), 100);
            return true;
        }
    }

}