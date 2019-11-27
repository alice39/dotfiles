function transfer --description "Automatically uploads files to transfer.sh and returns the link(s)."
    set --local options 'r/recursive'
    argparse $options -- $argv

    if not count $argv >/dev/null
        echo -e "No arguments are specified. Usage:\ntransfer [-r|--recursive] [<filename>..]"
        return 1
    end

    for file in $argv
        if set --query _flag_recursive; and test -d $file
            echo "--  Recursing into directory $file..."
            transfer -r $file/*
        else if test -d $file
            echo "--  Ignoring directory $file..."
        end

        if test -f $file
            set --local basename (echo $file | rev | cut -d "/" -f1 | rev)
            set --local tempfile (mktemp -t transfershXXXX)

            curl --progress-bar --upload-file $file "https://transfer.sh/$basename" > $tempfile
            cat $tempfile
            rm -f $tempfile
        end
    end
end
