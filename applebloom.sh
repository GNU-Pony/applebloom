#!/bin/bash
##
# applebloom – Apple Bloom the pony dictionary
# 
# Copyright © 2013  Mattias Andrée (maandree@member.fsf.org)
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
##

dictionary=dictionary

if [ $# == 0 ]; then
    echo 'Apple Bloom the pony dictionary' >&2
    echo 'applebloom [word...]' >&2
    exit 1
fi

for word in "$@"; do
    human="$dictionary/${word/ /-/}.human"
    pony="$dictionary/${word/ /-/}.pony"
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
	echo "$word is not in the directionary try something more or less pony"
    else
	if [ $pfail = 0 ]; then
	    echo -n "$word: pony word: "
	    cat "$pony"
	fi
	if [ $hfail = 0 ]; then
	    echo -n "$word: human word: "
	    cat "$human"
	fi
    fi
done

