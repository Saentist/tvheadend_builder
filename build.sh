#!/bin/bash

BASE=$(dirname "$0")
(
  if [ -d "$BASE/tvheadend" ]; then
    cd "$BASE/tvheadend"
    git pull
  else
    cd "$BASE"
    git clone https://github.com/tvheadend/tvheadend.git tvheadend # --depth=5 (need version tag workaround else 0.0.0 version)
    cd "$BASE/tvheadend"
  fi
  time AUTOBUILD_CONFIGURE_EXTRA="--disable-bintray_cache --enable-vaapi --enable-nvenc --disable-hdhomerun_client --disable-hdhomerun_static " ./Autobuild.sh -j$(nproc) # edit only betwin "quotation marks"
) | tee "$BASE/build.log"
