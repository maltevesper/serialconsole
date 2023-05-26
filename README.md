# serial_console

A simple serial console emulator. The primary goal is to have a powerful and intuitive ui, while keeping as much power of pure terminal based programs as possible.

# Installation

## Ubuntu

Dependencies: libserialport.so
Permissions: to access serial devices

```
# check `ls -ld /dev/ttyYouWantToConnect` for the group you need to have (Ubuntu has dialout)
sudo usermod -a -G dialout $USER
# need to reboot to apply (relogging might not be enough)
```

```
sudo apt-get install -y libserialport-dev
```

# TODO:

 but in case you are building a Flutter app instead of a pure Dart app, there is a ready-made drop-in solution called flutter_libserialport that utilizes Flutter's build system to build and deploy libserialport on all supported platforms: