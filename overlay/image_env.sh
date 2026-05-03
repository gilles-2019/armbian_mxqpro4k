#!/bin/bash
echo -e "\e[1;32m[ info ]\e[0m ** EXECUTING OVERLAY FILE IMAGE_ENV.SH **"
export ROOT_PWD="$HOST_ROOT_PWD"
export WIFI_SSID="$HOST_WIFI_SSID"
export WIFI_PWD="$HOST_WIFI_PWD"
echo -e "\e[1;32m[ info ]\e[0m Imported Root password: ${ROOT_PWD}"
echo -e "\e[1;32m[ info ]\e[0m Imported Wifi ssid: ${HOST_WIFI_SSID}"
echo -e "\e[1;32m[ info ]\e[0m Imported Wifi  pwd: ${HOST_WIFI_PWD}"

