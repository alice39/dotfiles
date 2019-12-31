function update-mirrors --description "Fetch the latest HTTPS mirrors of a country and rank them by speed."
    set --local options 'n/mirrornum=!_validate_int --min 1' 'c/countries'
    argparse $options -- $argv

    if not count $argv >/dev/null
        echo "No arguments are specified."
        echo "Usage: update_mirrors [-n|--mirrornum <amount of mirrors>] [<countries...>]"
        return 1
    end

    set --local mirror_url "https://www.archlinux.org/mirrorlist/?protocol=https&use_mirror_status=on"
    for country in $argv
        set mirror_url "$mirror_url&country=$country"
    end

    echo "Fetching mirrors with $mirror_url"

    echo "Found these mirrors:"
    curl -Ls $mirror_url | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n $_flag_mirrornum - | sudo tee /etc/pacman.d/mirrorlist
end
