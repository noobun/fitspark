import Toybox.WatchUi;

function navi(code, _manager) as Void {
    if(code==4 || code==3){ // Forward
        if(_manager.moveSubPage(1)){
            var page = _manager.getCurrentPage();
            WatchUi.switchToView(page[0], page[1], WatchUi.SLIDE_LEFT);
        }
    }
    if(code==5 || code==1){ // Back
        var currentSubLevel = _manager.getSubViewIndex();
        var currentLevel = _manager.getViewIndex();
        if(currentSubLevel==0){
            if(currentLevel==0){
                WatchUi.popView(WatchUi.SLIDE_LEFT);
            }else{
                _manager.setView(0, 0);
                var page = _manager.getCurrentPage();
                WatchUi.switchToView(page[0], page[1], WatchUi.SLIDE_UP);
            }
        }else{
            if(_manager.moveSubPage(-1)){
                var page = _manager.getCurrentPage();
                WatchUi.switchToView(page[0], page[1], WatchUi.SLIDE_RIGHT);
            }
        }
    }
    if(code==8 || code==0){ // Down
        _manager.movePage(1);
        var page = _manager.getCurrentPage();
        WatchUi.switchToView(page[0], page[1], WatchUi.SLIDE_UP);
            
    }
    if(code==13 || code==2){ // Up
        _manager.movePage(-1);
        var page = _manager.getCurrentPage();
        WatchUi.switchToView(page[0], page[1], WatchUi.SLIDE_DOWN);    
    } 
}