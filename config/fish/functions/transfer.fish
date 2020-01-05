function transfer --description "Automatically uploads files to transfer.sh and returns the link(s)."
    set --local options 'r/recursive' 'm/max-downloads=!_validate_int --min=1' 'd/max-days=!_validate_int --min 1'
    argparse $options -- $argv

    if not count $argv >/dev/null
        echo -e "No arguments are specified. Usage:\ntransfer [-r|--recursive] [-m|--max-days <num>] [-d|--max-days <num>]  [<filename>..]"
        return 1
    end

    for file in $argv
        if set --query _flag_r; and test -d $file
            echo "--  Recursing into directory $file..."
            transfer -r $file/*
        else if test -d $file
            echo "--  Ignoring directory $file..."
        end

        if set --query _flag_m
            set max_downloads "Max-Downloads: $_flag_max-downloads"
        end

        if set --query _flag_d
            set max_days "Max-Days: $_flag_max-days"
        end
        

        if test -f $file
            set --local basename (echo $file | rev | cut -d "/" -f1 | rev)
            set --local tempfile (mktemp -t transfershXXXX)

            curl --progress-bar -H $max_downloads -H $max_days --upload-file $file "https://transfer.eyedevelop.org/$basename"
            echo
        end
    end
end
