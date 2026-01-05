#!/bin/bash

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <IC type> <Matter version>"
  echo "IC type       : ameba-rtos"
  echo "Matter version: v1.3 / v1.4 / v1.5"
  exit 1
fi

AMEBA="$1"
MATTER_VER="$2"

files_to_delete=(
	"$PWD/component/soc/amebadplus/cmsis/cmsis.h"
	"$PWD/component/soc/amebadplus/cmsis/cmsis_nvic.h"
	"$PWD/component/soc/amebadplus/cmsis/core_cache.h"
	"$PWD/component/soc/amebadplus/cmsis/core_cm0plus.h"
	"$PWD/component/soc/amebadplus/cmsis/core_cm4_simd.h"
	"$PWD/component/soc/amebadplus/cmsis/core_cmFunc.h"
	"$PWD/component/soc/amebadplus/cmsis/core_cmInstr.h"
	"$PWD/component/soc/amebadplus/cmsis/mpu.h"
	"$PWD/component/soc/amebadplus/cmsis/mpu_config.h"
	"$PWD/component/soc/amebadplus/cmsis/mpu_config_ns.h"
	"$PWD/component/soc/amebadplus/cmsis/mpu_config_s.h"
)

delete_files() {
  for file_path in "${files_to_delete[@]}"; do
    if [ -e "$file_path" ]; then
      rm "$file_path"
      echo "File $file_path removed."
    else
      echo "File $file_path does not exist."
    fi
  done
}

case "$AMEBA" in
  ameba-rtos)
    echo "Configuring for $AMEBA"
    delete_files
    ;;
  *)
    echo "Invalid IC type argument. Expected 'ameba-rtos'."
    exit 1
    ;;
esac

case "$MATTER_VER" in
  v1.3 | v1.4 | v1.5)
    echo "Matter Version is set to $MATTER_VER"
    ;;
  *)
    echo "Invalid Matter version argument. Expected 'v1.3', 'v1.4', or 'v1.5'."
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

case "$AMEBA" in
  ameba-rtos)
    if [ ! -d component/application/matter ] || [ -z "$(find component/application/matter -mindepth 1)" ]; then
      mkdir -p component/application/matter
      git clone https://github.com/Ameba-AIoT/ameba-rtos-matter.git component/application/matter -b ameba-rtos/release/$MATTER_VER
    fi
    ;;
  *)
    echo "Invalid argument. Expected 'ameba-rtos'."
    exit 1
    ;;
esac
echo "Matter setup complete"
