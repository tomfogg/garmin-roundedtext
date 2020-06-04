#!/bin/sh

FONTDEGREES=10
HANDDEGREES=6
FONTCHARS="A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9 -"
HANDCHARS="( ) *"
FONTSIZE=60C
HANDSIZE=5L
FONTLOOKUPS="1"
FONTLOOKUPSDEGREES=1
HANDLOOKUPS="1 2 3 4"
HANDLOOKUPSDEGREES=6
RADII="195 140 130 120 109"

# generate the fonts and hands for all the devices
radii="$RADII"; for r in $radii; do \
    d=$((r*2))
    cd ~/watch
    mkdir -p resources-round-${d}x${d}/fonts
    cd resources-round-${d}x${d}/fonts && ../../generatefonts.js \
        ../../font.ttf font $FONTSIZE "$FONTCHARS" \
        $FONTDEGREES $r "$FONTLOOKUPS" $FONTLOOKUPSDEGREES > /dev/null &
done;
for r in $radii; do \
    d=$((r*2))
    cd ~/watch
    mkdir -p resources-round-${d}x${d}/hands
    cd resources-round-${d}x${d}/hands && ../../generatefonts.js \
        ../../font.ttf hand $HANDSIZE "$HANDCHARS" \
        $HANDDEGREES $r "$HANDLOOKUPS" $HANDLOOKUPSDEGREES > /dev/null &
done;

echo "generating fonts"
wait
# copy one of the generated source files
find resources-round-218x218 -name 'Res*mc' -exec mv {} source \;
# remove the multiple generated source files
find resources*/ -name 'ResFont*.mc' -delete;
find resources*/ -name 'ResLookups*.mc' -delete;
sync
