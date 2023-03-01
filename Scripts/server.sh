UT99_PATH=/Users/maarten/Documents/UT99/UT99_Windows
MAP=CTF-BT-andACTION-dbl

if [[ ! -z $1 ]] ; then
    MAP=$1
fi

wine ${UT99_PATH}/System/ucc.exe server ${MAP}?game=BTPlusPlusPublicUTBT_beta3.BunnyTrackGame 2> /dev/null
