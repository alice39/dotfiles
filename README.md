# A.L.I.C.E's DotFiles
![Some image of dotfiles I found](img/dotfiles.png)

## Installation
### Dependencies
This script will install all the dependencies it needs.
Do make sure yay is installed, otherwise these packages
cannot be installed.

### Actual installing!
**Warning:** Please look at the code before you execute blindly.

The helper install script:
```bash
./install.py --help
```

To install all the dotfiles in the user's home directory:
```bash
./install.py -d ~/ -m all
```

You can look at what can be installed by looking in the 'installers' folder.

## Updating
> "Because re-installation sucks."

**Same warning applies as listed above.**

Just use the Update helper script.
```bash
./update.py --help
```

To update all the dotfiles in the user's home directory:
```bash
./update.py -d ~/ -m all
```

As you can see, the update helper uses the exact same syntax as the installer.
