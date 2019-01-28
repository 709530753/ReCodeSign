
#找到当前ipa
TARGET_IPA_PATH="${SRCROOT}/APP/*.ipa"
echo "根目录" + "${TARGET_IPA_PATH}"

TEMP_FLDER_PATH="${SRCROOT}/Temp"

#创建temp文件夹
rm -rf "${TEMP_FLDER_PATH}"
mkdir -p "${TEMP_FLDER_PATH}"

#解压ipa
unzip "${TARGET_IPA_PATH}" -d "${TEMP_FLDER_PATH}/"

#找到Payload 目录的.app文件

#TEMP_APP_PATH="$TEMP_FLDER_PATH/Payload/*.app"
#比较坑
TEMP_APP_PATH=$(set -- "$TEMP_FLDER_PATH/Payload/"*.app;echo "$1")


echo "包路径：" + "${TEMP_APP_PATH}"

#将.app拷贝工程目录
TARGET_APP_PATH="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app"
echo "工程目录下的app : ${TARGET_APP_PATH}"

rm -rf "$TARGET_APP_PATH"
mkdir -p "$TARGET_APP_PATH"
cp -rf "$TEMP_APP_PATH/" "$TARGET_APP_PATH"

#删除Watch PlugIns
rm -rf "$TARGET_APP_PATH/Watch" "$TARGET_APP_PATH/PlugIns"

#修改bundleIdentity
echo "包名：" "${PRODUCT_BUNDLE_IDENTIFIER}"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $PRODUCT_BUNDLE_IDENTIFIER" "$TARGET_APP_PATH/Info.plist"

#获取macho文件权限

# 5. 给MachO文件上执行权限
# 拿到MachO文件的路径
APP_BINARY=`plutil -convert xml1 -o - $TARGET_APP_PATH/Info.plist|grep -A1 Exec|tail -n1|cut -f2 -d\>|cut -f1 -d\<`
#上可执行权限
chmod +x "$TARGET_APP_PATH/$APP_BINARY"

#重签名frameworks
#----------------------------------------
# 6. 重签名第三方 FrameWorks
TARGET_APP_FRAMEWORKS_PATH="$TARGET_APP_PATH/Frameworks"
if [ -d "$TARGET_APP_FRAMEWORKS_PATH" ];
then
for FRAMEWORK in "$TARGET_APP_FRAMEWORKS_PATH/"*
do

#签名
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$FRAMEWORK"
done
fi



