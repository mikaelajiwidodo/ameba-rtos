# Realtek IOT Ameba-RTOS v1.0 Matter SDK

## Release for Matter v1.5

### SDKs Version

```
ameba-rtos Github SDK           : mikaelajiwidodo:release/v1.1+matter_v1.5
ameba-rtos-matter branch        : mikaelajiwidodo:ameba-rtos-v1.1/v1.5-branch, tested @ 18b005e39f554add23e811e4304d70fca43b063f
connectedhomeip branch          : v1.5-branch, tested @ 6603ea3c2067037d770fde4291a2cdd7fabac040
```

### Changes added to ameba-rtos/release/v1.1 Github SDK details

1. Modified `Menuconfig` and `CMake` scripts to support Matter sub-module
2. Created dummy `CMakeLists.txt` at `component/application/` to avoid build error for AmebaSmart
3. Added `ble_matter_adapter_peripheral` example to the `bluetooth` folder
4. `LwIP` modifications
    - Added `extern struct netif xnetif[];` to lwip_netconf.h
    - Added `CONFIG_PBUF_POOL_BUFSIZE` in the `Menuconfig` to modify `PBUF_POOL_BUFSIZE`
5. `FreeRTOS` modifications
    - Added `xPortResetHeapMinimumEverFreeHeapSize` API
    - Modified `lib_freertos_smp.a` of AmebaSmart
6. `TrustZone` modifications
    - Added `CONFIG_TZ_S_SIZE` in the `Menuconfig` to modify `TZ_S_SIZE` of `ameba_layout.ld` (dplus and lite)
    - Added `CONFIG_SECURE_HEAP_SIZE` in the `Menuconfig` to modify `secureconfigTOTAL_SRAM_HEAP_SIZE` of `FreeRTOSConfig.h`
    - Modified `postbuild.cmake` (dplus and lite) to fix TrustZone issue by adding `OR CONFIG_TRUSTZONE_FOR_KM4` beside `CONFIG_TRUSTZONE`
    - Modified `component/soc/amebalite/fwlib/CMakeLists.txt` by adding `ram_${c_MCU_TYPE}/ameba_arch.c`, `ram_common/ameba_ipc_ram.c`, and `ram_common/ameba_pll.c` to the `image3` part
    - Modified `component/soc/amebasmart/atf/`
7. `SoC` header files modifications
    - Removed `IN/OUT/INOUT` macros out of header files
    - Modified `PeripheralNames.h` to support Matter sub-module
    - Added `extern "C"` to `ameba_reset.h` and `strproc.h` if `__cplusplus` is defined
8. Added `matter_setup.sh` script to help setting up Matter

## Build Instruction

### Prerequisites

Before you start, ensure you have met the necessary prerequisites. For detailed information, please refer to the [Building Guide](https://github.com/project-chip/connectedhomeip/blob/master/docs/guides/BUILDING.md) provided in the Connected Home over IP (CHIP) project.

### Environment

Tested on Ubuntu 24.04 LTS

### Ameba Matter SDK 

#### Setting Up the SDKs

1. Create and enter new directory
    ```bash
    mkdir dev
    cd dev
    ```

2. Clone ameba-rtos/release/v1.1+matter_v1.5 Github SDK into 'dev' directory
    ```bash
    git clone https://github.com/mikaelajiwidodo/ameba-rtos.git --branch release/v1.1+matter_v1.5
    ```

3. Clone connectedhomeip sdk into 'dev' directory
    ```bash
    git clone --recurse-submodules https://github.com/project-chip/connectedhomeip
    ```

4. Make sure ameba-rtos and connectedhomeip are on the same directory level
    ```
    dev/
    ├── ameba-rtos
    └── connectedhomeip
    ```

5. Set Matter Build Environment
    ```bash
    cd connectedhomeip
    git switch v1.5-branch
    git submodule sync
    git submodule update --init --recursive
    source scripts/bootstrap.sh
    ```

6. Run ameba.sh to install additional python modules
    ```bash
    cd ameba-rtos
    chmod u+x ameba.sh
    ./ameba.sh
    ```

7. Run matter_setup.sh to clone the ameba-rtos-matter repository to component/application/matter, disable ameba WiFi fast reconnect, and remove [tools/scripts/copy.py](Readme.md#L10)
    ```bash
    cd ameba-rtos
    chmod u+x matter_setup.sh
    ./matter_setup.sh ameba-rtos v1.5
    ```

#### Setting Up the Build Configuration

1. Run `python menuconfig.py` at one of the ameba project folder
    ```bash
    cd ameba-rtos/amebaxxx_gcc_project
    python menuconfig.py
    ```

2. Set the following settings in the `menuconfig`:
    - To enable Matter, navigate in the following sequence:
        ```
        MENUCONFIG FOR General
        └─> CONFIG APPLICATION
            └─> Matter Config
                └─> [*] Enable Matter # Additional settings can be enabled below
                    ├─> [ ] Enable Matter IPv4
                    └─> [ ] Enable Matter Terms and Condition
        ```
    - To support Matter, LwIP configurations needs to be updated, please navigate in the following sequence:
        ```
        Connectivity config
        └─> CONFIG LWIP
            ├─> [*] Enable LWIP IPv6
            └─> (1500) Len of pbuf pool
        ```
    - To enable Matter BLE, enable Matter, then navigate in the following sequence:
        ```
        Connectivity config
        └─> CONFIG BT
            └─> [*] Enable BT
        MENUCONFIG FOR General
        └─> CONFIG APPLICATION
            └─> Matter Config
                └─> [*] Enable Matter
                    └─> [*] BLE Matter Adapter
        ```
    - To enable Matter Secure, enable Matter, then navigate in the following sequence: # THE TRUSTZONE IS STILL BUGGY
        ```
        MENUCONFIG FOR General
        ├─> CONFIG TrustZone #THIS OPTION IS ONLY ENABLED FOR AMEBADPLUS AND AMEBALITE!!!
        │   └─> [*] Enable TrustZone
        │       └─> TrustZone by RDP or TFM (RDP_BASIC) #THIS OPTION IS ONLY ENABLED FOR AMEBADPLUS!!!
        └─> CONFIG APPLICATION
            └─> Matter Config
                └─> [*] Enable Matter
                    └─> [*] Enable Matter Secure
        ```

3. Save the new kernel configuration

#### Build the Firmware

The following is the example to build all_clusters example firmware.

1. Activate Matter build environment
    ```bash
    cd connectedhomeip
    source scripts/activate.sh
    ```

2. Build Matter library and final firmware in one go
    ```bash
    cd ameba-rtos/amebaxxx_gcc_project
    python build.py -D MATTER_EXAMPLE=all_clusters
    ```

#### Flash the Firmware using Python script (New!)

The following is the example to flash the firmware to `/dev/ttyUSB0` port.
```bash
cd ameba-rtos/amebaxxx_gcc_project
python flash.py -p /dev/ttyUSB0
```

If the app image is too large, please add the --image/-i option
- For AmebaDplus / AmebaLite
    ```bash
    python flash.py -p /dev/ttyUSB0 -i km4_boot_all.bin 0x08000000 0x08014000 -i <km0_km4_app.bin or kr4_km4_app.bin> 0x08014000 0x08300000
    ```

- For AmebaSmart
    ```bash
    python flash.py -p /dev/ttyUSB0 -i km4_boot_all.bin 0x08000000 0x08020000 -i km0_km4_ca32_app.bin 0x08020000 0x08400000
    ```

#### Monitor Ameba Log using Python script (New!)

The following is the example to monitor Ameba log through the `/dev/ttyUSB0` port.
```bash
cd ameba-rtos/amebaxxx_gcc_project
python monitor.py -p /dev/ttyUSB0 -b 1500000
```

#### Troubleshooting

1. Please try to `ninja clean_matter_libs clean` at the corresponding `ameba-rtos/amebaxxx_gcc_project/build` if faced with any build issue when building the firmware.

2. If met with issue during `Set Matter Build Environment` (e.g., pw command issue), please remove the environment with `rm -rf .environment/*` in connectedhomeip directory and `source scripts/bootstrap.sh` again.

3. If met with heap exhaustion issue during runtime of AmebaLite with Matter Secure enabled, you may update the `CONFIG Link Option` in the `menuconfig`:
    ```
    CONFIG Link Option
    └─> (CodeInXip_DataHeapInPsram) IMG2(Application) running on FLASH or PSRAM?
    ```

## Documents

For further details on other Matter related guide, please refer to the [Markdown documentation](https://github.com/mikaelajiwidodo/ameba-rtos-matter/blob/ameba-rtos-v1.1/v1.5-branch/README.md) or [AN0204 Matter Application Note](https://github.com/mikaelajiwidodo/ameba-rtos-matter/blob/ameba-rtos-v1.1/v1.5-branch/docs/AN0204%20Realtek%20Matter%20application%20note.en.pdf). Please refer to the documentations located at [ameba-rtos-v1.1/v1.5-branch branch](https://github.com/mikaelajiwidodo/ameba-rtos-matter/tree/ameba-rtos-v1.1/v1.5-branch) only.
