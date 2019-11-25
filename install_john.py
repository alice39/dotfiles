import os
import shutil

def copy(src: str, dest: str):
    if os.path.isfile(dest):
        return 
    with open(src, 'rb') as src_file:
        with open(dest, 'ab') as dest_file:
            dest_file.write(src_file.read())

copy("./fish/lock.fish", f"{os.path.expanduser('~')}/.config/fish/functions/lock.fish")
copy("./fish/wake_pc.fish", f"{os.path.expanduser('~')}/.config/fish/functions/wake_pc.fish")
shutil.copytree("./locker", f"{os.path.expanduser('~')}/.locker")