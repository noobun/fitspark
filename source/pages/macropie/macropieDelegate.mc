import Toybox.Lang;
import Toybox.WatchUi;
using WatchUi as Ui;
import Toybox.Application;
import Toybox.System;
import Toybox.Communications;
using Toybox.Graphics;
import Toybox.Attention;
using Toybox.Timer;

class macroPieDelegate extends WatchUi.BehaviorDelegate {

    private var _view as macroPieView;
    private var _manager;
    private var _sparkyconnector;

    function initialize(manager, sparkyconnector, view_nr, subview_nr) {
        writeLog("MacroPieDelegate:init", "DONE",10);
        BehaviorDelegate.initialize();
        _manager = manager;
        _sparkyconnector = sparkyconnector;
        _view = manager.getViewByIndex(view_nr, subview_nr);
        // _view.setFocus(selection_keys[selected]);
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