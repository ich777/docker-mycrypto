#!/bin/bash
export DISPLAY=:99
export XAUTHORITY=${DATA_DIR}/.Xauthority

LAT_V="$(wget -qO- https://api.github.com/repos/MyCryptoHQ/MyCrypto/releases/latest | jq -r '.tag_name')"
CUR_V="$(find ${DATA_DIR}/bin -maxdepth 1 -type f -name "mycryptov_*" 2>/dev/null | cut -d '_' -f2)"

if [ -z "${LAT_V}" ]; then
  if [ -z "${CUR_V}" ]; then
    echo "---Can't get latest version from MyCrypto and found no local installed version!---"
	sleep infinity
  else
    echo "---Can't get latest version from MyCrypto, falling back to installed version ${CUR_V}---"
	LAT_V="${CUR_V}"
  fi
fi

echo "---Version Check---"
if [ -z "${CUR_V}" ]; then
  echo "---MyCrypto not installed, installing...---"
  cd ${DATA_DIR}
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/mycrypto_${LAT_V}.AppImage "https://github.com/MyCryptoHQ/MyCrypto/releases/download/${LAT_V}/linux-x86-64_${LAT_V}_MyCrypto.AppImage" ; then
    echo "---Sucessfully downloaded MyCrypto---"
  else
    echo "---Something went wrong, can't download MyCrypto, putting container in sleep mode---"
    sleep infinity
  fi
  chmod +x ${DATA_DIR}/mycrypto_${LAT_V}.AppImage
  ${DATA_DIR}/mycrypto_${LAT_V}.AppImage --appimage-extract
  mkdir -p ${DATA_DIR}/bin
  mv $(find ${DATA_DIR}/squashfs-root -type d -name "app")/* ${DATA_DIR}/bin/
  rm -rf ${DATA_DIR}/squashfs-root ${DATA_DIR}/mycrypto_${LAT_V}.AppImage
  touch ${DATA_DIR}/bin/mycryptov_${LAT_V}
elif [ "${CUR_V}" != "${LAT_V}" ]; then
  echo "---Version missmatch, installed v${CUR_V}, downloading and installing latest v${LAT_V}...---"
  cd ${DATA_DIR}
  rm -rf ${DATA_DIR}/bin
  if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/mycrypto_${LAT_V}.AppImage "https://github.com/MyCryptoHQ/MyCrypto/releases/download/${LAT_V}/linux-x86-64_${LAT_V}_MyCrypto.AppImage" ; then
    echo "---Sucessfully downloaded MyCrypto---"
  else
    echo "---Something went wrong, can't download MyCrypto, putting container in sleep mode---"
    sleep infinity
  fi
  chmod +x ${DATA_DIR}/mycrypto_${LAT_V}.AppImage
  ${DATA_DIR}/mycrypto_${LAT_V}.AppImage --appimage-extract
  mkdir -p ${DATA_DIR}/bin
  mv $(find ${DATA_DIR}/squashfs-root -type d -name "app")/* ${DATA_DIR}/bin/
  rm -rf ${DATA_DIR}/squashfs-root ${DATA_DIR}/mycrypto_${LAT_V}.AppImage
  touch ${DATA_DIR}/bin/mycryptov_${LAT_V}
elif [ "${CUR_V}" == "${LAT_V}" ]; then
	echo "---MyCrypto v$CUR_V up-to-date---"
fi

if [ "${CUSTOM_RES_W}" -le 1279 ]; then
	echo "---Width to low must be a minimal of 1280 pixels, correcting to 1024...---"
    CUSTOM_RES_W=1280
fi
if [ "${CUSTOM_RES_H}" -le 1023 ]; then
	echo "---Height to low must be a minimal of 1024 pixels, correcting to 768...---"
    CUSTOM_RES_H=1024
fi

echo "---Checking for old display lock files---"
rm -rf /tmp/.X99*
rm -rf /tmp/.X11*
rm -rf ${DATA_DIR}/.vnc/*.log ${DATA_DIR}/.vnc/*.pid
chmod -R ${DATA_PERM} ${DATA_DIR}
if [ -f ${DATA_DIR}/.vnc/passwd ]; then
	chmod 600 ${DATA_DIR}/.vnc/passwd
fi
screen -wipe 2&>/dev/null

echo "---Starting TurboVNC server---"
vncserver -geometry ${CUSTOM_RES_W}x${CUSTOM_RES_H} -depth ${CUSTOM_DEPTH} :99 -rfbport ${RFB_PORT} -noxstartup ${TURBOVNC_PARAMS} 2>/dev/null
sleep 2
echo "---Starting Fluxbox---"
env HOME=/etc /usr/bin/fluxbox 2>/dev/null &
sleep 2
echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem ${NOVNC_PORT} localhost:${RFB_PORT}
sleep 2

echo "---Starting MyCrypto---"
cd ${DATA_DIR}
${DATA_DIR}/bin/mycrypto