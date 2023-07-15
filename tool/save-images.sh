#!/usr/bin/env bash

# github에 올린 user-images를 자동으로 다운로드합니다.

NUM=4795889

CHANGE_LIST=`git diff --exit-code --cached --name-only --diff-filter=ACM -- '*.md'`

echo $CHANGE_LIST

SUCCESS_COUNT=0
FAIL_COUNT=0
for CHANGED_FILE in $CHANGE_LIST; do
    echo "이미지경로를 교정할 문서 파일: [$CHANGED_FILE]"

    RESOURCE_DIR=`head $CHANGED_FILE | egrep -o '[A-F0-9-]{6}/[A-F0-9-]{30}$'`
    echo $RESOURCE_DIR
    TARGET_PATH="./resource/$RESOURCE_DIR"
    echo $TARGET_PATH

    echo "생성할 디렉토리 경로: [$TARGET_PATH]"
    mkdir -p $TARGET_PATH

    # 작업 대상 파일에서 참조하고 있는 github에 등록된 리소스 파일들의 URI 목록
    # URI_LIST=`ag "https://github.com/mcsmonk/mcsmonk.github.io/assets/\/$NUM\/.*" -o $CHANGED_FILE`
    # URI_LIST=`ag "https://user-images\.githubuser.*?\/$NUM\/.*?(png|jpg|gif|mp4)" -o $CHANGED_FILE`
    # URI_LIST=`ag "https://pbs.twimg.com/media/.*?(png|jpg|gif|mp4)" -o $CHANGED_FILE`

    URI_LIST=`ag "https://((user-images\.githubuser.*?\/$NUM\/)|(pbs.twimg.com/media/)|(video.twimg.com/.+_video/)).*?(png|jpg|gif|mp4)" -o $CHANGED_FILE`
    #URI_LIST=`ag "https://github.com/mcsmonk/mcsmonk.github.io/assets/$NUM/[a-zA-Z0-9-]+" -o $CHANGED_FILE`
sunghyunjin.com/blogwiki/resource/14D861/B8-96A4-4808-97FA-79E3BF206E72/253731648-d034b2ac-1b1f-48a0-8ef6-082620d34405.jpg
    for URI in $URI_LIST; do
        FILE_NAME=`echo $URI | sed 's,^.*/,,'`
        echo $FILE_NAME
        RESOLVE_FILE_PATH="$TARGET_PATH/$FILE_NAME"
        echo $RESOLVE_FILE_PATH
        RESOLVE_URL=`echo "$RESOLVE_FILE_PATH" | sed -E 's/^\.//'`
        RESOLVE_URL="https://sunghyunjin.com/blogwiki$RESOLVE_URL"
        echo $RESOLVE_URL

        echo "작업 대상 URI: [$URI]"
        echo "작업 대상 파일 패스: [$RESOLVE_FILE_PATH]"
        curl -s $URI > $RESOLVE_FILE_PATH

        if [ "$?" == "0" ]; then
            echo "DOWNLOAD SUCCESS: $FILE_NAME"
            sed -i '' -E 's, *https://.*('"$FILE_NAME"') *, '$RESOLVE_URL' ,g' $CHANGED_FILE

            git add $RESOLVE_FILE_PATH

            SUCCESS_COUNT=$((SUCCESS_COUNT+1))
        else
            echo "DOWNLOAD FAIL: $FILE_NAME"
            rm -f $RESOLVE_FILE_PATH
            FAIL_COUNT=$((FAIL_COUNT+1))
        fi
    done
    git add $CHANGED_FILE
done

printf "Success: %d, Fail: %d\n" $SUCCESS_COUNT $FAIL_COUNT

