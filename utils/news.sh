#!/bin/sh -ex

texi=`mktemp`

cat > $texi <<EOF
\input texinfo
@documentencoding UTF-8
@settitle NEWS

@node News
@unnumbered News

`sed -n '5,$p' < doc/news.texi`

@bye
EOF
makeinfo --plaintext -o NEWS $texi

cat > $texi <<EOF
\input texinfo
@documentencoding UTF-8
@settitle NEWS.RU

@node Новости
@unnumbered Новости

`sed -n '3,$p' < doc/news.ru.texi | sed 's/^@subsection/@section/'`

@bye
EOF
makeinfo --plaintext -o NEWS.RU $texi

rm -f $texi
