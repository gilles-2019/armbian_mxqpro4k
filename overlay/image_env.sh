export HOST_WIFI_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2) 
export HOST_WIFI_PWD=$(sudo nmcli -s -g 802-11-wireless-security.psk connection show "${HOST_WIFI_SSID}")
echo "host wifi ssid: ${HOST_WIFI_SSID}"
echo "host wifi  pwd: ${HOST_WIFI_PWD}"
export ROOT_PWD="root"
export WIFI_SSID="$HOST_WIFI_SSID"
export WIFI_PWD="$HOST_WIFI_PWD"
