# nrfjprog
Shell port of the nrfjprog.exe program distributed by Nordic. 
Thanks to ssfrr. Go to https://github.com/ssfrr/nrfjprog.sh for the original repository.

Changes:

Added following functionalities:
 * write 4 bytes to a flash memory address
 * launch JLink GDB server for debugging with GDB

Usage:

```
nrfjprog.sh <action> [hexfile]
```

where action is one of:
 * `--reset`
 * `--pin-reset`
 * `--erase-all`
 * `--flash`
 * `--flash-softdevice`
 * `--write`
 * `--debug`
 * `--rtt`

ATTENTION: RTT functionality has not been well tested.
