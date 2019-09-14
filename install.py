#!/usr/bin/env python3
import getopt
import logging
import os
import sys

import helpers
from config import logger
from install_module import install_module

__author__ = "EyeDevelop"


def print_help():
    print(
        "DotFiles Installer Help:\n\n"
        "-h or --help: This page.\n"
        "-d or --installdir: Sets the installation directory.\n"
        "-m or --modules: The modules to be installed. (from 'installers' dir)\n"
        "-v or --verbose: Verbose mode.\n"
    )
    print("IMPORTANT: Installation directory has to be set before modules are picked.")
    print("\nExample:\n"
          "Installs all modules in the home directory:\n"
          "./install.py -d ~/ -m all\n")
    exit(0)


def main():
    # Check for command line arguments
    # d: install_dir: {DOT_INSTALL_DIR}
    # v: verbose
    # h: help
    install_dir = None
    modules = None

    try:
        options, _ = getopt.getopt(sys.argv[1:], "d:vhm:", ["installdir=", "help", "verbose", "modules="])
    except getopt.GetoptError as err:
        print(err)
        print("Please see the help (--help).")
        exit(1)

    # Parse the command line arguments.
    for option, argument in options:
        if option in ("-v", "--verbose"):
            logger.setLevel(logging.DEBUG)
            for handler in logger.handlers:
                handler.setLevel(logging.DEBUG)
        elif option in ("-h", "--help"):
            print_help()
            exit(0)
        elif option in ("-d", "--installdir"):
            install_dir = os.path.abspath(argument)
        elif option in ("-m", "--modules"):
            if argument.lower() == "all":
                modules = list(helpers.scan_for_installers(install_dir).keys())
            else:
                modules = argument.split(",")
        else:
            assert False, "Unknown option {}.".format(option)

    if not install_dir:
        logger.fatal("Installation directory not provided. Not installing.")
        exit(1)

    if not modules or len(modules) < 1:
        logger.fatal("No modules selected.")
        exit(1)

    # Get all available modules for installation.
    available_modules = helpers.scan_for_installers(install_dir)

    # Remove the dependency modules from the list so they don't get installed twice.
    dependency_modules = []
    for module in modules:
        if "depends" in available_modules[module].keys():
            for dependency in available_modules[module]["depends"]:
                dependency_modules.append(dependency)

    for module in dependency_modules:
        if module in modules:
            modules.remove(module)

    logger.debug("Installation directory: {}".format(install_dir))

    for module in modules:
        try:
            install_module(module, install_dir, available_modules)
        except Exception as e:
            logger.error("Failed to install {}\n    {}".format(module, e))

    print("\nAll done installing!")


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        logger.fatal(e)
        exit(1)
    except KeyboardInterrupt:
        exit(1)
