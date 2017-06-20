#!/bin/ksh
#----------------------------------------------------------------
#----------------------------------------------------------------

FLG_EXCLUDE="OFF";
WORK_DIR='/BP/FLV02B';
ADD_JCL_DIR='';

# コマンドラインオプションの処理
# 検索オプション
# -a:本番jclを検索対象に含める
while   getopts v:s:a      OPT;do
    case $OPT in
        "v" )
            FLG_EXCLUDE="ON"; REG_EXP_EXCLUDE="$OPTARG";;
        "s" )
            FLG_S="ON";;
        "a" )
            ADD_JCL_DIR='/export/home/bp/jcl /export/home/bp/unyou1/jcl';;
          * )
                      ;;
    esac
    shift $(($OPTIND -1));
done

#----------------------------------------------------
#       $WORK_DIR の空き容量のチェック
#       一定値を超えたら、メッセージを吐いて異常終了。
#----------------------------------------------------
SPACE_WORK_DIR=`df -k ${WORK_DIR} | nawk 'NR == 2 { sub( /%$/, "", $5 );print $5}'`;
if [ "${SPACE_WORK_DIR}" -gt 95 ];then

    echo "\033[;5m" # 反転表示の開始

    echo "${WORK_DIR} の使用率が95%を超えています。容量を空けてから実行シテね！";
    df -k "${WORK_DIR}";

    echo "\033[;0m" # 反転表示の終了

    exit    90;

fi

#----------------------------------------------------
# JCL検索初期処理
#----------------------------------------------------

# 検索文字列
REG_EXP=$1;

JCL_DIR_LIST="`ls -d /export/home/bpp/bpw00/*/jcl` ${ADD_JCL_DIR}";

#----------------------------------------------------
# JCL検索・結果出力処理
#----------------------------------------------------
for JCL_DIR in ${JCL_DIR_LIST}
do

    GREP_AWK="/export/home/s1/s1yst/awk_dir/grepjcl.awk";
    GREP_AWK_S="/export/home/s1/s1yst/awk_dir/grepjcl_s.awk";
    GREP_AWK_EXCLUDE="/export/home/s1/s1yst/awk_dir/grepjcl_exclude.awk";

    yyyymmddhhmmss=`date +%Y%m%d%H%M%S`;
    pid=$$;

    SPLIT_DIR="${WORK_DIR}/bpwgrepjcl_${yyyymmddhhmmss}_${pid}/";

    cd $JCL_DIR;

    # CNTL-C されたとき(2)、
    # あるいは、強制終了されたとき(9)は、
    # SPLIT_DIR を削除して、終了する(返り値:1)。
    trap "/bin/rm -r $SPLIT_DIR;exit 1;" 2 9;

    mkdir $SPLIT_DIR;


    ls -1|split - "${SPLIT_DIR}/spl_";

    # $SPLIT_DIR 配下の各ファイルについて、
    # そのファイルに記述したjclファイル名で指示されたjclから、
    # 正規表現 $REG_EXP を検索し、
    ls -1 $SPLIT_DIR/* | while read spl_file;do

        # JCL_DIR 配下の $spl_file から、正規表現 $REG_EXP を検索する。
        # ヒットした場合、jclファイル名をファイル ${spl_file} に格納
        grep -l $REG_EXP `awk '{printf("%s ",$0)}' $spl_file` >> ${spl_file}_grep  &

    done

    wait;

    echo "↓↓↓""\033[;5m$JCL_DIR\033[;0m""↓↓↓";
    echo "# ★☆★☆★☆★☆★☆★☆";


    cat $SPLIT_DIR/*_grep   \
    | while   read    para;do
        if      [[ $FLG_EXCLUDE = "ON" ]];then
                ${GREP_AWK_EXCLUDE} -v "REG_EXP_EXCLUDE=${REG_EXP_EXCLUDE}" "$REG_EXP" $para;
        elif    [[ $FLG_S = "ON" ]];then
                ${GREP_AWK_S} "$REG_EXP" $para;
        else
                ${GREP_AWK} "$REG_EXP" $para;
        fi
    done;
    echo "#================================================================#";
    echo "# ★☆★☆★☆★☆★☆★☆";

    /bin/rm -r $SPLIT_DIR;
done
