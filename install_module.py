import os
import sys

import helper_classes
import helpers
import subprocess
from config import logger, BASE_DIR


def install_module(module_name, dot_install_dir, available_modules, is_dependency=False):
    # Cannot install a module if it doesn't have an installer.
    if module_name not in available_modules.keys():
        logger.error("{} is not installable.".format(module_name))
        return False

    module = available_modules[module_name]

    # Check if the module needs an alternate installer function.
    name_split = module_name.split(":")
    if len(name_split) > 1:
        if name_split[0] not in installer_map.keys():
            logger.critical("Installer for {} not found.".format(module_name))
            return False

        installer = installer_map[name_split[0]]
        return installer(module_name, dot_install_dir, available_modules, is_dependency)

    dependency_str = " dependency" if is_dependency else ""
    logger.info("Installing{}: {}".format(dependency_str, module_name))

    # Install the module's dependencies first (if any).
    logger.debug("Found dependencies for {}.".format(module_name))
    if len(module["depends"]) > 0:
        for dependency in module["depends"]:
            if not install_module(dependency, dot_install_dir, available_modules, is_dependency=True):
                logger.critical("{} could not install dependency {}.".format(module_name, dependency))
                return False

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


def install_sh_module(module_name, dot_install_dir, available_sh_modules, is_dependency):
    # Cannot install a module if it doesn't have an installer.
    if module_name not in available_sh_modules.keys():
        logger.error("{} is not installable.".format(module_name))
        return False

    module = available_sh_modules[module_name]

    dependency_str = " dependency" if is_dependency else ""
    logger.info("Installing SH{}: {}".format(dependency_str, module_name))

    # Try to run the installer script.
    working_directory = os.path.join(BASE_DIR, module["working_dir"])
    proc_args = " ".join([module["installer"], *module["arguments"].split()])

    # Ask user for consent.
    print("!!! YOU ARE ABOUT TO RUN A SHELL SCRIPT !!!")
    print("Please review the contents of this script carefully before continuing.")
    print("The script: [{}] {}".format(module["working_dir"], module["installer"]))
    consent = input("Would you like to continue [y/N]: ")
    consent = consent.lower() == "y"

    if not consent:
        logger.fatal("User gave no consent to run shell script.")
        return False

    # Run the installer script.
    try:
        print("\nSometimes the stdin buffer hangs. Press enter when the program exited.")
        print("Output:")
        proc = helper_classes.Process(
            command_to_run=proc_args,
            working_directory=working_directory,
        )
        if proc.return_code != 0:
            raise Exception("Process exited non-zero.")
        print()
    except Exception as err:
        logger.error("SH script ran into an error! Please fix the error and reinstall the module.")
        logger.error(err)

    # Module is installed successfully.
    return True


installer_map = {
    "sh": install_sh_module
}
