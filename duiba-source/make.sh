#/bin/sh
#coding utf-8
#上传模块需要FIR.im CLI 
#安装gem install fir-cli
#token 获取 http://fir.im/user/info

#安静模式，不输出多余log
quiet=1

while getopts "huv" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
         t)
            echo "t's arg:$OPTARG" #参数存在$OPTARG中
            ;;
         u)
            upload=1
            ;;
         v)
            quiet=0
            ;;

         h)
            echo Commands:
            echo "    make -u        #build ipa and upload fir.im"
            ;;
         ?)  #当有不认识的选项的时候arg为?
        echo "unkonw argument"
    ;;
    esac
done

token="f7bb3f28184ed014d137621048ac5790"  #token 获取 http://fir.im/user/info

echo '--------------start----------------'
echo '>> clean...'
proj=$(cd $(dirname ${0}) ; pwd -P)
xcodebuild clean 1>/dev/null
project=PrizeClaw #修改为项目的名称
product="$proj/build/$project.ipa"
rm $product

echo '>> build...'
if [[ $quiet == 1 ]]
then
    xcodebuild -workspace "$project.xcworkspace" -scheme "$project" archive -archivePath $proj/build/$project.xcarchive -configuration Debug -sdk iphoneos >/dev/null
else
    xcodebuild -workspace "$project.xcworkspace" -scheme "$project" archive -archivePath $proj/build/$project.xcarchive -configuration Release -sdk iphoneos
fi

echo '>> create ipa...'

xcodebuild -exportArchive -archivePath $proj/build/$project.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath "$proj/build"

#copy dsym to xcarchives
echo '>> archive dsym...'
if [[ -d $proj/build/$project.xcarchive ]]
then
    filename=$(date "+%Y%m%d%H%M.%S")
    mkdir -p "$proj/build/archives"
    cp -r $proj/build/$project.xcarchive/ "$proj/build/archives/$filename.xcarchive"
    cp "$product" "$proj/build/archives/$filename.xcarchive"
fi

echo '>>>upload ipa'
fir l $token
fir p "$product"
clear
fir i "$product"

#if [[ $upload == 1 ]] && [[ -f "$product" ]]
#then
#    echo '>>>upload ipa'
#    fir l $token
#    fir p "$product"
#    clear
#    fir i "$product"
#else
#    open "$proj/build"
#fi
