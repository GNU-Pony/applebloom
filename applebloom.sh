#!/bin/bash
##
# applebloom – Apple Bloom the pony dictionary
# 
# Copyright © 2013  Mattias Andrée (maandree@member.fsf.org)
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

is_backend=0
if [ "$1" == "--back-end" ]; then
    is_backend=1
    shift 1
fi


dictionary=dictionary

if [ $is_backend = 0 ]; then
    export TEXTDOMAIN=applebloom
    export TEXTDOMAINDIR=/usr/share/locale
fi

_usage ()
{
    echo "$(gettext -n -- 'Apple Bloom the pony dictionary')"
    echo "applebloom $(gettext -n -- '[word...]')"
}

_not_found ()
{
    echo "$1 $(gettext -n -- 'is not in the dictionary try something more or less pony')"
}

_pony ()
{
    echo -n "$1: $(gettext -n -- 'pony word'): "
    cat "$2"
}

_human ()
{
    echo -n "$1: $(gettext -n -- 'human word'): "
    cat "$2"
}


if [ $is_backend = 0 ]; then
    if [ ! -z "$XDG_CONFIG_HOME" ] && [ -f "$XDG_CONFIG_HOME/applebloom/applebloomrc" ]; then
	. "$XDG_CONFIG_HOME/applebloom/applebloomrc"
    elif [ ! -z "$HOME" ] && [ -f "$HOME/.config/applebloom/applebloomrc" ]; then
	. "$HOME/.config/applebloom/applebloomrc"
    elif [ ! -z "$HOME" ] && [ -f "$HOME/.config/applebloomrc" ]; then
	. "$HOME/.config/applebloomrc"
    elif [ ! -z "$HOME" ] && [ -f "$HOME/.config/.applebloomrc" ]; then
	. "$HOME/.config/.applebloomrc"
    elif [ ! -z "$HOME" ] && [ -f "$HOME/.applebloomrc" ]; then
	. "$HOME/.applebloomrc"
    elif [ -f ~/.applebloomrc ]; then
	. ~/.applebloomrc
    elif [ -f /etc/applebloomrc ]; then
	. /etc/applebloomrc
    fi
fi


if [ $# == 0 ]; then
    _usage >&2
    exit 1
fi

for word in "$@"; do
    human="$dictionary/${word/ /-}.human"
    pony="$dictionary/${word/ /-}.pony"
    human="${human,,}"
    pony="${pony,,}"
    hfail=0
    pfail=0
    if [ -L "$human" ]; then
	human="$(realpath "$human")"
	hfail=$?
    fi
    if [ -L "$pony" ]; then
	pony="$(realpath "$pony")"
	pfail=$?
    fi
    if [ $hfail = 0 ]; then	
	if [ ! -f "$human" ]; then
	    hfail=1
	fi
    fi
    if [ $pfail = 0 ]; then	
	if [ ! -f "$pony" ]; then
	    pfail=1
	fi
    fi
    fail=$(( $hfail * $pfail ))
    if [ ! $fail = 0 ]; then
	_not_found "$word"
    else
	if [ $pfail = 0 ]; then
	    _pony "$word" "$pony"
	fi
	if [ $hfail = 0 ]; then
	    _pony "$word" "$human"
	fi
    fi
done

