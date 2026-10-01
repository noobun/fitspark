import Toybox.Lang;
import Toybox.WatchUi;
using WatchUi as Ui;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;
using Toybox.Graphics;
import Toybox.Attention;
using Toybox.Timer;

class nutritrendsDelegate extends WatchUi.BehaviorDelegate {

    private var _manager;
    private var _sparkyconnector;

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        writeLog("nutritrendsDelegate:init", "DONE",10);
        BehaviorDelegate.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector;
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

    function moveAround(code, _manager) as Void {
        navi(code, _manager);
    }
}