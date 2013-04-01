xcodebuild -workspace MKTool.xcworkspace -configuration Cydia -scheme MKToolCydia archive

./packCydiaPackage.sh
./copyArchive.sh
