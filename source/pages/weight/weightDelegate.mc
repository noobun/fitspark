import Toybox.Lang;
import Toybox.WatchUi;
using WatchUi as Ui;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;
using Toybox.Graphics;
import Toybox.Attention;
using Toybox.Timer;

class weightDelegate extends WatchUi.BehaviorDelegate {

    private var _view as weightView;
    private var _manager;
    private var _sparkyconnector;

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        writeLog("weightDelegate:init", "DONE",10);
        BehaviorDelegate.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector;
        _view = manager.getViewByIndex(view_nr, subview_nr);
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        eventHandling(keyEvent.getKey());
        return true;
    }

    function onSwipe(swipeEvent) {
        eventHandling(swipeEvent.getDirection());
        return true;
    }

    function onMenu() as Boolean {
        getMainMenu();
        return true;
    }

    function eventHandling(code){
        moveAround(code, _manager);
    }

    function onPlusPressed() {
        var weightActual = _view.getWeight();
        writeLog("weightDelegate:onPlusPressed", "Current weight: " + weightActual, 10);
        weightActual += 0.1;
        _view.receiveWeightData(weightActual);
        return true;
    }

    function onMinusPressed() {
        var weightActual = _view.getWeight();
        writeLog("weightDelegate:onMinusPressed", "Current weight: " + weightActual, 10);
        weightActual -= 0.1;
        _view.receiveWeightData(weightActual);
        return true;
    }

    function onSubmitPressed() {
        var weight = _view.getWeight();
        if (weight == null || weight <= 0) {
            writeLog("weightDelegate:onSubmitPressed", "Not submitting invalid weight: " + weight, 100);
            return true;
        }
        writeLog("weightDelegate:onSubmitPressed", "Submitting weight: " + weight, 10);
        _sparkyconnector.submitWeight(weight);
        WatchUi.showToast("Logged", {
                    :icon => WatchUi.loadResource(Rez.Drawables.positiveCheckToastIcon)
        });
        vibrateAttention();
        return true;
    }

    function moveAround(code, _manager) as Void {
        navi(code, _manager);
    }
}