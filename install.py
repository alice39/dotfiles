#!/usr/bin/env python3
import logging
import os
import getopt
import sys

from config import logger
import helpers

__author__ = "EyeDevelop"


def install_module(module_name, dot_install_dir, available_modules, is_dependency=False):
    # Cannot install a module if it doesn't have an installer.
    if module_name not in available_modules.keys():
        logger.error("{} is not installable.".format(module_name))
        return False

    module = available_modules[module_name]

    dependency_str = " dependency" if is_dependency else ""
    logger.info("Installing{}: {}".format(dependency_str, module_name))

    # Install the module's dependencies first (if any).
    logger.debug("Found dependencies for {}.".format(module_name))
    if len(module["depends"]) > 0:
        for dependency in module["depends"]:
            if not install_module(dependency, dot_install_dir, available_modules, is_dependency=True):
                logger.critical("{} could not install dependency {}.".format(module_name, dependency))

    # Check if the entire directory can be installed.
    if "install_dir" in module.keys():
        install_dir = module["install_dir"]
        logger.debug("[{}] Installing entire directory to {}.".format(module_name, install_dir))

        source_dir = helpers.get_config(module["config_dir"])
        helpers.symlink(source_dir, install_dir, is_directory=True)
    else:
        for config_file in module["config_files"]:
            install_location = module["config_files"][config_file]
            logger.debug("[{}] Installing {} to {}.".format(module_name, config_file, install_location))

            source_file = helpers.get_config(module["config_dir"], config_file)
            helpers.symlink(source_file, install_location)

    # Module has been successfully installed.
    return True


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
          "./install.py -d /home/user -m all\n")
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
        for dependency in available_modules[module]["depends"]:
            dependency_modules.append(dependency)

    for module in dependency_modules:
        modules.remove(module)

    logger.debug("Installation directory: {}".format(install_dir))

    for module in modules:
        try:
            install_module(module, install_dir, available_modules)
        except Exception as e:
            logger.error("Failed to install {}\n    {}".format(module, e))


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        logger.fatal(e)
        exit(1)
    except KeyboardInterrupt:
        exit(1)
