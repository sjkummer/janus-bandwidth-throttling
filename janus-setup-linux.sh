#!/bin/sh

# error setup ->
set -eE
cleanup() {
  local EXIT_CODE=$?
  #echo "exit code: $EXIT_CODE"
  if [ "$EXIT_CODE" != "0" ]; then
    echo "ERROR"
  fi
  exit $EXIT_CODE
}
ignore_error()
{
    true;
}
trap 'cleanup' EXIT
# <- error setup


sudo apt-get -y update

# Various Dependencies
sudo apt-get -y install ffmpeg tcpdump openssl wget git

# Janus Dependencies #1 from README
sudo apt-get -y install libmicrohttpd-dev libjansson-dev \
    	libssl-dev libsofia-sip-ua-dev libglib2.0-dev \
    	libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev \
    	libconfig-dev pkg-config gengetopt libtool automake

# Debian: Make sure no outdated libsrtp is used
sudo apt-get -y remove libsrtp2-1 || ignore_error
#sudo apt -y autoremove

# Janus Dependencies #2 Undocumented
sudo apt-get -y install gtk-doc-tools glib2.0

# Make temporary directory
sudo rm -rfd janus-tmp-builddir || ignore_error
mkdir janus-tmp-builddir
cd janus-tmp-builddir

# Janus Dependecnies #3 libnice
sudo apt install -y python3-pip
sudo pip3 install meson
sudo pip3 install ninja
sudo apt-get remove libnice-dev
sudo apt-get -y install automake libtool
sudo rm -rfd libnice || ignore_error
git clone https://gitlab.freedesktop.org/libnice/libnice.git
cd libnice
git checkout 0.1.18
meson builddir --prefix=/usr
ninja -C builddir
sudo ninja -C builddir install
cd ..
echo "SUCCESS libnice"


# Janus Dependencies #4 srtp
sudo rm -rfd libsrtp-2.3.0 || ignore_error
sudo rm -rfd v2.3.0.tar.gz || ignore_error
wget https://github.com/cisco/libsrtp/archive/v2.3.0.tar.gz \
&& tar xfv v2.3.0.tar.gz \
&& cd libsrtp-2.3.0 \
&& ./configure --prefix=/usr --enable-openssl \
&& make shared_library \
&& sudo make install \
&& cd .. \
&& rm -rdf libsrtp-2.3.0
echo "SUCCESS libsrtp"


# Install libWebsockets
sudo apt-get -y install cmake
sudo rm -rfd libwebsockets || ignore_error
git clone https://libwebsockets.org/repo/libwebsockets \
&& cd libwebsockets \
&& git checkout v3.2-stable \
&& mkdir build \
&& cd build \
&& cmake -DLWS_MAX_SMP=1 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
&& make \
&& sudo make install \
&& cd .. \
&& rm -rfd libwebsockets \
&& cd ..
echo "SUCCESS libwebsockets"


# Install Janus
sudo rm -rfd janus-gateway || ignore_error
git clone $JANUS_REPO \
&& cd janus-gateway \
&& git fetch \
&& git checkout $JANUS_BRANCH \
&& sh autogen.sh \
&& ./configure --prefix=/opt/janus PKG_CONFIG_PATH=/usr/libnice/lib/pkgconfig:/usr/srtp/lib/pkgconfig \
&& make \
&& sudo make install \
&& sudo make configs \
&& cd .. \
&& rm -rfd janus-gateway

# Cleanup temporary directory
cd ..
sudo rm -rfd janus-tmp-builddir

echo "SUCCESS janus-gateway setup"
echo ""
echo "To start janus, run:"
echo "/opt/janus/bin/janus"
