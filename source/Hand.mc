class Hand {

    const SYMBOL_ARROW_UP = '(';
    const SYMBOL_ARROW_DOWN = ')';
    const SYMBOL_HAND = '*';

    function initialize() {
    }

    function draw(dc,val,font) {

        // size is the number of sections the hand is drawn in
        var size = font.handlookups.size();
        for(var i=0;i<size;i++) {

            // get the rotation information from the lookup
            var lookup = font.handlookups[i];
            var v = lookup[val];
            // x, y and font values are packed 9 bits each into 1 32bit number
            var af = (v & 0x7fc0000) >> 18;
            var x1 = (v & 0x3fe00) >> 9;
            var y1 = v & 0x1ff;
           
            // load the font resource
            var f = font.getHand(af);

            // the hand is drawn in sections using different characters for 
            // each section. depending on the angle we need to use a up or down
            // arrow character to get the right result
            var letter = i==0 ? (val >= 45 || val < 15 ? SYMBOL_ARROW_UP : SYMBOL_ARROW_DOWN) : SYMBOL_HAND;

            // draw the actual character
            dc.drawText(x1,y1-font.handheight/2,f,letter,Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
