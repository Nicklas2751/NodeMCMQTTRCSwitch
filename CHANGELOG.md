# Version v1.1.0

## Improved usability

The script saves now the device codes in the config and listens to pseudo codes consisting of the device number and the state. 
Like `10` for the first device `1` and the state off `0`. It also listens for other commands like `restart`which restarts the NodeMCU.
If the device gets an command which is unkown it logs help text with all codes and commands.

# Version v1.0.0

## First stable version 1.0.0.

The script sends directly the recived codes.
