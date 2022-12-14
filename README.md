# esp-idf-env.nix
ESP32 IDF development environment manged with nix

## Usage
To enter the development environment, call it with `nix-shell`.
```shell
nix-shell ~/path/to/esp-idf-env.nix
```

### Installation
```shell
git clone --recurse-submodules https://github.com/cyber-murmel/esp-idf-env.nix.git
```

### Examples
The examples are to be executed after entering the development environment.

#### MicroPython
```shell
# get code
git clone --branch v1.19 https://github.com/micropython/micropython.git
cd micropython/
make -C mpy-cross/
make -C ports/esp32 submodules
# build
make -C ports/esp32
# set port
export ESP32_PORT=/dev/ttyUSB0
# flash
make -C ports/esp32 deploy PORT=${ESP32_PORT}
# open REPL
python -m serial.tools.miniterm --exit-char 24 --raw --dtr 0 --rts 0 ${ESP32_PORT} 115200
```
