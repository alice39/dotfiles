import json
import os
import shutil

from config import BASE_DIR, logger


def scan_for_installers(dot_install_dir):
    installers = {}

    # Scan for every json file in 'installers'
    for installer in os.listdir(os.path.join(BASE_DIR, "installers")):
        if installer.endswith(".json"):
            with open(os.path.join(BASE_DIR, "installers", installer), "rt") as installer_fp:
                # Replace the {DOT_INSTALL_DIR}
                file_contents = installer_fp.read()
                file_contents = file_contents.replace("{DOT_INSTALL_DIR}", dot_install_dir)

                try:
                    # Add the install data to installers.
                    data = json.loads(file_contents)
                    name = installer[:-5]
                    if "module_name" in data.keys():
                        name = data["module_name"]

                    installers[name] = data
                except json.JSONDecodeError:  # It was not a valid json file.
                    logger.warn("{} is not a valid installer!".format(installer))

    return installers


def get_config(config_dir, config_file=None):
    options = [BASE_DIR, "config", config_dir, config_file]
    options = [x for x in options if x is not None]
    return os.path.join(*options)


def symlink(src, dst, is_directory=False):
    install_folder = "/".join(dst.split("/")[:-1])
    os.makedirs(install_folder, 0o755, exist_ok=True)

    # Remove file if it already exists
    if os.path.lexists(dst):
        logger.warn("{} exists. Deleting...".format(dst))

        if not os.path.isdir(dst) or os.path.islink(dst):
            os.remove(dst)
        else:
            shutil.rmtree(dst)

    logger.debug("Symlinking {} to {}.".format(src, dst))
    os.symlink(src, dst, target_is_directory=is_directory)
