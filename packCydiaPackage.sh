CYDIAREPOSITORY=/Users/frankblumenberg/Develop/Cocoa/Mikrocopter/Cydia-Repo/repo/
PROJECTMAIN=$(pwd)
PROJECT_NAME="iKopter2"
APPMAIN=${PROJECTMAIN}/Cydia/$PROJECT_NAME/Applications/${PROJECT_NAME}.app
#
if [[ -f "${APPMAIN}/Info.plist" ]]
then
buildPlist="${APPMAIN}/Info.plist"
else
echo -e "Can't find the plist: ${PROJECT_NAME}-Info.plist"
exit 1
fi
#
buildVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${buildPlist}" 2>/dev/null)
if [[ "${buildVersion}" = "" ]]
then
echo -e "\"${buildPlist}\" does not contain key: \"CFBundleVersion\""
exit 1
fi

marketVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${buildPlist}" 2>/dev/null)
if [[ "${marketVersion}" = "" ]]
then
echo -e "\"${buildPlist}\" does not contain key: \"CFBundleShortVersionString\""
exit 1
fi


cd ${PROJECTMAIN}/Cydia/${PROJECT_NAME}/DEBIAN
sed 's/Version:.*$/Version: '${marketVersion}-${buildVersion}'/' control > control1
echo "==============================="
mv control1 control

find ${PROJECTMAIN}/Cydia -name .DS_Store -ls -exec rm {} \;
rm -Rf ${PROJECTMAIN}/Cydia/repo
mkdir ${PROJECTMAIN}/Cydia/repo
mkdir ${PROJECTMAIN}/Cydia/repo/deb

cd ${PROJECTMAIN}/Cydia
/usr/local/bin/dpkg-deb -b $PROJECT_NAME ${PROJECTMAIN}/Cydia/repo/deb/${PROJECT_NAME}Package.deb

cd ${PROJECTMAIN}/Cydia/repo 
/usr/local/bin/dpkg-scanpackages deb / > Packages
cat Packages
bzip2 Packages

cd ${PROJECTMAIN}

cp ${PROJECTMAIN}/Cydia/repo/deb/${PROJECT_NAME}Package.deb ${CYDIAREPOSITORY}/deb


