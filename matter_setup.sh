#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <IC type> <Matter version>"
  echo "IC type       : ameba-rtos"
  echo "Matter version: v1.5 / v1.6"
  exit 1
fi

AMEBA="$1"
MATTER_VER="$2"

files_to_delete=(
	"$PWD/tools/scripts/copy.py"
)

ameba_wifi_config=(
  "$PWD/component/soc/usrcfg/amebadplus/ameba_wificfg.c"
  "$PWD/component/soc/usrcfg/amebalite/ameba_wificfg.c"
  "$PWD/component/soc/usrcfg/amebasmart/ameba_wificfg.c"
)

delete_files() {
  echo "Deleting unrequired files"
  for file_path in "${files_to_delete[@]}"; do
    if [ -e "$file_path" ]; then
      rm "$file_path"
      echo "File $file_path removed."
    else
      echo "File $file_path does not exist."
    fi
  done
}

turn_off_wifi_fast_reconnect() {
  echo "Turning off WiFi fast reconnect"
  for file_path in "${ameba_wifi_config[@]}"; do
    if [ -e "$file_path" ]; then
      sed -i 's/^\([[:space:]]*wifi_user_config\.fast_reconnect_en[[:space:]]*=[[:space:]]*\)1;/\10;/' "$file_path"
      echo "File $file_path updated."
    else
      echo "File $file_path does not exist."
    fi
  done
}

case "$AMEBA" in
  ameba-rtos)
    echo "Configuring for $AMEBA"
    delete_files
    turn_off_wifi_fast_reconnect
    ;;
  *)
    echo "Invalid IC type argument. Expected 'ameba-rtos'."
    exit 1
    ;;
esac

case "$MATTER_VER" in
  v1.5|v1.6)
    echo "Matter Version is set to $MATTER_VER"
    ;;
  *)
    echo "Invalid Matter version argument. Expected 'v1.5' / 'v1.6'."
    exit 1
    ;;
esac

if [ ! -d third_party ];then
    mkdir third_party
else
    rm third_party/connectedhomeip
fi

cd third_party
rm -rf connectedhomeip
ln -s ../../connectedhomeip connectedhomeip

cd ../

case "$MATTER_VER" in
  v1.5|v1.6)
    if [ ! -d component/application/matter ] || [ -z "$(find component/application/matter -mindepth 1)" ]; then
      mkdir -p component/application/matter
      git clone https://github.com/Ameba-AIoT/ameba-rtos-matter.git component/application/matter -b ameba-rtos/release/$MATTER_VER
    fi
    ;;
  *)
    echo "Invalid argument. Expected 'v1.5' / 'v1.6'."
    exit 1
    ;;
esac
echo "Matter setup complete"
