#!/usr/xpg4/bin/awk -f
BEGIN{
	
	REG_EXP=ARGV[1];
	ARGV[1]	=	ARGV[2];
	delete	ARGV[2];
	FILENAME	=	ARGV[1];
	
	

	"basename "	FILENAME	|	getline	JCL_NAME;
	#print	JCL_NAME	"\r";
	#print	REG_EXP
	
	i	=	0;
	flg_find	=	"off";
	flg_scr	=	"off";
	flg_exclude	=	"off";


}

#/REG_EXP/{
#	flg_find	=	"on";
#}

#==2007/03/16 (1) s1meg Start
#/^stepstart/{
/^ *stepstart/{
#==2007/03/16 (1) s1meg End
	for(j in que){
		delete	que[j];
	}
	flg_find	=	"off";
	flg_scr	=	"off";
	flg_exclude	=	"off";
	i	=	0;
}

/^ *exec *\/export\/home\/bp\/sh\/CMD_SCR.csh/{
	flg_scr	=	"on";
}
	
( index( $0, REG_EXP_EXCLUDE ) > 0 )	{
	flg_exclude	=	"on";
}


{
	if(index($0,REG_EXP) > 0){
		flg_find	=	"on";
        gsub(REG_EXP,"\033[;5m&\033[;3m");
	}
	que[i++]	=	$0;
}

#==2007/03/16 (2) s1meg Start
#/^stepend/{
/^ *stepend/{
#==2007/03/16 (2) s1meg End
	# 2010/07/07 s1meg #	if((flg_find == "on")&&(flg_scr	==	"off")){
	if	( ( flg_find == "on" ) && ( flg_scr	==	"off" ) && ( flg_exclude == "off" ) )	{
		print "#================================================================#";
		for(j=0;j<i;j++){
			printf("# %s:%s\n",JCL_NAME,que[j]);
		}
	}
}

