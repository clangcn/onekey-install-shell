#!/usr/bin/env bash
#! Encoding UTF-8
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear;
cn="false"
case $LANG in
	zh_CN*) cn="true";;
esac
#获取脚本路劲
ScriptPath=$(cd $(dirname "$0") && pwd)
CONFIG_CREATE(){
	declare -a VarLists
	declare -a ValueLists
	declare -a ExplainLists
	ValueLists=("/var/log" "/usr/local" "/tmp")
	VarLists=("LogPath" "InstallPath" "DownloadTmp")
	$cn && ExplainLists=("日志路径" "安装路径" "缓存路径") || ExplainLists=("Logs" "Install" "Download")
	count=0
	for var in ${VarLists[@]} ;do
		$cn &&  TmpMsg="请输入需要生成的${ExplainLists[$count]}." || TmpMsg="Please input the path with ${ExplainLists[$count]}."
		read -p "$TmpMsg" -t 30 tmpvar
		eval ${VarLists[$count]}=${tmpvar:-${ValueLists[$count]}}
		echo "========================================================================="
		echo "#             ${VarLists[$count]}=${tmpvar:-${ValueLists[$count]}}           #"
		count=$(expr $count + 1)
	done
cat > $ScriptPath/config <<eof
#! Encoding UTF-8
#配置参数
#基础路径
InstallPath="/usr/local"
DownloadTmp="/tmp"
LogPath="/var/log"
#程序路径
LibPath="\$ScriptPath/mylib"
FunctionPath="\$ScriptPath/function"
TemplatePath="\$ScriptPath/Template"
MyCronBashPath="\$InstallPath/mybash"
MyBashLogPath="\$LogPath/mybash"
Python2Path="\$ScriptPath/py2script"
#日志路径
InfoLog=\$LogPath/mlsbs_err\$(date +%Y%m%d).log
ErrLog=\$LogPath/mlsbs_info\$(date +%Y%m%d).log
#check system parameter about cpu's core ,ram ,other
#
#收集系统的一些基础参数给其他函数使用
#
SysName=""
SysCount=""
FileMax=$(cat /proc/sys/fs/file-max)
OSlimit=$(ulimit -n)
egrep -i "centos" /etc/issue && SysName='centos';
egrep -i "debian" /etc/issue && SysName='debian';
egrep -i "ubuntu" /etc/issue && SysName='ubuntu';
SysVer=$(uname -r|cut -d. -f1-2)
SysBit='32' && [ \$(getconf WORD_BIT) == '32' ] && [ \$(getconf LONG_BIT) == '64' ] && SysBit='64';
eof
}
#加载配置内容
[[ ! -f $ScriptPath/config ]] && CONFIG_CREATE
source $ScriptPath/config
#################错误提示##############################
EXIT_MSG(){
	$cn && ExitMsg="$1" || ExitMsg="$2"
	echo -e "$(date +%Y-%m-%d-%H:%M) -ERR $ExitMsg " |tee -a $ErrLog && exit 1
}
#########普通日志##########
INFO_MSG(){
	$cn && InfoMsg="$1" || InfoMsg="$2"
	echo -e "$(date +%Y-%m-%d-%H:%M) -INFO $InfoMsg " |tee -a $InfoLog
}
#检测脚本文件是否存在并加载
SOURCE_SCRIPT(){
for arg do
	if [ ! -f "$arg" ]; then
		EXIT_MSG "缺少文件：$arg ，程序无法运行，请重新下载原程序！" "not exist $arg,so $0 can not be supported!" 
	else
		INFO_MSG "正在加载库: $arg ......" "loading $arg now, continue ......"
		source $arg
	fi
done
}
[[ "$SysName" == '' ]] && EXIT_MSG "程序不支持在此系统上运行。" "Your system is not supported this script"
SOURCE_SCRIPT $LibPath/common
#main
SELECT_RUN_SCRIPT(){
	echo "----------------------------------------------------------------"
	declare -a VarLists
	if $cn ;then
		echo "[Notice] 请选择要运行的指令:"
		VarLists=("退出" "软件安装" "系统设置" "生成脚本工具" "系统报告")
	else
		echo "[Notice] Which function you want to run:"
		VarLists=("Exit" "Sofeware_Install" "System_Setup" "Create_Script" "System_Report")
	fi
	select var in ${VarLists[@]} ;do
		case $var in
			${VarLists[1]})
				SOURCE_SCRIPT $FunctionPath/sofeinstall.sh
				SELECT_SOFE_INSTALL;;
			${VarLists[2]})
				SOURCE_SCRIPT $FunctionPath/system_setup.sh
				SELECT_SYSTEM_SETUP_FUNCTION;;
			${VarLists[3]})
				SOURCE_SCRIPT $FunctionPath/create_tools.sh
				SELECT_TOOLS_CREATE;;
			${VarLists[4]})
				SOURCE_SCRIPT $FunctionPath/report_system.sh
				SELECT_REPORT_CREATE;;
			${VarLists[0]})
				exit 0;;
			*)
				SELECT_RUN_SCRIPT;;
		esac
		break
	done
	SELECT_RUN_SCRIPT
}
SELECT_RUN_SCRIPT
