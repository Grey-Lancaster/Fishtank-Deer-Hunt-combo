#!/usr/bin/env bash
# Build Fish Tank + Deer Hunt on greyhound and merge them into one USB-flash image per board.
#   tools/build_combo.sh [board ...]        boards: freenove4 freenove28 cyd28 cyd28usb2 (default: all four)
# Needs the "GreyHound" entry in ~/.ssh/config. Output: dist/Fishtank-DeerHunt-<board>-USB.bin, flash it at offset 0x0.
# Each image is also copied to docs/firmware/fishtank-deerhunt-<board>.bin, which is what the web installer flashes.
# There is no OTA in the combo build, so this image is the only way onto a board (and the only way to update one).
set -euo pipefail
BOARDS=("$@"); [ ${#BOARDS[@]} -eq 0 ] && BOARDS=(freenove4 freenove28 cyd28 cyd28usb2)
SSH=(ssh -o BatchMode=yes -o ControlMaster=no -o ControlPath=none GreyHound)
SCP=(scp -o BatchMode=yes -o ControlMaster=no -o ControlPath=none)
REMOTE='~/cyd-build/Fishtank-Deer-Hunt-Combo'
cd "$(dirname "$0")/.."

tar -czf - platformio.ini partitions_*.csv boards include lib_freenove apps tools | "${SSH[@]}" "mkdir -p $REMOTE && tar -xzf - -C $REMOTE"
mkdir -p dist
for b in "${BOARDS[@]}"; do
  case $b in
    freenove4|freenove28) CHIP=esp32s3; BOOTOFF=0x0;    APP1=0x310000; SIZE=16MB ;;
    cyd28|cyd28usb2)      CHIP=esp32;   BOOTOFF=0x1000; APP1=0x200000; SIZE=4MB ;;
    *) echo "unknown board $b" >&2; exit 1 ;;
  esac
  echo "== $b"
  "${SSH[@]}" "set -e; cd $REMOTE; P=~/.platformio; export PATH=\$P/penv/bin:\$PATH
    pio run -e fish-$b 2>&1 | grep -E 'error|SUCCESS|FAILED|Flash:' || true
    mkdir -p out/$b; cp .pio/build/fish-$b/firmware.bin out/$b/fish.bin
    pio run -e deer-$b 2>&1 | grep -E 'error|SUCCESS|FAILED|Flash:' || true
    cp .pio/build/deer-$b/firmware.bin out/$b/deer.bin
    cp .pio/build/deer-$b/bootloader.bin .pio/build/deer-$b/partitions.bin out/$b/
    python \$P/packages/tool-esptoolpy/esptool.py --chip $CHIP merge_bin -o out/$b/combo.bin --flash_mode dio --flash_size $SIZE \
      $BOOTOFF out/$b/bootloader.bin 0x8000 out/$b/partitions.bin 0xe000 \$P/packages/framework-arduinoespressif32/tools/partitions/boot_app0.bin \
      0x10000 out/$b/fish.bin $APP1 out/$b/deer.bin"
  "${SCP[@]}" "GreyHound:cyd-build/Fishtank-Deer-Hunt-Combo/out/$b/combo.bin" "dist/Fishtank-DeerHunt-$b-USB.bin"
  ls -l "dist/Fishtank-DeerHunt-$b-USB.bin"
  mkdir -p docs/firmware
  cp "dist/Fishtank-DeerHunt-$b-USB.bin" "docs/firmware/fishtank-deerhunt-$b.bin"
done
