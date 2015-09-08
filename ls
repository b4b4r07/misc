#!/bin/bash

. "$DOTPATH"/etc/lib/vital.sh

search_ls() {
    local p
    p="$PATH:"

    local ls_path

    while [ -n "$p" ]; do
        # the first remaining entry
        x="${p%%:*}"
        # reset p
        p="${p#*:}"

        if [ -x "$x/ls" ]; then
            # Skip this ls command
            file "$x/ls" | grep -vq "text"
            if [ $? -eq 0 ]; then
                ls_path="$x/ls"
            fi
        else
            continue
        fi
    done

    # Set gls if exists
    if is_gls; then
        ls_path="gls"
    fi

    # Return ls path
    echo "$ls_path"
}

main() {
    # find ls path
    {
        local ls_path
        ls_path="$(search_ls)"

        if [ -z "$ls_path" ]; then
            echo "ls: not found in the PATH" 1>&2
            return 1
        fi
    }

    # Add ls options
    {
        local ls_option

        # initialize ls_option with a zero string
        ls_option=""

        # color option
        if is_linux || is_gls; then
            ls_option="${ls_option} --color=always"
        elif is_osx; then
            ls_option="${ls_option} -G"
        fi

        # identifier option
        ls_option="${ls_option} -F"

        if is_gls; then
            # grouping option
            ls_option="${ls_option} --group-directories-first"
            # human readable
            ls_option="${ls_option} --human-readable"
        fi
    }
    # run ls
    eval "$ls_path" "$ls_option" "$@"
    return $?
}

is_gls() {
    # a temporary PATH value
    local p
    p="$PATH:"

    # The case that GNU ls command name is gls
    if has "gls"; then
        gls --version 2>/dev/null | grep -iq "GNU"
        if [ $? -eq 0 ]; then
            return 0
        fi
    fi

    # The case that GNU ls command name is ls
    while [ -n "$p" ]; do
        # the first remaining entry
        x="${p%%:*}"
        # reset p
        p="${p#*:}"

        # find GNU ls command aliased to ls
        if [ -x "$x/ls" ]; then
            eval "$x/ls" --version 2>/dev/null | grep -iq "GNU"
            return $?
        else
            continue
        fi
    done

    # GNU ls doesn't found in the PATH
    return 1
}

main "$@"
