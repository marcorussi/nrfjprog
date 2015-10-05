# nrfjprog
Shell port of the nrfjprog.exe program distributed by Nordic. 
Thanks to ssfrr. Go to https://github.com/ssfrr/nrfjprog.sh for the original repository.

Changes:

Added following functionalities:
 * write 4 bytes to a flash memory address
 * launch JLink GDB server for debugging with GDB

Usage:

```
nrfjprog.sh <action> [<params>]
```

where action and params are one row of these:
 * `--reset`
 * `--pin-reset`
 * `--erase-all`
 * `--flash <hexfile>`
 * `--flash-softdevice <hexfile>`
 * `--write <address_hex> <value_hex>`
 * `--debug <outfile>`
 * `--rtt`

ATTENTION: RTT functionality has not been well tested.
