using Toybox.WatchUi;
using Toybox.Graphics as Graphics;
using Toybox.System as System;

class RoundTextView extends WatchUi.WatchFace {

    var font;
    var hand;
    var bezeltext;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        font = new Font();
        hand = new Hand();
        bezeltext = new BezelText();
    }

    var i=0;
    function onUpdate(screen) {

        // clear the screen
        screen.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
        screen.clear();
        screen.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
   
        // draw the text round the screen
        bezeltext.draw(screen,"THIS IS SOME TEXT "+i,i % 2 ? 100 : 280,font);

        // draw a hand
        var time = System.getClockTime();
        hand.draw(screen,time.sec,font);

        i++;
    }

    function onHide() {
    }

    function onExitSleep() {
    }

    function onEnterSleep() {
    }
}
