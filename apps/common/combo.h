// Fish Tank + Deer Hunt on one board: two app slots (ota_0 and ota_1), flashed together over USB.
// Switching just points the boot loader at the other slot and restarts. Nothing is ever written to either slot at runtime
// (there is no OTA), so a bad switch cannot damage anything.
#pragma once
#include <Arduino.h>

// COMBO_OTHER_NAME is set per app in platformio.ini ("Deer Hunt" in the Fish Tank build, and the reverse).
bool comboOtherInstalled();   // the other slot holds a real app image
bool comboSwitch();           // make the other slot the next boot (does NOT restart; the caller does)

// "Switch to ..." button on the BOOT info screen, in the 480x320 virtual world
#define COMBO_BTN_X 46
#define COMBO_BTN_W 270
#define COMBO_BTN_H 30
#define COMBO_HOLD_MS 2000    // hold BOOT this long to switch
