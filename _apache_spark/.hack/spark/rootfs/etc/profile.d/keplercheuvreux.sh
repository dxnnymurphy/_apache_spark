if [ -d ~/.danny/etc/profile.d ]; then
    for i in ~/.danny/etc/profile.d/*.sh; do
        if [ -r "$i" ]; then
            if [ "${-#*i}" != "$-" ]; then 
                . "$i"
            else
                . "$i" >/dev/null
            fi
        fi
    done
    unset i
fi
