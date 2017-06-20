#!/bin/ksh
#----------------------------------------------------------------
#----------------------------------------------------------------

FLG_EXCLUDE="OFF";
WORK_DIR='/BP/FLV02B';
ADD_JCL_DIR='';

# �R�}���h���C���I�v�V�����̏���
# �����I�v�V����
# -a:�{��jcl�������ΏۂɊ܂߂�
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
#       $WORK_DIR �̋󂫗e�ʂ̃`�F�b�N
#       ���l�𒴂�����A���b�Z�[�W��f���Ĉُ�I���B
#----------------------------------------------------
SPACE_WORK_DIR=`df -k ${WORK_DIR} | nawk 'NR == 2 { sub( /%$/, "", $5 );print $5}'`;
if [ "${SPACE_WORK_DIR}" -gt 95 ];then

    echo "\033[;5m" # ���]�\���̊J�n

    echo "${WORK_DIR} �̎g�p����95%�𒴂��Ă��܂��B�e�ʂ��󂯂Ă�����s�V�e�ˁI";
    df -k "${WORK_DIR}";

    echo "\033[;0m" # ���]�\���̏I��

    exit    90;

fi

#----------------------------------------------------
# JCL������������
#----------------------------------------------------

# ����������
REG_EXP=$1;

JCL_DIR_LIST="`ls -d /export/home/bpp/bpw00/*/jcl` ${ADD_JCL_DIR}";

#----------------------------------------------------
# JCL�����E���ʏo�͏���
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

    # CNTL-C ���ꂽ�Ƃ�(2)�A
    # ���邢�́A�����I�����ꂽ�Ƃ�(9)�́A
    # SPLIT_DIR ���폜���āA�I������(�Ԃ�l:1)�B
    trap "/bin/rm -r $SPLIT_DIR;exit 1;" 2 9;

    mkdir $SPLIT_DIR;


    ls -1|split - "${SPLIT_DIR}/spl_";

    # $SPLIT_DIR �z���̊e�t�@�C���ɂ��āA
    # ���̃t�@�C���ɋL�q����jcl�t�@�C�����Ŏw�����ꂽjcl����A
    # ���K�\�� $REG_EXP ���������A
    ls -1 $SPLIT_DIR/* | while read spl_file;do

        # JCL_DIR �z���� $spl_file ����A���K�\�� $REG_EXP ����������B
        # �q�b�g�����ꍇ�Ajcl�t�@�C�������t�@�C�� ${spl_file} �Ɋi�[
        grep -l $REG_EXP `awk '{printf("%s ",$0)}' $spl_file` >> ${spl_file}_grep  &

    done

    wait;

    echo "������""\033[;5m$JCL_DIR\033[;0m""������";
    echo "# ������������������������";


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
    echo "# ������������������������";

    /bin/rm -r $SPLIT_DIR;
done
