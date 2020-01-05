function transfer-get --description "Gets the file from transfer.sh using the url."
    set --local options 'o/output='
    argparse $options -- $argv

    if not count $argv >/dev/null
        echo -e "No url specified. Usage:\ntransfer_get [-o|--output output_dir] [<url>..]"
        return 1
    end

    set --query _flag_o; or set --local _flag_o ./
    set --local previous_dir (pwd)
    cd $_flag_o

    if not test -d $_flag_o
        mkdir -p $_flag_o; or exit 1
    end

    for url in $argv
        curl -OL $url >/dev/null 2>&1
        set --local basename (echo $url | rev | cut -d "/" -f1 | rev)
        echo "Downloaded $_flag_o/$basename"
    end

    cd $previous_dir
end
