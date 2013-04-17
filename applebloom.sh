#!/bin/sh
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

dictionary=./

if [ $# == 0 ]; then
    echo 'Apple Bloom the pony dictionary' >&2
    echo 'applebloom [word...]' >&2
    exit 1
fi

for word in "$@"; do
    file="$dictionary${file/ /-/}"
    fail=0
    if [ -L "$file" ]; then
	file="$(realpath file)"
	fail=$?
    fi
    if [ $fail = 0 ]; then	
	if [ ! -f "$file" ]; then
	    fail=$1
	fi
    fi
    if [ ! $fail = 1 ]; then
	echo "$word is not in the directionary try something more or less pony"
    else
	echo -n "$word: "
	cat "$file"
    fi
done

