FROM ubuntu:bionic

RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common && DEBIAN_FRONTEND=noninteractive apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get -y install git openjdk-8-jre-headless build-essential sudo wget unzip libxxf86vm1 libgtk2.0-0 openssh-server libusb-1.0-0 libsm6 libwebkitgtk-1.0-0 imagemagick imagemagick-common x11-apps nodejs && apt-get clean && rm -rf /var/lib/apt/lists/*

# need this version of libpng
RUN wget -q https://launchpad.net/~ubuntu-security/+archive/ubuntu/ppa/+build/15108504/+files/libpng12-0_1.2.54-1ubuntu1.1_amd64.deb && dpkg -i *deb && rm *deb

# create a garmin user
RUN useradd -ms /bin/bash garmin
USER garmin
WORKDIR /home/garmin

# install the sdk
RUN wget -q https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-lin-3.1.8-2020-05-01-05516d846.zip && unzip *zip && rm *zip

RUN mkdir /home/garmin/watch
WORKDIR /home/garmin/watch

# generate a developer key
RUN openssl genrsa -out developer_key.pem 4096 && openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt

# generate the fonts
RUN mkdir resources source
COPY generatefonts.js generatefonts.js
COPY dodevices.sh dodevices.sh
COPY font.ttf font.ttf
RUN ./dodevices.sh

# copy the app
COPY monkey.jungle monkey.jungle
COPY manifest.xml manifest.xml
COPY resources/strings.xml resources/strings.xml
COPY resources/drawables.xml resources/drawables.xml
COPY resources/launcher_icon.png resources/launcher_icon.png
COPY source/RoundTextApp.mc source/RoundTextApp.mc
COPY source/RoundTextView.mc source/RoundTextView.mc
COPY source/Font.mc source/Font.mc
COPY source/BezelText.mc source/BezelText.mc
COPY source/Hand.mc source/Hand.mc

# build the app
RUN ~/bin/monkeyc -d fenix6xpro -f monkey.jungle -y developer_key.der -o test.prg

# run the app, wait for the X authority file to get copied in first
CMD while [ ! -f /tmp/.docker.xauth ]; do sleep 1; done; ~/bin/simulator & ~/bin/monkeydo test.prg fenix6xpro
