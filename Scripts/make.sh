UT99_DEV_PATH=/Users/maarten/Documents/UT99_Dev_Install
BTPOG_USCRIPT_PATH=/Users/maarten/Documents/UT99_Projects/BTPog/UScript

mkdir -p ${UT99_DEV_PATH}
docker volume create --opt type=none --opt device=${UT99_DEV_PATH} --opt o=bind ut99-dev

cp -r ${BTPOG_USCRIPT_PATH}/. ${UT99_DEV_PATH}

docker run -it --rm --platform linux/amd64 \
    -v ut99-dev:/root/.utpg:rw \
    fulcrum/ut99-build-tools \
    "rm -f ./System/BTPog.u && ./System64/ucc-bin-amd64 make INI=../BTPog/make.ini"
