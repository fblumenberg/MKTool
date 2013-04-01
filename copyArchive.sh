DST_DIR=~/Develop/symbolicate/MKTool
ARCH_DIR=~/Library/Developer/Xcode/Archives
LATEST_ARCH_DIR=$(ls -t $ARCH_DIR | head -1);

LATEST_ARCH=$(ls -t $ARCH_DIR/$LATEST_ARCH_DIR | head -1);

cp -R "$ARCH_DIR/$LATEST_ARCH_DIR/$LATEST_ARCH" $DST_DIR

mdimport -d 1 $DST_DIR