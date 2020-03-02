import os
import git

def get_git_root():
    try:
        git_repo = git.Repo(os.getcwd(), search_parent_directories=True)
        git_root = git_repo.git.rev_parse("--show-superproject-working-tree") or git_repo.git.rev_parse("--show-toplevel")
        return git_root
    except git.exc.InvalidGitRepositoryError as e:
        print("Invalid git repository:", e)
        exit(-1)

def main():
    os.chdir(get_git_root())
    if not os.path.isfile("CMakeLists.txt"):
        print("Not a CMake project, exiting")
        exit(-1)
    if not os.path.isdir("build"):
        os.mkdir("build")
    os.chdir("build")

    os.system("cmake .. -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_CXX_COMPILER=/usr/bin/clang++")
    os.system("cmake --build . -- -j $(nproc)")


if __name__ == "__main__":
    main()
