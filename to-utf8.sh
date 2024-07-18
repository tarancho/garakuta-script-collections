#!/bin/sh
#
# テキストファイルの文字コードを utf-8 へ変換するスクリプト。変換元の
# 文字コードは file コマンドの結果から簡易的に推測していますので、完全
# である保証はありません。

set -ue

if [ -z "$(iconv --version 2>/dev/null)" ]
then
    echo "iconv が見付かりません。" >&2
    exit 1
fi
if [ -z "$(file --version 2>/dev/null)" ]
then
    echo "file コマンドが見付かりません。" >&2
    exit 1
fi
if [ -z "$(diff --version 2>/dev/null)" ]
then
    echo "diff コマンドが見付かりません。" >&2
    exit 1
fi

tmpfile=$(mktemp)

while [ $# -ge 1 ]
do
    echo -n "$1: "
    rm -f $tmpfile
    fcode=$(file -i $1 | cut -f 2 -d ';' | cut -f 2 -d '=')
    echo -n "$fcode → "
    if [ "$fcode" = "iso-8859-1" ]
    then
        # euc-jp は iso-8859-1 と判別される事が多い
        fopt="euc-jp"
    elif [ "$fcode" = "unknown-8bit" ]
    then
        # ms932 は unknown-8bit と判別される事が多い
        fopt="ms932"
    elif [ "$fcode" = "us-ascii" ]
    then
        # iso-2022-jp は us-asciiと判別される。us-asciiは本来、変換不
        # 要。
        fopt="iso-2022-jp"
    else
        echo "コード変換の必要はありません"
        shift
        continue
    fi

    set +e
    iconv -f $fopt -t utf-8 -o $tmpfile $1
    if [ $? -ne 0 ]
    then
        echo "コード変換できません"
        shift
        continue
    fi

    diff $tmpfile $1 > /dev/null
    if [ $? -eq 0 ]
    then
        echo "変換の結果同一"
    else
        rm -f $1~
        mv $1 $1~
        cp $tmpfile $1
        echo "変換終了"
    fi
    shift
done
rm -f $tmpfile
exit 0
