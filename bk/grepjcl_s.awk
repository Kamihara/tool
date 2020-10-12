#!/bin/nawk -f
BEGIN{
        REG_EXP=ARGV[1];
        ARGV[1] =       ARGV[2];
        delete  ARGV[2];
        FILENAME        =       ARGV[1];


        "basename "     FILENAME        |       getline JCL_NAME;

        i       =       0;
        FLG_FIND        =       "off";
        flg_scr =       "off";

}


/^ *stepstart/{
        for(j in que){
                delete  que[j];
        }
        FLG_FIND        =       "off";
        flg_scr =       "off";
        i       =       0;
}

/^ *exec *\/export\/home\/bp\/sh\/CMD_SCR.csh/{
        flg_scr =       "on";
}



{
	#	if(match($0,REG_EXP) > 0){
	#		
	#		if	( substr( $0, RSTART + RLENGTH ) ~ /^[^, \/\t"']/ )	{	#"
	#			;
	#		}else if( ( RSTART > 1 ) && ( substr( $0, RSTART - 1  ) ~ /^[^, \/\t"']/ ) )	{ #"
	#			;
	#		}else{
	#			flg_find        =       "on";
	#			gsub(REG_EXP,"\033[;5m&\033[;3m");
	#		}
	#	}
	#	que[i++]        =       $0;
	
	#	que[i++] = kensaku( REG_EXP, $0 );
	que[i++] = ( $0 ~ /^\*/ ? $0 : kensaku( REG_EXP, $0 ) );
	
}

/^ *stepend/{
        if((FLG_FIND == "on")&&(flg_scr ==      "off")){
                print "#================================================================#";
                for(j=0;j<i;j++){
                        printf("# %s:%s\n",JCL_NAME,que[j]);
                }
        }
}




function	kensaku(var_regexp, var_string,		tmp_str, ret ){
	
	if	( match(var_string,var_regexp) > 0){
		
		if	( substr( var_string, RSTART + RLENGTH ) ~ /^[^, \/\t"']/ )	{	#"
			tmp_str = substr( var_string, 1, RSTART + RLENGTH - 1 );
		}else if( ( RSTART > 1 ) && ( substr( var_string,  RSTART - 1  ) ~ /^[^, \/\t"']/ ) )	{ #"
			tmp_str = substr( var_string, 1, RSTART + RLENGTH - 1 );
		}else{
			FLG_FIND        =       "on";
			gsub(REG_EXP,"\033[;5m&\033[;3m");
			
			tmp_str = substr( var_string, 1, RSTART - 1 ) "\033[;5m" substr( var_string, RSTART, RLENGTH ) "\033[;3m";
		}
		
		return sprintf( "%s%s", tmp_str, kensaku( var_regexp, substr( var_string, RSTART + RLENGTH ) ) );
	}
	return var_string;
}

