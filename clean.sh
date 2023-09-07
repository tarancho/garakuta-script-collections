#!/bin/sh

# ディレクトリ配下の作業ファイル等を削除します。ディレクトリ配下の全て
# のファイルが対象となりますので注意してください。

set +ue
cwd=$(cd $(dirname $0) && pwd)

tgt=$cwd
if [ $# -gt 0 ]
then
    tgt=$1
fi

find $tgt \( -name '*~' -o -name 'svn-commit.[0-9.]*tmp' \
    -o -name 'svn-commit.tmp' \) \
    -exec rm -f {} \; -print

# Local Variables:
# coding: utf-8
# mode: sh
# End:
