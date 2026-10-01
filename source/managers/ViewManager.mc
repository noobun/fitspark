import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Communications;
import Toybox.Graphics;

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
                {"view" => new nutriView(self, sparkyconnector, indexview, macro_indexview)}
            );
            viewStack[indexview][macro_indexview]["del"] = new nutriDelegate(self, sparkyconnector, indexview, macro_indexview);
            macro_indexview += 1;
        }
        if (Application.getApp().getProperty("view_nutrition_trends")){
            if (sections["nutrition"] == false) {
                indexview++;
                viewStack.add([]);
                sections["nutrition"] = true;
            }
            viewStack[indexview].add(
                {"view" => new nutritrendsView(self, sparkyconnector, indexview, macro_indexview)}
            );
            viewStack[indexview][macro_indexview]["del"] = new nutritrendsDelegate(self, sparkyconnector, indexview, macro_indexview);
            macro_indexview += 1;
        }
        if (Application.getApp().getProperty("view_custom_nutrition") && Capabilities.HAS_TOUCH_HARDWARE){
            if (sections["nutrition"] == false) {
                indexview++;
                viewStack.add([]);
                sections["nutrition"] = true;
            }
            viewStack[indexview].add(
                {"view" => new customNutriView(self, sparkyconnector, indexview, macro_indexview)}
            );
            viewStack[indexview][macro_indexview]["del"] = new customNutriDelegate(self, sparkyconnector, indexview, macro_indexview);
            macro_indexview += 1;
        }
        if (Application.getApp().getProperty("view_calories_breakdown")){
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
        
        
        if (Application.getApp().getProperty("view_hydration") && Capabilities.HAS_TOUCH_HARDWARE) {
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
        
        if (Application.getApp().getProperty("view_weight") && Capabilities.HAS_TOUCH_HARDWARE) {
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

        if (viewStack.size() == 0) {
            writeLog("ViewManager:configureViews", "No views enabled - adding fallback page", 100);
            viewStack.add([]);
            viewStack[0].add({"view" => new fallbackView()});
            viewStack[0][0]["del"] = new fallbackDelegate();
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

    function movePage(direction as Number) as Boolean{

        if(viewStack.size() == 0){
            currentSubLevel = 0;
            currentLevel = 0;
            return false;
        }

        currentSubLevel = 0;
        var previousLevel = currentLevel;
        currentLevel = currentLevel+direction;
        if(currentLevel<0){
            currentLevel=viewStack.size()-1;
        }

        if(currentLevel > viewStack.size()-1){
            currentLevel = 0;
        }
        return currentLevel != previousLevel;
    }

    function moveSubPage(direction as Number) as Boolean{

        if((viewStack[currentLevel].size()-1)==0){
            return false;
        }else{
            currentSubLevel = currentSubLevel+direction;
            if(currentSubLevel<0){
                currentSubLevel=viewStack[currentLevel].size()-1;
            }

            if(currentSubLevel > viewStack[currentLevel].size()-1){
                currentSubLevel = 0;
            }
            return true;
        }
    }

}

class fallbackView extends WatchUi.View {
    private var _noViewsText;
    private var _noViewsHint;

    function initialize() {
        View.initialize();
        _noViewsText = WatchUi.loadResource(Rez.Strings.NoViewsEnabled);
        _noViewsHint = WatchUi.loadResource(Rez.Strings.NoViewsHint);
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - 20, Graphics.FONT_MEDIUM, _noViewsText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 + 10, Graphics.FONT_SMALL, _noViewsHint, Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class fallbackDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        getMainMenu();
        return true;
    }
}
