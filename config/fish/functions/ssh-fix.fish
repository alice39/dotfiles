function ssh-fix --description "Fixes the xterm-kitty being unknown."
    if test (count $argv) -lt 1
        echo "Specify the SSH args please."
        return 1
    end

    infocmp xterm-kitty | ssh $argv tic -x -o \~/.terminfo /dev/stdin
    echo "Done!"
end
