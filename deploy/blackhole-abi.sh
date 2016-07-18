#!/bin/sh
set -e

PROJECT_NAME=blackhole
SOURCE_DIR=~/code/${PROJECT_NAME}/
TARGET_DIR=/home/esafronov/code/${PROJECT_NAME}/${PROJECT_NAME}
TARGET_HOST=s30h.xxx.yandex.net

OLD_COMMIT=${1-"master"}
NEW_COMMIT=${2-"develop"}

echo "Deploying ..."
rsync -avz --exclude=build ${SOURCE_DIR} ${TARGET_HOST}:${TARGET_DIR} --delete-before

ssh -t ${TARGET_HOST} "cd ${TARGET_DIR}/build && rm -rf * && mkdir -p ${TARGET_DIR}/build/${OLD_COMMIT} && mkdir -p ${TARGET_DIR}/build/${NEW_COMMIT}"
ssh -t ${TARGET_HOST} "cd ${TARGET_DIR}/build/${OLD_COMMIT} && git checkout ${OLD_COMMIT} && cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=. ../.. && time make -j32 install"
ssh -t ${TARGET_HOST} "cd ${TARGET_DIR}/build/${NEW_COMMIT} && git checkout ${NEW_COMMIT} && cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=. ../.. && time make -j32 install"

OLD_XML="
<version>
    ${OLD_COMMIT}
</version>

<headers>
    ${TARGET_DIR}/build/${OLD_COMMIT}/include/
</headers>

<libs>
    ${TARGET_DIR}/build/${OLD_COMMIT}/lib
</libs>"

NEW_XML="
<version>
    ${NEW_COMMIT}
</version>

<headers>
    ${TARGET_DIR}/build/${NEW_COMMIT}/include/
</headers>

<libs>
    ${TARGET_DIR}/build/${NEW_COMMIT}/lib
</libs>"

ssh -t ${TARGET_HOST} "echo '${OLD_XML}' > /tmp/${OLD_COMMIT}.xml && echo '${NEW_XML}' > /tmp/${NEW_COMMIT}.xml"

ssh -t ${TARGET_HOST} "abi-compliance-checker -lib blackhole -old /tmp/${OLD_COMMIT}.xml -new /tmp/${NEW_COMMIT}.xml -gcc-options -std=c++11"
