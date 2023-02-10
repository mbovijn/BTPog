UT99_DEV_PATH=/Users/maarten/Documents/UT99_Dev_Install
MAP=CTF-BT-andACTION-dbl

if [[ ! -z $1 ]] ; then
    MAP=$1
fi

mkdir -p ${UT99_DEV_PATH}
docker volume create --opt type=none --opt device=${UT99_DEV_PATH} --opt o=bind ut99-dev

docker run -it --rm --platform linux/i386 \
    -v ut99-dev:/root/.utpg:rw \
    -p 7777:7777/udp \
    -p 7778:7778/udp \
    fulcrum/ut99-build-tools \
    "./System/ucc-bin server ${MAP}?game=BTPlusPlusTE_beta3.BunnyTrackGame"
