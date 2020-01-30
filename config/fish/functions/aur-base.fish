function aur-base --description "Initialises a directory for AUR PKGBUILD creation."
    if test (count $argv) -lt 1
        echo "Please specify a package name."
        return 1
    end

    set --local pkgname "$argv[1]"
    if test -d "$pkgname"; and test -f "$pkgname/PKGBUILD"
        echo "-- Existing PKGBUILD found. Initialising repo..."
        cd "$pkgname"
        makepkg --printsrcinfo > .SRCINFO
        git init
        git remote add origin "ssh://aur@aur.archlinux.org/$pkgname"
        git fetch
    else
        echo "-- Cloning repository..."
        git clone "ssh://aur@aur.archlinux.org/$pkgname"
    end

    cd "$pkgname"
    git config user.name "Hans Goor"
    git config user.email "me@eyedevelop.org"
end
