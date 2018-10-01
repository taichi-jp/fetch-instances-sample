#!/bin/bash

set -eu

#メッセージを保存する一時ファイル
MESSAGEFILE=$(mktemp -t webhooks.XXXXXX)

usage_exit() {
    echo "Usage: $0 [-u url] [-m message] [-r role] [-c channel] [-i icon] [-l level] [-n botname]" 1>&2
    exit 0
}

while getopts c:u:i:l:r:n:m: opts
do
    case $opts in
        c)
            CHANNEL=$OPTARG
            ;;
        u)
            URL=$OPTARG
            ;;
        i)
            FACEICON=$OPTARG
            ;;
        l)
            LEVEL=$OPTARG
            ;;
        r)
            ROLE=$OPTARG
            ;;
        n)
            BOTNAME=$OPTARG
            ;;
        m)
            MESSAGE=$OPTARG"\n"
            ;;
        \?)
            usage_exit
            ;;
    esac
done

#slack 送信チャンネル
CHANNEL=${CHANNEL:-"#notify-gpu-servers"}

#slack 送信名
BOTNAME=${BOTNAME:-"gcp"}

#slack アイコン
FACEICON=${FACEICON:-":computer:"}

#サーバの役割
ROLE=${ROLE:-"unknown"}

#レベル
LEVEL=${LEVEL:-"info"}

#ホスト名
HOSTNAME=`hostname`

#Incoming WebHooksのURL
WEBHOOKURL=${URL:-"https://hooks.slack.com/services/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"}

#見出しとなるようなメッセージ
MESSAGE=${MESSAGE:-""}

if [ -p /dev/stdin ] ; then
    #改行コードをslack用に変換
    cat - | tr '\n' '\\' | sed 's/\\/\\n/g' | sed 's|/|\\/|g' | sed 's/"/\\"/g'  > ${MESSAGEFILE}
else
    echo "nothing stdin"
    exit 1
fi

#レベルにより、表示色を変える
COLOR="#D3D3D3"
if [ "$LEVEL" = "info" ] ; then
    COLOR="#32CD32"
elif [ "$LEVEL" = "warn" ] ; then
    COLOR="#FFFF00"
elif [ "$LEVEL" = "error" ] ; then
    COLOR="#FF0000"
fi

WEBMESSAGE=''`cat ${MESSAGEFILE}`''

#Incoming WebHooks送信
curl -s -S -X POST --data-urlencode \
  "payload={ \
    \"channel\": \"${CHANNEL}\", \
    \"username\": \"${BOTNAME}\", \
    \"attachments\": [ \
      { \
        \"pretext\": \"${MESSAGE}\", \
        \"color\": \"${COLOR}\", \
        \"text\": \"${WEBMESSAGE}\" \
      } \
    ], \
    \"icon_emoji\": \"${FACEICON}\" \
  }" \
${WEBHOOKURL}

trap "
    rm ${MESSAGEFILE}
" 0
