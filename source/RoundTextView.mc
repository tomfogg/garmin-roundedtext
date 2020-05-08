using Toybox.WatchUi;
using Toybox.Graphics as Graphics;
using Toybox.System as System;

class RoundTextView extends WatchUi.WatchFace {

    // for caching the font and hand resources
    var fontcache=new[31];
    var handcache=new[31];
    var fontLRU=[];

    var r;
    var width;
    var height;
    var fontlookup;
    var fontheight;
    var handlookups;
    var handheight;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
       
        // graphics setup
        width = dc.getWidth();
        height = dc.getHeight();
        r = width/2;
       
        // 15 is when the font is without rotation
        fontheight=Graphics.getFontHeight(getFont(15))/2.0;
        // calculate the x,y and font index for each 60 positions around the face
        fontlookup = generateLookup(r-fontheight);

        // 15 is when the font is at 12 o' clock
        handheight=Graphics.getFontHeight(getHand(15));
        // calculate the offset that means the hands stack together properly
        var offset = (Math.sqrt(Math.pow(handheight,2)+Math.pow(handheight,2))-handheight)/2;
        // work out how many hands stacked together will fit in this screen
        var handlengths = (r-handheight/2)/(handheight-offset);
        // calculate the x,y and font index for each 60 positions around the face
        // times the number of stacked hands needed to fill the screen to the edge
        handlookups = new[handlengths];
        for(var i=0;i<handlookups.size();i++) {
            handlookups[i] = generateLookup((handheight-offset)*(i+1));
        }
    }

    // load a hand and cache it
    function getHand(f) {
        var hand = handcache[f];
        if(hand == null) {
            if(f==0) { hand = loadResource(Rez.Fonts.hand_0); }
            else if(f==1) { hand = loadResource(Rez.Fonts.hand_6); }
            else if(f==2) { hand = loadResource(Rez.Fonts.hand_12); }
            else if(f==3) { hand = loadResource(Rez.Fonts.hand_18); }
            else if(f==4) { hand = loadResource(Rez.Fonts.hand_24); }
            else if(f==5) { hand = loadResource(Rez.Fonts.hand_30); }
            else if(f==6) { hand = loadResource(Rez.Fonts.hand_36); }
            else if(f==7) { hand = loadResource(Rez.Fonts.hand_42); }
            else if(f==8) { hand = loadResource(Rez.Fonts.hand_48); }
            else if(f==9) { hand = loadResource(Rez.Fonts.hand_54); }
            else if(f==10) { hand = loadResource(Rez.Fonts.hand_60); }
            else if(f==11) { hand = loadResource(Rez.Fonts.hand_66); }
            else if(f==12) { hand = loadResource(Rez.Fonts.hand_72); }
            else if(f==13) { hand = loadResource(Rez.Fonts.hand_78); }
            else if(f==14) { hand = loadResource(Rez.Fonts.hand_84); }
            else if(f==15) { hand = loadResource(Rez.Fonts.hand_90); }
            else if(f==16) { hand = loadResource(Rez.Fonts.hand_96); }
            else if(f==17) { hand = loadResource(Rez.Fonts.hand_102); }
            else if(f==18) { hand = loadResource(Rez.Fonts.hand_108); }
            else if(f==19) { hand = loadResource(Rez.Fonts.hand_114); }
            else if(f==20) { hand = loadResource(Rez.Fonts.hand_120); }
            else if(f==21) { hand = loadResource(Rez.Fonts.hand_126); }
            else if(f==22) { hand = loadResource(Rez.Fonts.hand_132); }
            else if(f==23) { hand = loadResource(Rez.Fonts.hand_138); }
            else if(f==24) { hand = loadResource(Rez.Fonts.hand_144); }
            else if(f==25) { hand = loadResource(Rez.Fonts.hand_150); }
            else if(f==26) { hand = loadResource(Rez.Fonts.hand_156); }
            else if(f==27) { hand = loadResource(Rez.Fonts.hand_162); }
            else if(f==28) { hand = loadResource(Rez.Fonts.hand_168); }
            else if(f==29) { hand = loadResource(Rez.Fonts.hand_174); }
            else if(f==30) { hand = loadResource(Rez.Fonts.hand_180); }
            handcache[f] = hand;
        }

        return hand;
    }

    // load a font and cache it, use a LRU to free old fonts if memory low
    function getFont(f) {
        var font = fontcache[f];
        if(font == null) {
            if(f==-1) { font = null; }
            else if(f==0) { font = loadResource(Rez.Fonts.font_0); }
            else if(f==1) { font = loadResource(Rez.Fonts.font_6); }
            else if(f==2) { font = loadResource(Rez.Fonts.font_12); }
            else if(f==3) { font = loadResource(Rez.Fonts.font_18); }
            else if(f==4) { font = loadResource(Rez.Fonts.font_24); }
            else if(f==5) { font = loadResource(Rez.Fonts.font_30); }
            else if(f==6) { font = loadResource(Rez.Fonts.font_36); }
            else if(f==7) { font = loadResource(Rez.Fonts.font_42); }
            else if(f==8) { font = loadResource(Rez.Fonts.font_48); }
            else if(f==9) { font = loadResource(Rez.Fonts.font_54); }
            else if(f==10) { font = loadResource(Rez.Fonts.font_60); }
            else if(f==11) { font = loadResource(Rez.Fonts.font_66); }
            else if(f==12) { font = loadResource(Rez.Fonts.font_72); }
            else if(f==13) { font = loadResource(Rez.Fonts.font_78); }
            else if(f==14) { font = loadResource(Rez.Fonts.font_84); }
            else if(f==15) { font = loadResource(Rez.Fonts.font_90); }
            else if(f==16) { font = loadResource(Rez.Fonts.font_96); }
            else if(f==17) { font = loadResource(Rez.Fonts.font_102); }
            else if(f==18) { font = loadResource(Rez.Fonts.font_108); }
            else if(f==19) { font = loadResource(Rez.Fonts.font_114); }
            else if(f==20) { font = loadResource(Rez.Fonts.font_120); }
            else if(f==21) { font = loadResource(Rez.Fonts.font_126); }
            else if(f==22) { font = loadResource(Rez.Fonts.font_132); }
            else if(f==23) { font = loadResource(Rez.Fonts.font_138); }
            else if(f==24) { font = loadResource(Rez.Fonts.font_144); }
            else if(f==25) { font = loadResource(Rez.Fonts.font_150); }
            else if(f==26) { font = loadResource(Rez.Fonts.font_156); }
            else if(f==27) { font = loadResource(Rez.Fonts.font_162); }
            else if(f==28) { font = loadResource(Rez.Fonts.font_168); }
            else if(f==29) { font = loadResource(Rez.Fonts.font_174); }
            else if(f==30) { font = loadResource(Rez.Fonts.font_180); }
            fontcache[f] = font;
        
            // if we have low memory, evict the least used font from the cache
            var stats = System.getSystemStats();
            if(stats.freeMemory < 20000) {
                if(fontLRU.size() > 0) {
                    var oldfont = fontLRU[0];
                    fontcache[oldfont] = null;
                    fontLRU.remove(oldfont);
                }
            }
        }
           
        // update the LRU
        fontLRU.remove(f);
        fontLRU.add(f);

        return(font);
    }

    // pre-calculate coordinates for rotating
    function generateLookup(h) {
        var al = new[60];

        // sin and cos of 6 degrees (angle for each minute)
        var sin = 0.10452846326;
        var cos = 0.99452189536;

        var y = -h;
        var x = 0.0;

        var c=15;
        var rr=r;
        for(var i=0;i<60;i++) {
            // lookup for the font drawing
            var ox = rr+x.toNumber();
            var oy = rr+y.toNumber();
            ox = ox > 0 ? ox : 0;
            oy = oy > 0 ? oy : 0;
            // pack the data so we can have x,y fontindex all in 32 bits
            // 9 bits is enough for 512 which is more resolution than current
            // watches have
            al[i] = (c & 0xff) << 24 | (ox & 0x1ff) << 9 | oy & 0x1ff;
            if(i==15 || i == 45) { c = 0; }
            c++;

            // apply a 6 degree rotation transformation
            var oldx = x;
            var oldy = y;
            x = oldx*cos - oldy*sin;
            y = oldx*sin + oldy*cos;
        }
        return al;
    }

    // draw a hand
    // the hand is made up of a few font characters stacked on top of each 
    // other to reduce memory usage 
    function drawHand(dc,val) {
        var l = handlookups.size()-1;
        for(var i=l; i >= 0; i--) {
            // look up the x,y position and font to use for this angle
            var lookup = handlookups[i];
            var v = lookup[val];
            var fontindex = (v & 0xff000000) >> 24;
            var x = (v & 0x3fe00) >> 9;
            var y = v & 0x1ff;
            
            var font = getHand(fontindex);
            // use the ( character for an arrow pointing up
            // a ) for the arrow pointing down 
            // and a * for a straight bar 
            var letter = i==l ? val > 45 || val <= 15 ? '(' : ')' : '*';
            dc.drawText(x,y-handheight/2,font,letter,Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // draw the curved text around the watch face
    function drawBezelText(dc,text) {
        for(var a=0; a < text.size(); a++) {
            // get a character from the string
            var t = text[a];
            // draw the data text
            if(t != ' ') {
                // get the lookup for this angle
                var val = fontlookup[a];
                // unpack the data from the lookup
                var fontindex = (val & 0xff000000) >> 24;
                var x = (val & 0x3fe00) >> 9;
                var y = val & 0x1ff;
                // get the font resource with the letter rotated at angle a
                var font = getFont(fontindex);
                // draw the letter at the right position
                dc.drawText(x,y-fontheight,font,t,Graphics.TEXT_JUSTIFY_CENTER);
            }
        }
    }

    var i=0;
    var i2=100;
    function onUpdate(screen) {

        // clear the screen
        screen.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
        screen.clear();
        screen.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
   
        // draw the text round the screen
        var text = ("COUNTING UP "+i).toCharArray();
        // the bottom half has to be reversed since its drawn 'upside down'
        text.addAll(("COUNTING DOWN "+i2+"         ").toCharArray().reverse());
        drawBezelText(screen,text);

        // draw a hand
        var time = System.getClockTime();
        drawHand(screen,time.sec);

        i++;
        i2--;
    }

    function onHide() {
    }

    function onExitSleep() {
    }

    function onEnterSleep() {
    }
}
