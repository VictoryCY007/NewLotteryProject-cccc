#!/bin/sh

echo "~~~~~~~~~~~~~~~~~~~~ 开始执行打包脚本 ~~~~~~~~~~~~~~~~~~~~"

########################## 工程基本信息配置 ###########################
#循环数组,需要打包的渠道名称,以空格隔开
channelArray=("ZZCP" "HCT" "LotteryApp")
#channelArray=("ZZCP")

exportPlistPathArray=("/Users/quanwei/Documents/GitHub/LotteryProject/LotteryApp/ExportOptionsZZCP.plist" "/Users/quanwei/Documents/GitHub/LotteryProject/LotteryApp/ExportOptionsHCT.plist" "/Users/quanwei/Documents/GitHub/LotteryProject/LotteryApp/ExportOptionsLotteryApp.plist")
#exportOptionsPlistPath="/Users/quanwei/Documents/GitHub/LotteryProject/LotteryApp/ExportOptionsZZCP.plist"
#项目路径
MWBuildDir="/Users/quanwei/Documents/GitHub/LotteryProject/LotteryApp"
#工程名/Users/quanwei/Documents/GitHub/LotteryProject/LotteryApp
projectName="LotteryApp"
#ExportOptions.plist 路径/Users/quanwei/Documents/GitHub/LotteryProject/LotteryApp/ExportOptions(HCT).plist

#exportOptionsPlistPath="/Users/quanwei/Documents/GitHub/LotteryProject/LotteryApp/ExportOptions(HCT).plist"
#Release还是Debug
buildConfiguration="Release"
#Ipa导出路径
IpaExportPath="/Users/quanwei/Desktop/ipapackat"
# 开始时间
beginTime=`date +%s`

for ((i=0;i<${#channelArray};i++))
do

echo  ${channelArray[$i]}

targetName=${channelArray[$i]}
exportOptionsPlistPath=${exportPlistPathArray[$i]}

# 创建不同 app ipa 目录
mkdir $allIPAPackPath/${targetName}
rm -rf $allIPAPackPath/${targetName}}/*

echo "\033[31m appChannelName:$targetName \n \033[0m"
#exportOptionsPlistPath=${exportPlistPathArray[$i]}
echo  $projectName
echo  $targetName

#编译
xcodebuild archive -workspace ${projectName}.xcworkspace -scheme ${targetName} -configuration ${buildConfiguration} -sdk "iphoneos" clean archive -archivePath ./ArchivePath/${targetName}.xcarchive
if [[ $? = 0 ]]; then
echo "\033[31m 编译成功\n \033[0m"
else
echo "\033[31m 编译失败\n \033[0m"
fi

# 先创建 payload 文件夹
mkdir ${IpaExportPath}/Payload
# 移动编译生成的 app 到的 Payload 文件夹下
cp -Rf ${MWBuildDir}/build/${targetName}.xcarchive ${IpaExportPath}/Payload
#cp -Rf ${projectDir}/build/${schemeName}.xcarchive ${ipaPath}/Payload
if [[ $? = 0 ]]; then
echo "\033[31m app移动成功\n \033[0m"
else
echo "\033[31m app移动失败\n \033[0m"
fi
#生成ipa
xcodebuild -exportArchive -archivePath ./ArchivePath/${targetName}.xcarchive -exportOptionsPlist ${exportOptionsPlistPath} -exportPath ${IpaExportPath}/$targetName
if [[ $? = 0 ]]; then
echo "\033[31m \n 生成 IPA 成功 \n\n\n\n\n\033[0m"
else
echo "\033[31m \n 生成 IPA 失败 \n\n\n\n\n\033[0m"
fi
#echo  "打包成功"
done


# 清除无关文件
rm -rf ${IpaExportPath}/Payload

# 结束时间
endTime=`date +%s`
echo -e "打包时间$[ endTime - beginTime ]秒"

#xcodebuild archive -workspace MeteorologicalMonitoring.xcworkspace -scheme WamingJinshan -configuration Release -sdk "iphoneos" clean archive -archivePath ./ArchivePath/WamingJinshan.xcarchive

done

