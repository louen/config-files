# Debian-bootstrap

How to start from a freshly installed debian netinst to a usable system using the files in this repository.


### Ethernet 
```
#> dhclient -v eth0
```

### Wifi with wpa_supplicant

This will work for a home network with wpa2-psk. Else `man wpa_supplicant.conf`.


Edit this file with `#> vi /etc/wpa_supplicant/home.conf`, filling `<$SSID>` and `<$PASSWORD>`
```
network={
  ssid="<$SSID>"
  scan_ssid=1
  key_mgmt=WPA-PSK
  psk="<$PASSWORD>"
}
```

Run wpa-supplicant on `wlan 0`(`-i`) on verbose mode (`-d`) using your config file (`-c /etc/wpa_supplicant/home.conf`) and make it a daemon running in background (`-B`)
```
#> wpa_supplicant -i wlan0 -d -c home.conf -B 
dhclient -v wlan0
```

### Install script

Grab the script from this repo and run it

```
#> cd /root
#> wget https://raw.githubusercontent.com/louen/config-files/master/linux/script_install.sh
#> bash script_install.sh
```
