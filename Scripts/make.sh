UT99_PATH=/Users/maarten/Documents/UT99/UT99_Windows
USCRIPT_PROJECT_PATH=/Users/maarten/Documents/UT99/BTPog/UScript

rm -rf ${UT99_PATH}/BTPog
cp -r ${USCRIPT_PROJECT_PATH}/. ${UT99_PATH}
rm -f ${UT99_PATH}/System/BTPog.u

wine ${UT99_PATH}/System/ucc.exe make INI=../BTPog/make.ini 2> /dev/null
