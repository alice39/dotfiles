# Set BASE_DIR to the absolute path of this directory.
import logging
import os


# Setup the logging facility.
logger = logging.getLogger("DotFiles")
logger.setLevel(logging.INFO)

log_format = logging.Formatter("[%(name)s]: %(levelname)s: %(message)s")

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
console_handler.setFormatter(log_format)

logger.addHandler(console_handler)


# Set the base directory to the directory this file is located in.
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
