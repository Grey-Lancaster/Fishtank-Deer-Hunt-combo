# Fish Tank + Deer Hunt combo

One board, two apps. [Fish Tank](https://github.com/Grey-Lancaster/CYD-and-Freenove-Fish-Tank) lives in app slot `ota_0` and [Deer Hunt](https://github.com/Grey-Lancaster/CYD-and-Freenove-Deer-and-Turkey-display) in `ota_1`. Switching just points the boot loader at the other slot and restarts (about 3 seconds).

## Easiest way: the web installer

### [➡ Open the Web Installer](https://grey-lancaster.github.io/Fishtank-Deer-Hunt-combo/)

Use **Chrome or Edge on a computer**, plug the board in by USB, pick your board in the list, click **Connect**, then **Flash**. (Freenove boards: hold BOOT, tap RESET, release BOOT first, and press RESET after flashing. The board starts in Fish Tank and asks you to pick your WiFi on the screen.) Flashing wipes the board, including its saved WiFi.

Prefer the command line? `esptool.py write_flash 0x0 Fishtank-DeerHunt-<board>-USB.bin` with the file from `docs/firmware/`.

## Switching apps
- the web page: the **Switch app** card (Fish Tank: above System; Deer Hunt: above Maintenance)
- the screen: press **BOOT** for the info screen and tap **Switch to ...**
- the BOOT button: **hold it for 2 seconds**, any time

**No OTA.** The ElegantOTA `/update` page and ArduinoOTA are removed, because an over-the-air update could only replace the running slot and would break the pairing. Every install or update is a USB flash of the merged image, which is what the web installer writes at offset `0x0`.

**Settings.** WiFi networks are shared (same TouchWifiProvisioner version and NVS layout), so a switch comes back online by itself. Everything else (volume, time zone, alarm) is kept per app. **Both apps answer to `http://huntfish.local`** on every board (the default hostname; only one app runs at a time, so there is no clash). After a switch the web page reloads at the board's IP address. If you rename a board on Fish Tank's web page, that name applies to Fish Tank only.

## Builds
`pio run -e <app>-<board>` with app `fish` or `deer`, board `freenove4`, `freenove28`, `cyd28`, `cyd28usb2`. `tools/build_combo.sh [board ...]` builds both apps on greyhound and merges them into `dist/`; it also copies each image to `docs/firmware/fishtank-deerhunt-<board>.bin` for the web installer, so commit and push `docs/firmware/` after a rebuild. Partitions: `partitions_16MB.csv` (2 x 3 MB) for the Freenove boards, `partitions_4MB.csv` (2 x 1.94 MB) for the CYDs. The CYD apps use 83-87% of their slot.

## Layout
`docs/`: the web installer (GitHub Pages, esptool-js) and the four merged images. `apps/fishtank`, `apps/deerhunt`: the two apps, copied from their repos with OTA removed and the switch added. `apps/common/combo.*`: the switch (`esp_ota_set_boot_partition`, refuses if the other slot is empty). Fixes made in either upstream repo have to be copied across by hand.

## Status
All four boards build for both apps and merge. Tried on a Freenove 2.8": the flash, the BOOT-hold switch and the shared WiFi work. Not yet tried on hardware: switching back, the web and on-screen switch buttons, the Freenove 4.0" and both CYDs.
