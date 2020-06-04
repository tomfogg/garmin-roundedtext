class BezelText {
    
    function initialize() {
    }

    function draw(dc,text,angle,font) {
       
        // get the lookup table and height of the font
        var textlookup = font.fontlookups[0];
        var fh = font.fontheight/2;

        // if we're beyond a certain angle we need to
        // draw the text in reverse
        var reverse = angle > 90 && angle < 270;
        var t = reverse ? text.length()-1 : 0;
       
        // start at this angle and go clockwise
        // until the text runs out
        var a = angle;
        while(text != null && t >= 0 && t < text.length()) {
            // get a character from the text
            var char = text.substring(t,t+1);
            // get the width in degrees of the character
            var w = font.letterwidths.get(char);

            // fix for if we go around the circle
            if(a >= 360) { a-= 360; }
            if(a < 0) { a+= 360; }

            // get the x, y and font values for this angle
            // these are packed 9 bits each into a 32 bit number in the 
            // lookup table
            var v = textlookup[a];
            var af = (v & 0x7fc0000) >> 18;
            var x = (v & 0x3fe00) >> 9;
            var y = v & 0x1ff;

            // load the font
            var f = font.getFont(af);
            if(!char.equals(" ")) { // can skip drawing a space
                dc.drawText(x,y-fh,f,char,Graphics.TEXT_JUSTIFY_CENTER);
            }

            // move to the next angle
            a += w;
            // move to the next character
            t += reverse ? -1 : 1;
        }
    }
}
