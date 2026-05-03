#!/bin/bash

export HOST_WIFI_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2) 
export HOST_WIFI_PWD=$(sudo nmcli -s -g 802-11-wireless-security.psk connection show "${HOST_WIFI_SSID}")
export HOST_ROOT_PWD="root"
echo -e "\e[1;32m[ info ]\e[0m Exported Root  password: ${HOST_ROOT_PWD}"
echo -e "\e[1;32m[ info ]\e[0m Exported host wifi ssid: ${HOST_WIFI_SSID}"
echo -e "\e[1;32m[ info ]\e[0m Exported host wifi  pwd: ${HOST_WIFI_PWD}"
