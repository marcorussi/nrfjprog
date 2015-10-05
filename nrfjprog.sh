#!/bin/bash

read -d '' USAGE <<- EOF
nrfprog.sh

This is a loose shell port of the nrfjprog.exe program distributed by Nordic,
which relies on JLinkExe to interface with the JLink hardware.

usage:

nrfjprog.sh <action> [hexfile]

where action is one of
  --reset
  --pin-reset
  --erase-all
  --flash
  --write
  --debug
  --flash-softdevice
  --rtt

EOF

TOOLCHAIN_PREFIX=arm-none-eabi
# assume the tools are on the system path
TOOLCHAIN_PATH=
JLINK_PATH="/opt/JLink_Linux_V502d_x86_64"
JLINK_OPTIONS="-device nrf51422 -if swd -speed 1000"

HEX=$2

JLINK="$JLINK_PATH/JLinkExe $JLINK_OPTIONS"
JLINKGDBSERVER="$JLINK_PATH/JLinkGDBServer $JLINK_OPTIONS"

if [ "$1" != "--debug" ]; then
    TMPSCRIPT=/tmp/tmp_$$.jlink
fi

if [ "$1" = "--reset" ]; then
    echo ""
    echo -e "Resetting..."
    echo ""
    echo "r" > $TMPSCRIPT
    echo "g" >> $TMPSCRIPT
    echo "exit" >> $TMPSCRIPT
    $JLINK $TMPSCRIPT
    rm $TMPSCRIPT
elif [ "$1" = "--pin-reset" ]; then
    echo ""
    echo -e "Resetting with pin..."
    echo ""
    echo "w4 40000544 1" > $TMPSCRIPT
    echo "r" >> $TMPSCRIPT
    echo "exit" >> $TMPSCRIPT
    $JLINK $TMPSCRIPT
    rm $TMPSCRIPT
elif [ "$1" = "--erase-all" ]; then
    echo ""
    echo -e "Perfoming full erase..."
    echo ""
    echo "w4 4001e504 2" > $TMPSCRIPT
    echo "w4 4001e50c 1" >> $TMPSCRIPT
    echo "sleep 100" >> $TMPSCRIPT
    echo "r" >> $TMPSCRIPT
    echo "exit" >> $TMPSCRIPT
    $JLINK $TMPSCRIPT
    rm $TMPSCRIPT
elif [ "$1" = "--flash" ]; then
    echo ""
    echo -e "Flashing ${HEX}..."
    echo ""
    echo "r" > $TMPSCRIPT
    echo "loadfile $HEX" >> $TMPSCRIPT
    echo "r" >> $TMPSCRIPT
    echo "g" >> $TMPSCRIPT
    echo "exit" >> $TMPSCRIPT
    $JLINK $TMPSCRIPT
    rm $TMPSCRIPT
elif [ "$1" = "--write" ]; then
    echo ""
    echo -e "Writing memory register..."
    echo ""
    echo "halt" > $TMPSCRIPT
    echo "w4 4001e504 1" >> $TMPSCRIPT
    echo "sleep 100" >> $TMPSCRIPT
    echo "w4 $2 $3" >> $TMPSCRIPT
    echo "sleep 100" >> $TMPSCRIPT
    echo "r" >> $TMPSCRIPT
    echo "exit" >> $TMPSCRIPT
    $JLINK $TMPSCRIPT
    rm $TMPSCRIPT
elif [ "$1" = "--debug" ]; then
    echo ""
    echo -e "Debugging init..."
    echo ""
    $JLINKGDBSERVER
elif [ "$1" = "--flash-softdevice" ]; then
    echo ""
    echo -e "Flashing softdevice ${HEX}..."
    echo ""
    # Write to NVMC to enable erase, do erase all, wait for completion. reset
    echo "w4 4001e504 2" > $TMPSCRIPT
    echo "w4 4001e50c 1" >> $TMPSCRIPT
    echo "sleep 100" >> $TMPSCRIPT
    echo "r" >> $TMPSCRIPT
    # Write to NVMC to enable write. Write mainpart, write UICR. Assumes device is erased.
    echo "w4 4001e504 1" > $TMPSCRIPT
    echo "loadfile $HEX" >> $TMPSCRIPT
    echo "r" >> $TMPSCRIPT
    echo "g" >> $TMPSCRIPT
    echo "exit" >> $TMPSCRIPT
    $JLINK $TMPSCRIPT
    rm $TMPSCRIPT
elif [ "$1" = "--rtt" ]; then
    # trap the SIGINT signal so we can clean up if the user CTRL-C's out of the
    # RTT client
    trap ctrl_c INT
    function ctrl_c() {
        return
    }
    echo -e "Starting RTT Server..."
    $JLINK &
    JLINK_PID=$!
    sleep 1
    echo -e "\nConnecting to RTT Server..."
    #telnet localhost 19021
    $JLINK_PATH/JLinkRTTClient
    echo -e "\nKilling RTT server ($JLINK_PID)..."
    kill $JLINK_PID
else
    echo "$USAGE"
fi
