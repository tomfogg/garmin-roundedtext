#!/bin/sh

if [ $# -lt 4 ]; then
    echo "Usage: $0 <font file> <font name> <font size> <list of characters to include> <trim blank space>"
    echo "eg:"
    echo "$0 ../../myfont.ttf myfont 18 6 6 \"A B C D E F SPACE STAR ( #\" no"
    echo
    echo trim blank space is useful for clock hands, yes to trim no or blank to not trim
    exit
fi

font=$1
fontname=$2
fontsize=$3
charlist=$4
maxwidth=256
if test "$5" = "yes"; then
    addtrim=-trim
fi

# work out how much space there is at the top and bottom of the letters so we can trim it off later
convert -page +0+0 -font $font -background black -fill white -pointsize $fontsize label:"A" PNG8:max.png
size=$(identify max.png | awk '{sub("x"," ",$3); print $3}')
fh=$(echo $size | awk '{print $2}')
convert max.png -gravity north -background red -splice 0x5 PNG8:max.png
convert max.png -trim +repage PNG8:max.png
size=$(identify max.png | awk '{sub("x"," ",$3); print $3}')
ht=$(echo $size | awk '{print $2}')
bottomtrim=$((fh-ht))
convert max.png -gravity south -background red -splice 0x5 PNG8:max.png
convert max.png -trim +repage PNG8:max.png
size=$(identify max.png | awk '{sub("x"," ",$3); print $3}')
hb=$(echo $size | awk '{print $2}')
toptrim=$((fh-bottomtrim-hb))
ch=$((fh-bottomtrim-toptrim))
echo font height is $fh, space at top is $toptrim, space at bottom is $bottomtrim, cut height is $ch

# create a max size of square the font will be
convert -page +0+0 -font $font -background black -fill white -pointsize $fontsize label:"W" -trim -rotate 45 PNG8:max.png
# get the width and height
size=$(identify max.png | awk '{sub("x"," ",$3); print $3}')
w=$(echo $size | awk '{print $1}')
h=$(echo $size | awk '{print $2}')
rm max.png

echo "generating font of size $w $h"
echo "<fonts>" > fonts.xml
for a in $(seq -90 6 90); do
    echo "Doing angle $a"
    x=0
    y=0
    row=0
    col=0
    num=$((a+90))
    fn=${fontname}_$num.fnt

    # need to turn on font antialiasing for right angles since
    # the -rotate wont do it for us
    if test "$a" = "0" | test "$a" = "-90" | test "$a" = "90"; then
        aaline="+antialias"
    else 
        aaline=""
    fi

    # create the font definition file
    echo info face=$fontname size=$fontsize bold=0 italic=0 charset=ascii unicode=0 stretchH=100 smooth=1 aa=0 padding=0,0,0,0 spacing=0,0 outline=0 > $fn
    echo common lineHeight=$fontsize base=$fontsize scaleW=256 scaleH=256 pages=1 packed=0 >> $fn
    echo page id=0 file=\"${fontname}_$num.png\" >> $fn
    echo chars count=${#charlist} >> $fn

    for c in $charlist; do

        # its really hard to escape some characters
        if test "$c" = "STAR"; then
            chr=42
            c="*"
        fi
        if test "$c" = "SPACE"; then
            # use a 0 for a space so we get >0 width
            chr=32
            c=0
        else
            # get the character code for this letter
            chr=$(printf '%d' "'$c'")
        fi
        
        # if normal angle text, use the actual width of the letter, rather than the rotated one
        if test "$a" = "0"; then
            convert -page +0+0 -font $font -background black -fill white -pointsize $fontsize label:"$c" PNG8:$chr.png
            size=$(identify $chr.png | awk '{sub("x"," ",$3); print $3}')
            ww=$(echo $size | awk '{print $1}')
        else
            ww=$w
        fi

        # draw the letter to a png
        convert -page +0+0 -font $font -background black -fill white -pointsize $fontsize label:"$c" $addtrim PNG8:$chr.png
        if test "$addtrim" = ""; then
            # trim the spacing from the top and bottom
            convert $chr.png -chop 0x$toptrim -gravity south -chop 0x$bottomtrim PNG8:$chr.png
        fi
 
        # rotate the letter and put it on the max size canvas
        convert $chr.png -background black -gravity center -rotate $a +repage -extent ${ww}x$h PNG8:$chr.png

        # blank out the image for a space
        if test "$chr" = "32"; then
            convert $chr.png -fill black -colorize 100% PNG8:$chr.png
        fi

        # add the rotated letter to the end of the row of letters
        if test $x = 0; then
            # first letter
            mv $chr.png row$row.png
        else
            # append to the row
            convert +append -background black row$row.png $chr.png row$row.png
            # clean up the letter file
            rm $chr.png
        fi

        # add to the font definition file
        echo char id=$chr x=$x y=$y width=$ww height=$h xoffset=0 yoffset=0 xadvance=$ww page=0 chnl=0 >> $fn
        
        
        # increment the values to use in the font definition file
        x=$((x+$ww))
        if test $x -gt $maxwidth; then 
            size=$(identify row$row.png | awk '{sub("x"," ",$3); print $3}')
            rowh=$(echo $size | awk '{print $2}')
            row=$((row+1))
            col=0
            x=0
            y=$((y+rowh))
        fi
    done
    # add this row to the full font image
    convert -append -background black row*png ${fontname}_$num.png
    # clean up the row files
    rm row*png
    echo "<font id=\"${fontname}_$num\" filename=\"${fontname}_$num.fnt\" antialias=\"true\"/>" >> fonts.xml
done
echo "</fonts>" >> fonts.xml
