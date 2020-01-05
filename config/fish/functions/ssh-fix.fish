function ssh-fix --description "Fixes the xterm-<terminal> being unknown."
    set --local options 's/system-wide'
    argparse $options -- $argv

    if test (count $argv) -lt 1
        echo "Usage: ssh-fix [-s|--system-wide] <ssh server>"
        return 1
    end

    set --local sudo_txt ""
    if set --query _flag_s
        echo "Enabling system wide... You need sudo for this on the SSH server."
        set sudo_txt "sudo"
    end

    stty -echo
    infocmp $TERM | ssh $argv "cat > ~/.terminfo_$TERM"
    ssh -tt $argv "$sudo_txt tic -x ~/.terminfo_$TERM"
    echo "Done!"
    stty echo
end
