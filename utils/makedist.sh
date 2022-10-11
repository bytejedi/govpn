#!/bin/sh -ex

cur=$(pwd)
tmp=$(mktemp -d)
release=$1
[ -n "$release" ]

git clone . $tmp/govpn-$release
repos="
    src/cypherpunks.ru/balloon
    src/github.com/agl/ed25519
    src/github.com/bigeagle/water
    src/gopkg.in/yaml.v2
    src/golang.org/x/crypto
    src/golang.org/x/sys
"
for repo in $repos; do
    git clone $repo $tmp/govpn-$release/$repo
done
cd $tmp/govpn-$release
git checkout $release
git submodule update --init

cat > $tmp/includes <<EOF
golang.org/x/crypto/AUTHORS
golang.org/x/crypto/CONTRIBUTORS
golang.org/x/crypto/LICENSE
golang.org/x/crypto/PATENTS
golang.org/x/crypto/README.md
golang.org/x/crypto/blake2b
golang.org/x/crypto/curve25519
golang.org/x/crypto/internal/chacha20
golang.org/x/crypto/internal/subtle
golang.org/x/crypto/poly1305
golang.org/x/crypto/ssh/terminal
golang.org/x/sys/AUTHORS
golang.org/x/sys/CONTRIBUTORS
golang.org/x/sys/LICENSE
golang.org/x/sys/PATENTS
golang.org/x/sys/README.md
golang.org/x/sys/cpu
golang.org/x/sys/unix
EOF
tar cfCI - src $tmp/includes | tar xfC - $tmp
rm -fr src/golang.org
mv $tmp/golang.org src/
rm -fr $tmp/golang.org $tmp/includes

cat > doc/download.texi <<EOF
@node Tarballs
@section Prepared tarballs
You can obtain releases source code prepared tarballs on
@url{http://www.govpn.info/}.
EOF
make -C doc
/bin/sh utils/news.sh
rm -r doc/.well-known doc/govpn.html/.well-known utils/news.sh

rm utils/makedist.sh
find . -name .git -type d | xargs rm -fr
find . -name .gitignore -delete
rm .gitmodules
rm -r ports

cd ..
tar cvf govpn-"$release".tar --uid=0 --gid=0 --numeric-owner govpn-"$release"
xz -9 govpn-"$release".tar
gpg --detach-sign --sign --local-user F2F59045FFE2F4A1 govpn-"$release".tar.xz
mv $tmp/govpn-"$release".tar.xz $tmp/govpn-"$release".tar.xz.sig $cur/doc/govpn.html/download

tarball=$cur/doc/govpn.html/download/govpn-"$release".tar.xz
size=$(( $(stat -f %z $tarball) / 1024 ))
hash=$(gpg --print-md SHA256 < $tarball)
release_date=$(date "+%Y-%m-%d")

cat <<EOF
An entry for documentation:
@item @ref{Release $release, $release} @tab $release_date @tab $size KiB
@tab @url{download/govpn-${release}.tar.xz, link} @url{download/govpn-${release}.tar.xz.sig, sign}
@tab @code{$hash}
EOF

cd $cur

cat <<EOF
Subject: [EN] GoVPN $release release announcement

I am pleased to announce GoVPN $release release availability!

GoVPN is simple free software virtual private network daemon, aimed to
be reviewable, secure, DPI/censorship-resistant, written on Go.

It uses fast strong passphrase authenticated key agreement protocol with
augmented zero-knowledge mutual peers authentication (PAKE DH A-EKE).
Encrypted, authenticated data transport that hides message's length and
timestamps. Optional encryptionless mode, that still preserves data
confidentiality. Perfect forward secrecy property. Resistance to:
offline dictionary attacks, replay attacks, client's passphrases
compromising and dictionary attacks on the server side. Built-in
heartbeating, rehandshaking, real-time statistics. Ability to work
through UDP, TCP and HTTP proxies. IPv4/IPv6-compatibility.
GNU/Linux and FreeBSD support.

------------------------ >8 ------------------------

The main improvements for that release are:

$(git cat-file -p $release | sed -n '6,/^.*BEGIN/p' | sed '$d')

------------------------ >8 ------------------------

GoVPN's home page is: http://www.govpn.info/

Source code and its signature for that version can be found here:

    http://www.govpn.info/download/govpn-${release}.tar.xz ($size KiB)
    http://www.govpn.info/download/govpn-${release}.tar.xz.sig

SHA256 hash: $hash
GPG key ID: 0xF2F59045FFE2F4A1 GoVPN releases <releases@govpn.info>
Fingerprint: D269 9B73 3C41 2068 D8DA  656E F2F5 9045 FFE2 F4A1

Please send questions regarding the use of GoVPN, bug reports and patches
to mailing list: https://lists.cypherpunks.ru/pipermail/govpn-devel/
EOF

cat <<EOF
Subject: [RU] Состоялся релиз GoVPN $release

Я рад сообщить о выходе релиза GoVPN $release!

GoVPN это простой демон виртуальных частных сетей, код которого нацелен
на лёгкость чтения и анализа, безопасность, устойчивость к DPI/цензуре,
написан на Go и является свободным программным обеспечением.

Он использует быстрый сильный аутентифицируемый по парольной фразе
несбалансированный протокол согласования ключей с двусторонней
аутентификацией сторон (PAKE DH A-EKE). Зашифрованный, аутентифицируемый
транспортный протокол передачи данных, скрывающий длины сообщений и их
временные характеристики. Опциональный нешифрованный режим, который
всё равно обеспечивает конфиденциальность и аутентичность данных.
Свойство совершенной прямой секретности. Устойчивость к: внесетевым
(offline) атакам по словарю, атакам повторного воспроизведения (replay),
компрометации клиентских парольных фраз на стороне сервера. Встроенные
функции сердцебиения (heartbeat), пересогласования ключей, статистика
реального времени. Возможность работы поверх UDP, TCP и HTTP прокси.
Совместимость с IPv4 и IPv6. Поддержка GNU/Linux и FreeBSD.

------------------------ >8 ------------------------

Основные усовершенствования в этом релизе:

$(git cat-file -p $release | sed -n '6,/^.*BEGIN/p' | sed '$d')

------------------------ >8 ------------------------

Домашняя страница GoVPN: http://www.govpn.info/
Коротко о демоне: http://www.govpn.info/O-demone.html

Исходный код и его подпись для этой версии находятся здесь:

    http://www.govpn.info/download/govpn-${release}.tar.xz ($size KiB)
    http://www.govpn.info/download/govpn-${release}.tar.xz.sig

SHA256 хэш: $hash
Идентификатор GPG ключа: 0xF2F59045FFE2F4A1 GoVPN releases <releases@govpn.info>
Отпечаток: D269 9B73 3C41 2068 D8DA  656E F2F5 9045 FFE2 F4A1

Пожалуйста, все вопросы касающиеся использования GoVPN, отчёты об ошибках
и патчи отправляйте в govpn-devel почтовую рассылку:
https://lists.cypherpunks.ru/pipermail/govpn-devel/
EOF
