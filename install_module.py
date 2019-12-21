import os
import subprocess

import helpers
from config import logger, BASE_DIR


def install_module(module_name, dot_install_dir, available_modules, is_dependency=False, install_dependencies=True):
    # Cannot install a module if it doesn't have an installer.
    if module_name not in available_modules.keys() and module_name.split(":")[0] not in ["package", "packages"]:
        logger.error("{} is not installable.".format(module_name))
        return False

    if module_name.split(":")[0] not in ["package", "packages"]:
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
    if install_dependencies:
        if "depends" in module.keys():
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
    elif "config_files" in module.keys():
        for config_file in module["config_files"]:
            install_location = module["config_files"][config_file]
            logger.debug("[{}] Installing {} to {}.".format(module_name, config_file, install_location))

            source_file = helpers.get_config(module["config_dir"], config_file)
            helpers.symlink(source_file, install_location)
    else:
        logger.debug("[{}]: No config files to install.".format(module_name))

    # Module has been successfully installed.
    return True


def install_sh_module(module_name, dot_install_dir, available_sh_modules, is_dependency):
    # Cannot install a module if it doesn't have an installer.
    if module_name not in available_sh_modules.keys():
        logger.error("{} is not installable.".format(module_name))
        return False

    module = available_sh_modules[module_name]

    dependency_str = " dependency" if is_dependency else ""
    logger.info("SH: Installing{} {}".format(dependency_str, module_name))

    # Try to run the installer script.
    working_directory = os.path.join(BASE_DIR, module["working_dir"])
    proc_args = " ".join([module["installer"], *module["arguments"].split()])

    # Ask user for consent.
    print()
    print("!!! YOU ARE ABOUT TO RUN A SHELL SCRIPT !!!")
    print("Please review the contents of this script carefully before continuing.")
    print("The script: [{}] {}".format(module["working_dir"], module["installer"]))
    no_consent = input("Would you like to continue [Y/n]: ").lower() == "n"

    if no_consent:
        logger.fatal("User skipped execution of shell script.")
        return True

    # Run the installer script.
    try:
        print("\nOutput:")
        rc = subprocess.call(
            proc_args.split(),
            cwd=working_directory
        )
        if rc != 0:
            raise Exception("Process exited non-zero.")
        print()
    except Exception as err:
        logger.error("SH script ran into an error! Please fix the error and reinstall the module.")
        logger.error(err)

    # Module is installed successfully.
    return True


def install_package_module(module_name, dot_install_dir, available_modules, is_dependency=True):
    """
    Installs a package from the package manager. Defaults to using yay.

    :param module_name: The package to install.
    :param dot_install_dir: N.A
    :param available_modules: N.A
    :param is_dependency: Whether the package is a dependency or not.
    :return: Whether the package is installed successfully.
    """

    package_name = module_name.split(":")[1]

    dependency_str = " dependency" if is_dependency else ""
    logger.info("PACKAGE: installing{} {}".format(dependency_str, package_name))

    working_directory = BASE_DIR
    proc_args = f"yay -S --needed {package_name}"

    # Install the package.
    try:
        rc = subprocess.call(
            proc_args.split(),
            cwd=working_directory,
        )
        if rc != 0:
            raise Exception("Process exited non-zero.")
        print()
    except Exception as err:
        logger.error("Cannot install package. Please fix the error manually and run again.")
        logger.error(err)

    return True


def install_packages(module_name, dot_install_dir, available_modules, is_dependency):
    """
    Simple helper to install multiple packages at once.

    :param module_name: The list of packages to install.
    :param dot_install_dir: N.A
    :param available_modules: N.A
    :param is_dependency: N.A
    :return: Whether the packages installed.
    """

    packages_to_install = module_name.split(":")[1].split()

    logger.info("PACKAGES: Installing {}".format(", ".join(packages_to_install)))

    working_directory = BASE_DIR
    proc_args = "yay -S --needed {}".format(" ".join(packages_to_install))

    # Install the packages.
    try:
        rc = subprocess.call(
            proc_args.split(),
            cwd=working_directory
        )
        if rc != 0:
            raise Exception("Process exited non-zero.")
        print()
    except Exception as err:
        logger.error("Failed to install packages. Please fix manually and try again.")
        logger.error(err)

    return True


installer_map = {
    "sh": install_sh_module,
    "package": install_package_module,
    "packages": install_packages,
}
