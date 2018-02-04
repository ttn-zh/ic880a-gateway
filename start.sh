#! /bin/bash

# Reset iC880a PIN
SX1301_RESET_BCM_PIN=25
echo "$SX1301_RESET_BCM_PIN"  > /sys/class/gpio/export 
echo "out" > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/direction 
echo "0"   > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value 
sleep 0.1  
echo "1"   > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value 
sleep 0.1  
echo "0"   > /sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value
sleep 0.1
echo "$SX1301_RESET_BCM_PIN"  > /sys/class/gpio/unexport 

# Test the connection, wait if needed.
while [[ $(ping -c1 google.com 2>&1 | grep " 0% packet loss") == "" ]]; do
  echo "[TTN Gateway]: Waiting for internet connection..."
  sleep 30
  done

# If there's a remote config, try to update it
if [ -d ../gateway-remote-config ]; then
    # First pull from the repo
    pushd ../gateway-remote-config/
    git pull
    git reset --hard
    popd

    # And then try to refresh the gateway EUI and re-link local_conf.json

    # Same network interface name detection as on install.sh
    # Get first non-loopback network device that is currently connected
    GATEWAY_EUI_NIC=$(ip -oneline link show up 2>&1 | grep -v LOOPBACK | sed -E 's/^[0-9]+: ([0-9a-z]+): .*/\1/' | head -1)
    if [[ -z $GATEWAY_EUI_NIC ]]; then
      echo "ERROR: No network interface found. Cannot set gateway ID."
      exit 1
    fi

    # Then get EUI based on the MAC address of that device
    GATEWAY_EUI=$(cat /sys/class/net/$GATEWAY_EUI_NIC/address | awk -F\: '{print $1$2$3"FFFE"$4$5$6}')
    GATEWAY_EUI=${GATEWAY_EUI^^} # toupper

    echo "[TTN Gateway]: Use Gateway EUI $GATEWAY_EUI based on $GATEWAY_EUI_NIC"
    INSTALL_DIR="/opt/ttn-gateway"
    LOCAL_CONFIG_FILE=$INSTALL_DIR/bin/local_conf.json

    if [ -e $LOCAL_CONFIG_FILE ]; then rm $LOCAL_CONFIG_FILE; fi;
    ln -s $INSTALL_DIR/gateway-remote-config/$GATEWAY_EUI.json $LOCAL_CONFIG_FILE

fi

# Fire up the forwarder.
./poly_pkt_fwd
