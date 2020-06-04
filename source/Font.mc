using Toybox.WatchUi as ui;

class Font {

    var fontcache;
    var handcache;
    var fontLRU;

    var fontheight;
    var handheight;

    var handlookups;
    var fontlookups;
    var letterwidths;
    var fontmemorysize;

    var normal;

    function initialize() {

        fontcache = {};
        handcache = {};
        fontLRU = [];

        fontlookups = getLookupsfont();
        handlookups = getLookupshand();


        var stats = System.getSystemStats();
        var memory = stats.freeMemory;

        // get the unrotated font height
        normal = (fontlookups[0][0] & 0x7fc0000) >> 18;
        fontheight = Graphics.getFontHeight(getFont(normal));

        stats = System.getSystemStats();
        fontmemorysize = memory-stats.freeMemory;
        System.println("Size of font file is "+fontmemorysize); // DEBUG

        // get the unrotated hand height
        handheight = Graphics.getFontHeight(getHand(normal));
        letterwidths = ui.loadResource(Rez.JsonData.letterwidths_font);
    }

    function freeMemory() {
        // if we have low memory, evict a font from the cache
        var stats = System.getSystemStats();
        if(fontmemorysize != null && stats.freeMemory < fontmemorysize*4) {
            if(fontLRU.size() > 0) {
                var oldfont = fontLRU[0];
                System.println("ejecting font "+oldfont+" from cache"); // DEBUG
                fontcache.remove(oldfont);
                fontLRU.remove(oldfont);
            }
        }
    }

    function getHand(f) {
        var hand = handcache.get(f);
        if(hand == null) {
            freeMemory();
            System.println("loading hand resource "+f); // DEBUG
            hand = getFonthand(f);
            handcache.put(f,hand);
        }

        return hand;
    }

    // load a font and cache it, use a LRU to free old fonts if memory low
    function getFont(f) {
        var font = fontcache.get(f);
        if(font == null) {
            freeMemory();
            System.println("loading font resource "+f); // DEBUG
            font = getFontfont(f);
            fontcache.put(f,font);
            
        }
           
        // update the LRU
        fontLRU.remove(f);
        fontLRU.add(f);

        return(font);
    }
}
