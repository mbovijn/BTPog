UT99_DEV_PATH=/Users/maarten/Downloads/UT99-Dev

mkdir -p ${UT99_DEV_PATH}
docker volume create --opt type=none --opt device=${UT99_DEV_PATH} --opt o=bind ut99-dev

docker run -it --rm --platform linux/amd64 \
    -v ut99-dev:/root/.utpg:rw \
    -p 7777:7777/udp \
    -p 7778:7778/udp \
    fulcrum/ut99-build-tools \
    "./System64/ucc-bin-amd64 server CTF-BT-andACTION-dbl?game=BTPlusPlusTE_beta3.BunnyTrackGame"