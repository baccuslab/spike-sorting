#!/usr/bin/env bash
# Script to convert from Windows line endings to Unix-like newlines


if [ $# -eq 0 ]; then
	echo "Usage: ./convert-line-endings.sh <filename> [<filename> ... ]"
	exit 1
fi

for file in $@; do
	mv "$file" "$file.bak"
	tr "\r" "\n" < "$file.bak" > $file
	if [ $? -ne 0 ]; then
		echo "Error converting file: $file"
	else
		rm "$file.bak"
	fi
done
