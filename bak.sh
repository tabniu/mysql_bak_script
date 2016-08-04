#!/bin/bash
#use to backup

bak_data_db(){
	read -p "input the db_id which to backup:" db_id
	bak_db_method	
}



bak_global_db(){
	read -p "input the golbal_db name:" db_id
	bak_db_method		
}

bak_db_method(){
	Tdate=`date +%Y-%m-%d-%H-%M-%S`
	Result="fail"
	for x in $db_id;do
		if [[ $x =~ ^[0-9]+$ ]]
			then 
			db_name=role_sys_data_${x}
			else
			db_name=$x
		fi
		bak_dir="$script_path/mysql_bak/`date +%Y-%m-%d`/${db_name}_${Tdate}/"
		mkdir -p ${bak_dir}
		TableList=`echo "SHOW TABLES;"| $link ${db_name} 2>/dev/null | grep -v "Tables_in_" `
		[[ "$TableList" == "" ]] && exit 3;
		for table in $TableList;do
			$db_link  --quick --single-transaction ${db_name} ${table} > ${bak_dir}/${table}.sql 2>/dev/null
			if [ $? -eq 0 ];then
				Result="success"
			else
				Result="fail ${table}"
				break
			fi
		done
		cd $script_path/mysql_bak/`date +%Y-%m-%d` && tar zcf ${db_name}_${Tdate}.tar.gz ${db_name}_${Tdate}
		rm -rf ${db_name}_${Tdate}
		echo "${Tdate} ${db_name} backup ${Result}!!" 2>&1 
	done
}

#start script

script_path=`dirname $0`


main(){
	read -p "Please input the db lind address:" link
	db_link=`echo "$link" | sed 's/mysql/mysqldump/g' `
	read -p "which database you want to backup(1:role_sys_data|2:golbal_data|3:QUIT):" opt
	case $opt in
		1)bak_data_db
			;;
		2)bak_global_db
			;;
		3)break
	esac		
}

main

