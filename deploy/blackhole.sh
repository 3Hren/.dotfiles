#!/bin/sh

PROJECT_NAME=blackhole
SOURCE_DIR=~/code/${PROJECT_NAME}/
TARGET_DIR=/home/esafronov/code/${PROJECT_NAME}/${PROJECT_NAME}
DEFAULT_HOST=s30h.xxx.yandex.net
TARGET_HOST=${1-${DEFAULT_HOST}}

rsync -avz --exclude=build ${SOURCE_DIR} ${TARGET_HOST}:${TARGET_DIR} && \

ssh -t ${TARGET_HOST} "cd ${TARGET_DIR}/build && rm -rf * && cmake -DENABLE_TESTING=ON -DENABLE_EXAMPLES=ON -DENABLE_BENCHMARKING=OFF .. && time make -j32 && valgrind ./blackhole-tests" && \
terminal-notifier -message "Done" -contentImage ~/.dotfiles/deploy/img/succ.png || \
terminal-notifier -message "Fail" -contentImage ~/.dotfiles/deploy/img/fail.png
