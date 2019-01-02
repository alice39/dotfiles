import os
import subprocess
import threading
import queue

from config import BASE_DIR


class Process:
    def __init__(self, command_to_run, working_directory):
        self.return_code = None
        self.process = None
        self.reading = True
        self.read_queue = queue.Queue()

        # Start the process
        with open(os.path.join(BASE_DIR, "process_output.log"), "wb") as fp:
            self.process = subprocess.Popen(
                args=command_to_run,
                cwd=working_directory,
                shell=True,
                stdin=subprocess.PIPE,
                stdout=fp,
                stderr=subprocess.STDOUT,
            )

        # Create a thread to continuously print output of the program.
        read_thread = threading.Thread(target=self.__read_output)
        read_thread.start()

        # Check if the program has exited and put the output in a reading queue.
        while True:
            if self.process.poll() is None:
                command = input().encode("utf-8")
                self.process.communicate(input=command)
            else:
                self.return_code = self.process.poll()
                self.reading = False
                break

        read_thread.join()

    def __read_output(self):
        with open(os.path.join(BASE_DIR, "process_output.log"), "rt") as fp:
            while self.reading:
                text = fp.read()
                if text:
                    print(text)
