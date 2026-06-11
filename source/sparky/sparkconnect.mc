using Toybox.Application.Storage;
import Toybox.Application;
using Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Time.Gregorian;

(:glance)
class SparkConnect {
    private var requestManager;
    
    // Data fields

    // private var name;
    private var uuid;
    // private var date_of_birth;
    private var gender;
    // private var height;
    private var weight = -1;
    private var weightHistory = {};

    private var interestNutrients = [];

    private var goals = {};
    private var nutrition_trends = {};
    private var waterContainers = [];
    private var primaryWaterContainerID = -1;
    private var waterConsumed = -1;
    
    private var today;
    
    // Callbacks for sync triggers
    private var onDataUpdatedCallback;

    function initialize() {
        requestManager = new RequestManager();
        loadFromStorage();
        today = getDateXDaysAgo(0);

        if (uuid == null) {
            writeLog("SparkConnect:initialize", "No profile found in storage, fetching from API", 10);
            fetchProfile();
            fetchPreferences();
        }
    }

    // Set callback for data updates
    function setOnDataUpdatedCallback(callback) {
        onDataUpdatedCallback = callback;
    }

    // Getters
    // function getName() { return name; }
    // function getBirthday() { return date_of_birth; }
    function getGender() { return gender; }
    // function getHeight() { return height; }
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
        var data = {
            "change_drinks" => change_drinks,
            "container_id" => container_id,
            "entry_date" => today.toString(),
            "user_id" => uuid.toString()
        };
        writeLog("SparkConnect:drink", "Submitting hydration change: "+data.toString(), 100);
        requestManager.post("/api/measurements/water-intake", data, method(:onHydrationUpdated));
    }

    function submitWeight(weight) {
        var data = {
            "entry_date" => today.toString(),
            "weight" => weight
        };
        requestManager.post("/api/measurements/check-in", data, method(:onWeightFetched));
    }

    // API methods
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
            date = today;
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
        if(uuid == null){
            fetchProfile(); // Ensure we have the UUID before fetching trends
        }
        var agoMoment = getDateXDaysAgo(4);
        var endpoint = "/api/reports/mini-nutrition-trends?userId=" + uuid + "&startDate=" + agoMoment + "&endDate=" + today;
        requestManager.get(endpoint, {}, method(:onNutriTrendsFetched));
    }

    function fetchWeightHistory(days) {
        if(uuid == null){
            fetchProfile(); // Ensure we have the UUID before fetching trends
        }
        weightHistory = {}; // Reset history
        for (var i = 0; i < days; i++) {
            requestManager.get(
                "/api/reports?userId=" + uuid + "&startDate=" + getDateXDaysAgo(i) + "&endDate=" + getDateXDaysAgo(i), 
                {}, 
                method(:onWeightHistoryFetched)
            );
        }
    }

    function fetchHydration() {
        if(uuid == null){
            fetchProfile(); // Ensure we have the UUID before fetching trends
        }
        fetchNutritionGoalByDate(today);
        requestManager.get("/api/measurements/water-intake/"+today+"?userId="+uuid, {}, method(:onHydrationFetched));
    }

    // Response handlers
    function onProfileFetched(result as Dictionary) as Void{
        if (result[:success]) {
            var data = result[:data];
            // name = data.get("full_name");
            // date_of_birth = data.get("date_of_birth");
            uuid = data.get("id");
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
        if (result[:success]) {
            var data = result[:data];
            data = data.get("measurementData");
            for (var i = 0; i < data.size(); i++) {
                var entry = data[i];
                // Store or process the trend data as needed
                weightHistory[entry.get("entry_date")] = entry.get("weight");
            }
            if (weightHistory.size() == 7){
                notifyDataUpdated();
            }
        }else{
            writeLog("SparkConnect:onWeightHistoryFetched", "Fetch Failed:"+result[:code].toString(), 100);
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

        Storage.setValue("interestNutrients", interestNutrients);
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
                    :icon => WatchUi.loadResource(Rez.Drawables.warningToastIcon) // Your custom "i" icon
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
    
    // Storage methods
    function saveToStorage() {
        // Storage.setValue("name", name);
        Storage.setValue("uuid", uuid);
        // Storage.setValue("date_of_birth", date_of_birth);
        Storage.setValue("gender", gender);
        // Storage.setValue("height", height);
        Storage.setValue("weight", weight);
        Storage.setValue("goals", goals);
        Storage.setValue("nutrition_trends", nutrition_trends);
        Storage.setValue("waterConsumed", waterConsumed);
        Storage.setValue("weightHistory", weightHistory);
        Storage.setValue("waterContainers", waterContainers);
    }

    private function loadFromStorage() {
        // if(Storage.getValue("name") != null){ // Clear storage for testing purposes
        //     name = Storage.getValue("name");
        // }
        if(Storage.getValue("uuid") != null){ // Clear storage for testing purposes
            uuid = Storage.getValue("uuid");
        }
        // if(Storage.getValue("date_of_birth") != null){ // Clear storage for testing purposes
        //     date_of_birth = Storage.getValue("date_of_birth");
        // }
        if(Storage.getValue("gender") != null){ // Clear storage for testing purposes
            gender = Storage.getValue("gender");
        }
        // if(Storage.getValue("height") != null){ // Clear storage for testing purposes
        //     height = Storage.getValue("height");
        // }
        if(Storage.getValue("weight") != null){ // Clear storage for testing purposes
            weight = Storage.getValue("weight");
        }
        if(Storage.getValue("goals") != null){ // Clear storage for testing purposes
            goals = Storage.getValue("goals");
        }
        if(Storage.getValue("nutrition_trends") != null){ // Clear storage for testing purposes
            nutrition_trends = Storage.getValue("nutrition_trends");
        }
        if(Storage.getValue("waterConsumed") != null){ // Clear storage for testing purposes
            waterConsumed = Storage.getValue("waterConsumed");
        }
        if(Storage.getValue("weightHistory") != null){ // Clear storage for testing purposes
            weightHistory = Storage.getValue("weightHistory");
        }
        if(Storage.getValue("waterContainers") != null){ // Clear storage for testing purposes
            waterContainers = Storage.getValue("waterContainers");
        }
        if(Storage.getValue("interestNutrients") != null){ // Clear storage for testing purposes
            interestNutrients = Storage.getValue("interestNutrients");
        }
    }

    private function notifyDataUpdated() {
        onDataUpdatedCallback.invoke();
    }
}