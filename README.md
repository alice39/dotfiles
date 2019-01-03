# EyeDevelop's DotFiles
![Some image of dotfiles I found](img/dotfiles.png)

## Installation
### Dependencies
This script assumes the following is installed:
* git
* zsh:
  * zsh
  * python (2 or 3)
* i3:
  * i3-gaps
  * polybar
  * rofi
  * fehbg
* neofetch (optional)

### Submodules
Please initialise the submodules before executing the installer.
```bash
git submodule update --init --recursive
```

### Actual installing! (yay)
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