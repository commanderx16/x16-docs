#!/bin/bash
set -euo pipefail
pandoc --version || {
    echo Install the following commands:
    echo sudo apt install pandoc texlive texlive-xetex
}
mkdir -p release
rm -f programmers-guide.md
echo Generating pdf...
find . -iname "X16 *.md" -print0 | sort --zero-terminated \
    | xargs -0 pandoc --file-scope    --pdf-engine=xelatex -o release/programmers-guide.pdf
echo Generating docfile...
find . -iname "X16 *.md" -print0 | sort --zero-terminated \
    | xargs -0 pandoc --file-scope   -o release/programmers-guide.docx
