#!/usr/bin/node

const { execSync } = require('child_process');
const fs = require('fs');

if(process.argv.length < 9) {
    console.log(`Usage: ${process.argv[1]} <font file> <font name> <character size> <list of characters to include> <degrees per font> <radius> <lookups> <lookupstep>");
eg:
${process.argv[1]} ../../myfont.ttf myfont 60C "A B C D E F SPACE STAR ( #" 6 130 "1 2" 1

- character size determines the size of font used
    - 60C means size the font to fit 60 characters into the diameter of the watch face
    - 3L means size the font to fit 3 lines of text in the radius of the watch face
- degrees is the number of degrees to go clockwise on each rotation
    - larger values will use less memory but the angles the characters are at won't fit the circle as well, smaller values will look better but use more memory
- radius is half with width of the watch face in pixels
- lookups is the lines of text you are going to use eg: "1 3" means i need to draw text at the outermost ring of the watch face, then two lines in from that
- lookupstep is the number of degrees to move on per lookup value. if you only need to do angles every 6 degrees (eg clock hands) use a 6 here, otherwise 1
`);
    process.exit();
}

const font = process.argv[2];
const fontname = process.argv[3];
const sizing = process.argv[4];
const charlist = process.argv[5].split(/ /);
const maxwidth = 256;
const degrees = +process.argv[6];
const radius = +process.argv[7];
const lookups = process.argv[8].split(/ /);
const lookupstep = +process.argv[9];

function getSize(fn) {
    let res = (""+execSync('identify '+fn)).match(/((\d+)x(\d+))/);
    return [+res[2],+res[3]];
}

let fontsize=0;
let w=0;
let h=0;
let m = sizing.match(/(\d+)([CL])/);
if(!m) {
    console.log('wrong value for sizing ',sizing);
    process.exit();
}
if(m[2] == 'C') {
    let chars = m[1];
    let wantw=Math.floor(2*Math.PI*radius/chars);
    console.log(`finding a fontsize that fits ${chars} letters around the bezel, looking for width ${wantw}`);
    do {
        fontsize += 1;
        execSync(`convert -page +0+0 -font ${font} -background black -fill white -pointsize ${fontsize} label:"${charlist[0]}" -trim PNG8:max.png`);
        [w,h] = getSize('max.png');
        fs.unlinkSync('max.png');
        wantw = 2*Math.PI*(radius-h)/chars;
    } while(w < wantw);
} else {
    let chars = m[1];
    let wanth=Math.floor(radius/chars);
    console.log(`finding a fontsize that fits ${chars} in the radius, looking for height ${wanth}`);
    do {
        fontsize += 1;
        execSync(`convert -page +0+0 -font ${font} -background black -fill white -pointsize ${fontsize} label:"${charlist[0]}" -trim PNG8:max.png`);
        [w,h] = getSize('max.png');
        fs.unlinkSync('max.png');
    } while(h < wanth);
}
console.log(`fontsize is ${fontsize} width is ${w}, height is ${h} = ${Math.floor(2*Math.PI*radius/w)} diameter characters`);


// work out how much space there is at the top and bottom of the letters so we can trim it off later
execSync(`convert -page +0+0 -font ${font} -background black -fill white -pointsize ${fontsize} label:"${charlist[0]}" PNG8:max.png`);
let fh = getSize('max.png')[1];
execSync('convert max.png -gravity north -background red -splice 0x5 PNG8:max.png');
execSync('convert max.png -trim +repage PNG8:max.png');
let ht = getSize('max.png')[1];
let bottomtrim=fh-ht;
execSync('convert max.png -gravity south -background red -splice 0x5 PNG8:max.png');
execSync('convert max.png -trim +repage PNG8:max.png');
let hb = getSize('max.png')[1];
let toptrim=fh-bottomtrim-hb;
let ch=fh-bottomtrim-toptrim;
console.log(`font height is ${fh}, space at top is ${toptrim}, space at bottom is ${bottomtrim}, cut height is ${ch}`);

// create a max size of square the font will be
execSync(`convert -page +0+0 -font ${font} -background black -fill white -pointsize ${fontsize} label:"${charlist[0]}" -trim -rotate 42 PNG8:max.png`);
[w,h] = getSize('max.png');

// get the widths of each letter
// increase by 20% to allow for compression due to rotation
let letterwidths = {};
charlist.map(c=>{
    c = c == '"' ? '\\"' : c;
    execSync(`convert -page +0+0 -font ${font} -background black -fill white -pointsize ${fontsize} label:"${c}" PNG8:max.png`);
    letterwidths[c == '\\"' ? '"' : c] = Math.floor(1.1*getSize('max.png')[0]/(2*Math.PI*radius/360));
    fs.unlinkSync('max.png');
});
// use smallest space for space
letterwidths[' '] = Object.values(letterwidths).reduce((s,d)=>d<s?d:s,10000);

let fontfiles = [];
[...Array(180/degrees).keys()].map(d=>d*degrees+270).map(d=>d>=360?d-360:d).map(a=>{
    let row = 0;
    let x = 0;
    let y = 0;
    let fontchars = [];
    console.log(`generating font ${a}`);
    let spacewidth = 1000;
    charlist.map(c=>{
        let chr = c.charCodeAt(0);
        c = c == '"' ? '\\"' : c;
        // write the letter
        execSync(`convert -page +0+0 -font ${font} -background black -fill white -pointsize ${fontsize} label:"${c}" PNG8:chr.png`);
    
        // trim off the top and bottom space
        execSync(`convert chr.png -chop 0x${toptrim} -gravity south -chop 0x${bottomtrim} PNG8:chr.png`);
       
        // trim off the left and right space
        execSync('convert chr.png -gravity east -background red -splice 5x0 PNG8:chr.png');
        execSync('convert chr.png -trim +repage PNG8:chr.png');
        execSync('convert chr.png -gravity west -background red -splice 5x0 PNG8:chr.png');
        execSync('convert chr.png -trim +repage PNG8:chr.png');
       
        // rotate the letter
        execSync(`convert chr.png -background black -gravity center -rotate ${a} +repage PNG8:chr.png`);

        // the size of the rotated image
        let [ww,wh]= getSize('chr.png');

        // add the image to the font image row
        if(x == 0) fs.renameSync('chr.png',`row${row}.png`);
        else {
            execSync(`convert +append -background black row${row}.png chr.png row${row}.png`);
            fs.unlinkSync('chr.png');
        }
        
        fontchars.push(`char id=${chr} x=${x} y=${y} width=${ww} height=${wh} xoffset=${0} yoffset=${Math.round((h-wh)/2)} xadvance=${ww} page=0 chnl=0`);

        spacewidth = ww < spacewidth ? ww : spacewidth;
        x+=ww;
        if(x > maxwidth) {
            y += getSize(`row${row}.png`)[1];
            x = 0;
            row++;
        }
    });

    // add one for space
    if(a==0) {
        fontchars.push(`char id=32 x=0 y=0 width=0 height=0 xoffset=0 yoffset=0 xadvance=${spacewidth} page=0 chnl=0`);
    }

    // add the row image to the font image
    let filename = `${fontname}_${a}`;
    let rows = fs.readdirSync('.').filter(f=>f.match(/^row\d+.png/));
    execSync(`convert -append -background black ${rows.join(' ')} ${filename}.png`);
    fontfiles.push(filename);
    rows.map(f=>fs.unlinkSync(f));

    fs.writeFileSync(`${filename}.fnt`,`info face=${fontname} size=${fontsize} bold=0 italic=0 charset=ascii unicode=0 stretchH=100 smooth=1 aa=0 padding=0,0,0,0 spacing=0,0 outline=0
common lineHeight=${h} base=${h} scaleW=256 scaleH=256 pages=1 packed=0
page id=0 file="${filename}.png"
chars count=${charlist.length}
${fontchars.join("\n")}
`);
});

fs.writeFileSync('letterwidths.json',JSON.stringify(letterwidths));
fs.writeFileSync('fonts.xml',`<fonts>
   ${fontfiles.map((f)=>'<font id="'+f+'" filename="'+f+'.fnt" antialias="true" />').join("\n")}
</fonts>
`);
fs.writeFileSync(`ResFont${fontname}.mc`,`using Toybox.WatchUi as A;
function getFont${fontname}(f) {
   ${fontfiles.map((n,i)=>(i>0 ? 'else if' : 'if')+'(f == '+(n.match(/(\d+)$/)[1])+') { return A.loadResource(Rez.Fonts.'+n+"); }").join("\n")}
}`);

function dolookup(r,s,step,step2) {
    console.log('doing lookup ',r,s,step,step2);
    let l = [];
    for(let a=0;a<360;a+=step2) {
        let x = Math.round(r+s*Math.sin(a*Math.PI/180));
        x = x < 0 ? 0 : x;
        let y = Math.round(r-s*Math.cos(a*Math.PI/180));
        y = y < 0 ? 0 : y;

        let c = Math.round(a/step)*step - Math.floor((a+90)/180)*180;
        c=c<0?c+360:c;
        c=c==90?270:c;

        l.push(y | x << 9 | c << 18);
    }
    return JSON.stringify(l);
}

// write the lookups 
if(m[2] == 'L') ch = ch-2; // fudge to fill in gaps in the hands 
let lookupjson = lookups.map(d=>radius-d*ch)
    .map((s,i)=>`<jsonData id="lookup_${fontname}_${i}">${dolookup(radius,s,degrees,lookupstep)}</jsonData>`);
fs.writeFileSync('lookups.xml',`<resources>
<jsonData id="letterwidths_${fontname}" filename="letterwidths.json" />
${lookupjson.join("\n")}
</resources>
`);
fs.writeFileSync(`ResLookups${fontname}.mc`,`using Toybox.WatchUi as A;
function getLookups${fontname}() {
    return [${lookups.map((_,i)=>"A.loadResource(Rez.JsonData.lookup_"+fontname+"_"+i+")").join(",")}];
}`);
