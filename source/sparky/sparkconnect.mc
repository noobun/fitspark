using Toybox.Application.Storage;
import Toybox.Application;
using Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Time.Gregorian;

(:glance)
class SparkConnect {
    private var requestManager;
    

    private var uuid;
    private var gender;
    private var weight = -1;
    private var weightHistory = {};

    private var interestNutrients = [];

    private var goals = {};
    private var nutrition_trends = {};
    private var waterContainers = [];
    private var primaryWaterContainerID = -1;
    private var waterConsumed = -1;
    
    private var onDataUpdatedCallback;

    private var _profileFetchPending = false;
    private var _pendingWeightHistoryDays = -1;
    private var _pendingHydration = false;
    private var _pendingNutriTrends = false;

    private var _weightHistoryAccumulator as Dictionary = {};
    private var _weightHistoryPending = 0;

    private var _weightHistoryGeneration = 0;
    private var _activeWeightHistoryGeneration = 0;

    function initialize() {
        requestManager = new RequestManager();
        if (isStorageEnabled()) {
            loadFromStorage();
        }

        if (uuid == null) {
            writeLog("SparkConnect:initialize", "No profile found in storage, fetching from API", 10);
            _profileFetchPending = true;
            fetchProfile();
            fetchPreferences();
        }
    }

    function setOnDataUpdatedCallback(callback) {
        onDataUpdatedCallback = callback;
    }

    private function isStorageEnabled() as Boolean {
        return Application.getApp().getProperty("persist_data") == true;
    }

    function getTodayStr() as String {
        return getDateXDaysAgo(0);
    }

    private function ensureProfileLoaded() as Void {
        if (uuid == null && !_profileFetchPending) {
            _profileFetchPending = true;
            fetchProfile();
        }
    }

    private function flushPendingFetches() as Void {
        if (_pendingWeightHistoryDays >= 0) {
            var deferredDays = _pendingWeightHistoryDays;
            _pendingWeightHistoryDays = -1;
            fetchWeightHistory(deferredDays);
        }
        if (_pendingHydration) {
            _pendingHydration = false;
            fetchHydration();
        }
        if (_pendingNutriTrends) {
            _pendingNutriTrends = false;
            fetchNutriTrends();
        }
    }

    function getGender() { return gender; }
    function getWeight() { return weight; }
    function getCaloriesConsumed() { return getMacroXDaysAgo("calories", 0); }
    function getProteinConsumed() { return getMacroXDaysAgo("protein", 0); }
    function getCarbsConsumed() { return getMacroXDaysAgo("carbs", 0); }
    function getFatsConsumed() { return getMacroXDaysAgo("fat", 0); }
    function getWaterConsumed() { return waterConsumed; }
    function getCaloriesGoal() { return goals.get("calories"); }
    function getProteinGoal() { return goals.get("protein"); }
    function getCarbsGoal() { return goals.get("carbs"); }
    function getFatsGoal() { return goals.get("fat"); }
    function getWaterGoal() { return goals.get("water_goal_ml"); }
    function getMacroGoal(macro) {
        var payload = {};
        for (var i=0; i<macro.size(); i++){
            payload[macro[i]] = getSafeValue(goals, macro[i], -1);
        }
        return payload;
    }
    function getMacroConsumed(date) { return nutrition_trends.get(goals); }
    function getGoals() { return goals; }

    function getInterestNutrients() { return interestNutrients; }
    function getInterestNutrientsCured() { 
        return filterInterestNutrients(interestNutrients); 
    } 
    
    private function filterInterestNutrients(nutrients) {
        var filtered = [];
        for (var i = 0; i < nutrients.size(); i++) {
            if (!nutrients[i].equals("calories")) {
                filtered.add(nutrients[i]);
            }
        }
        return filtered;
    }

    function getPrimaryWaterContainerID() { return primaryWaterContainerID; }

    function getMacroTrends(macro) { 
        var payload = [];
        var tmp = {};
        for(var i=0; i<nutrition_trends.size(); i++){
            tmp = nutrition_trends[i];
            if(tmp.hasKey(macro)){
                payload.add(tmp.get(macro));
            }
        }
        return payload;
    }

    function getMacrosXDaysAgo(day) {
        var searchedMoment = getDateXDaysAgo(day);
        if(nutrition_trends.size() > 0){ 
            for(var i=0; i<nutrition_trends.size(); i++){
                var payload = nutrition_trends[i];
                if(payload["date"].equals(searchedMoment)){
                    return payload;
                }
            }
        }
        return {};
    }

    function getMacroXDaysAgo(macro, day) {
        var macros = getMacrosXDaysAgo(day);
        if(macros.hasKey(macro)){
            return macros.get(macro).toNumber();
        }
        return 0;
    }

    function getMacroSetXDaysAgo(macros, day) {
        var payload = {};
        for(var i=0; i<macros.size(); i++){
            var macro = macros[i];
            payload[macro] = getMacroXDaysAgo(macro, day);
        }
        return payload;
    }

    function getMacroSetTrends(macros) {
        var payload = {};
        for(var i=0; i<macros.size(); i++){
            var macro = macros[i];
            payload[macro] = getMacroTrends(macro);
        }
        return payload;
    }

    function getWeightHistory() { return weightHistory; }
    function getWaterContainers() {return waterContainers; }

    function drink(container_id, change_drinks) {
        if (uuid == null) {
            writeLog("SparkConnect:drink", "Profile/uuid not ready; ignoring drink request", 100);
            return;
        }
        var data = {
            "change_drinks" => change_drinks,
            "container_id" => container_id,
            "entry_date" => getTodayStr(),
            "user_id" => uuid.toString()
        };
        writeLog("SparkConnect:drink", "Submitting hydration change: "+data.toString(), 100);
        requestManager.post("/api/measurements/water-intake", data, method(:onHydrationUpdated));
    }

    function submitWeight(weight) {
        var data = {
            "entry_date" => getTodayStr(),
            "weight" => weight
        };
        requestManager.post("/api/measurements/check-in", data, method(:onWeightFetched));
    }

    private function fetchProfile() {
        requestManager.get("/api/identity/profiles", {}, method(:onProfileFetched));
    }

    function fetchPreferences() {
        fetchInterestNutrients();
    }

    function fetchWeight() {
        requestManager.get("/api/measurements/most-recent/weight", {}, method(:onWeightFetched));
    }

    function fetchNutrition(date) {
        if (date == null){
            date = getTodayStr();
        }
        fetchNutritionGoalByDate(date);
        fetchNutriTrends();
    }

    function fetchWaterContainers() {
        requestManager.get("/api/water-containers", {}, method(:onWaterContainersFetched));
    }

    function fetchInterestNutrients() {
        requestManager.get("/api/preferences/nutrient-display", {}, method(:onInterestNutrientsFetched));
    }

    private function fetchNutritionGoalByDate(date) {
        requestManager.get("/api/goals/by-date/"+date, {}, method(:onNutritionGoalFetched));
    }

    function fetchNutriTrends() {
        if (uuid == null) {
            writeLog("SparkConnect:fetchNutriTrends", "Profile not loaded yet; deferring mini nutrition trends", 100);
            _pendingNutriTrends = true;
            ensureProfileLoaded();
            return;
        }
        var agoMoment = getDateXDaysAgo(4);
        var endpoint = "/api/reports/mini-nutrition-trends?userId=" + uuid + "&startDate=" + agoMoment + "&endDate=" + getTodayStr();
        requestManager.get(endpoint, {}, method(:onNutriTrendsFetched));
    }

    function fetchWeightHistory(days) {
        if (days == null || days <= 0) {
            return;
        }
        if (uuid == null) {
            writeLog("SparkConnect:fetchWeightHistory", "Profile not loaded yet; deferring weight history", 100);
            _pendingWeightHistoryDays = days;
            ensureProfileLoaded();
            return;
        }
        if (_weightHistoryPending > 0) {
            writeLog("SparkConnect:fetchWeightHistory", "Weight-history batch already in flight; skipping duplicate fetch", 50);
            return;
        }
        _weightHistoryGeneration += 1;
        _activeWeightHistoryGeneration = _weightHistoryGeneration;
        _weightHistoryAccumulator = {};
        _weightHistoryPending = days;
        for (var i = 0; i < days; i++) {
            requestManager.get(
                "/api/reports?userId=" + uuid + "&startDate=" + getDateXDaysAgo(i) + "&endDate=" + getDateXDaysAgo(i), 
                {}, 
                method(:onWeightHistoryFetched)
            );
        }
    }

    function fetchHydration() {
        if (uuid == null) {
            writeLog("SparkConnect:fetchHydration", "Profile not loaded yet; deferring hydration", 100);
            _pendingHydration = true;
            ensureProfileLoaded();
            return;
        }
        fetchNutritionGoalByDate(getTodayStr());
        requestManager.get("/api/measurements/water-intake/"+getTodayStr()+"?userId="+uuid, {}, method(:onHydrationFetched));
    }

    function onProfileFetched(result as Dictionary) as Void{
        _profileFetchPending = false;
        if (result[:success]) {
            var data = result[:data];
            if (data != null && data instanceof Dictionary) {
                uuid = data.get("id");
            }
            if (uuid != null) {
                flushPendingFetches();
            }
        }
        else{
            writeLog("SparkConnect:onProfileFetched", "Fetch Failed", 100);
        }
    }

    function onWeightFetched(result) {
        if (result[:success]) {
            var data = result[:data];
            weight = data.get(:weight);
            if (weight == null) {
                weight = data.get("weight");
            }
            notifyDataUpdated();
        }else{
            writeLog("SparkConnect:onWeightFetched", "Fetch Failed", 100);
        }
    }

    function onWeightHistoryFetched(result) {
        if (_weightHistoryGeneration != _activeWeightHistoryGeneration) {
            return;
        }
        if (result[:success]) {
            try {
                var data = result[:data];
                if (data != null && data instanceof Dictionary) {
                    var measurementData = data.get("measurementData");
                    if (measurementData != null && measurementData instanceof Array) {
                        for (var i = 0; i < measurementData.size(); i++) {
                            var entry = measurementData[i];
                            if (entry != null && entry instanceof Dictionary) {
                                var dateKey = entry.get("entry_date");
                                if (dateKey != null) {
                                    _weightHistoryAccumulator[dateKey] = entry.get("weight");
                                }
                            }
                        }
                    }
                }
            } catch (ex) {
                writeLog("SparkConnect:onWeightHistoryFetched", "Parse failed: " + ex.getErrorMessage(), 100);
            }
        }else{
            writeLog("SparkConnect:onWeightHistoryFetched", "Fetch Failed:"+result[:code].toString(), 100);
        }

        _weightHistoryPending -= 1;
        if (_weightHistoryPending <= 0) {
            _weightHistoryPending = 0;
            if (_weightHistoryAccumulator.size() > 0) {
                weightHistory = _weightHistoryAccumulator;
                if (isStorageEnabled()) {
                    Storage.setValue("weightHistory", weightHistory);
                }
            }
            _weightHistoryAccumulator = {};
            notifyDataUpdated();
        }
    }

    function onInterestNutrientsFetched(result) {
        if (result[:success]) {
            var data = result[:data];
            for (var i = 0; i < data.size(); i++) {
                var block = data[i];
                if (block["platform"].equals("mobile") && block["view_group"].equals("summary")) {
                    interestNutrients = block["visible_nutrients"];
                    break;
                }
            }
            notifyDataUpdated();
        }else{
            writeLog("SparkConnect:onInterestNutrientsFetched", "Fetch Failed:"+result[:code].toString(), 100);
        }

        if (isStorageEnabled()) {
            Storage.setValue("interestNutrients", interestNutrients);
        }
    }

    function onNutriTrendsFetched(result) {
        if (result[:success]) {
            var payload = result[:data];
            nutrition_trends = payload;
            notifyDataUpdated();
        }else{
            writeLog("SparkConnect:onNutriTrendsFetched", "Fetch Failed", 100);
        }
    }

    function onNutritionGoalFetched(result) {
        if (result[:success]) {
            var data = result[:data];
            goals = data;
            notifyDataUpdated();
        }else{
            writeLog("SparkConnect:onNutritionGoalFetched", "Fetch Failed", 100);
        }
    }

    function onHydrationFetched(result) {
        if (result[:success]) {
            var data = result[:data];
            waterConsumed = data.get("water_ml");
            notifyDataUpdated();
        }
    }

    function onHydrationUpdated(result) {
        if (result[:success]) {
            var data = result[:data];
            waterConsumed = data.get("water_ml");
            writeLog("SparkConnect:onHydrationUpdated", "Fetch Done:"+waterConsumed.toString(), 100);
            notifyDataUpdated();
        }else{
            if (WatchUi has :showToast) {
                WatchUi.showToast("Failed", {
                    :icon => WatchUi.loadResource(Rez.Drawables.warningToastIcon)
                });
            }
            writeLog("SparkConnect:onHydrationUpdated", "Fetch Failed", 100);
        }
    }

    function onWaterContainersFetched(result) {
        if (result[:success]) {
            waterContainers = [];
            var data = result[:data];
            for (var i = 0; i < data.size(); i++) {
                 waterContainers.add({
                    "name" => data[i]["name"],
                    "volume" => data[i]["volume"],
                    "id" => data[i]["id"],
                    "unit" => data[i]["unit"]
                });
                if (data[i]["is_primary"] == true){
                    primaryWaterContainerID = i;
                }
            }
            notifyDataUpdated();
        }else{
            writeLog("SparkConnect:onWaterContainersFetched", "Fetch Failed", 100);
        }
    }
    
    function saveToStorage() {
        if (!isStorageEnabled()) {
            return;
        }
        Storage.setValue("uuid", uuid);
        Storage.setValue("gender", gender);
        Storage.setValue("weight", weight);
        Storage.setValue("goals", goals);
        Storage.setValue("nutrition_trends", nutrition_trends);
        Storage.setValue("waterConsumed", waterConsumed);
        Storage.setValue("weightHistory", weightHistory);
        Storage.setValue("waterContainers", waterContainers);
        Storage.setValue("primaryWaterContainerID", primaryWaterContainerID);
    }

    private function loadFromStorage() {
        if(Storage.getValue("uuid") != null){
            uuid = Storage.getValue("uuid");
        }
        if(Storage.getValue("gender") != null){
            gender = Storage.getValue("gender");
        }
        if(Storage.getValue("weight") != null){
            weight = Storage.getValue("weight");
        }
        if(Storage.getValue("goals") != null){
            goals = Storage.getValue("goals");
        }
        if(Storage.getValue("nutrition_trends") != null){
            nutrition_trends = Storage.getValue("nutrition_trends");
        }
        if(Storage.getValue("waterConsumed") != null){
            waterConsumed = Storage.getValue("waterConsumed");
        }
        if(Storage.getValue("weightHistory") != null){
            weightHistory = Storage.getValue("weightHistory");
        }
        if(Storage.getValue("waterContainers") != null){
            waterContainers = Storage.getValue("waterContainers");
        }
        if(Storage.getValue("primaryWaterContainerID") != null){
            primaryWaterContainerID = Storage.getValue("primaryWaterContainerID");
        }
        if(Storage.getValue("interestNutrients") != null){
            interestNutrients = Storage.getValue("interestNutrients");
        }
    }

    private function notifyDataUpdated() {
        if (onDataUpdatedCallback != null) {
            onDataUpdatedCallback.invoke();
        }
    }
}