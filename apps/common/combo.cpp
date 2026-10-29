#include "combo.h"
#include <esp_ota_ops.h>
#include <esp_partition.h>

static const esp_partition_t *otherSlot() { return esp_ota_get_next_update_partition(nullptr); }

bool comboOtherInstalled() {
  const esp_partition_t *p = otherSlot();
  uint8_t magic = 0;
  return p && esp_partition_read(p, 0, &magic, 1) == ESP_OK && magic == 0xE9;   // 0xE9 starts every ESP32 app image
}

bool comboSwitch() {
  const esp_partition_t *p = otherSlot();
  return p && comboOtherInstalled() && esp_ota_set_boot_partition(p) == ESP_OK;
}
