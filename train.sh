#! /bin/bash

show()
{
    YEAR=${DATE:0:4}
    MON=${DATE:4:2}
    DAY=${DATE:6:2}
    
    TMPFILE=/tmp/train.tmp
    echo > $TMPFILE
    curl http://dynamic.12306.cn/TrainQuery/iframeLeftTicketByStation.jsp -d lx=00 -d nyear3=$YEAR -d nyear3_new_value=true -d nmonth3=$MON -d nmonthe3_new_value=true -d nday3=$DAY --data-urlencode startStation_ticketLeft=$START --data-urlencode arriveStation_ticketLeft=$TO -d nday3_new_value=true -d startStation_ticketLeft_new_value=true -d arriveStation_ticketLeft_new_value=true -d trainCode=$TRAINCODE -d trainCode_new_value=true -d rFlag=1 -d name_ckball=value_ckball -d tFlagT=T -d tFlagZ=Z -d tFlagDC=DC -d tFlagK=K -d tFlagPK=PK -d tFlagQT=QT -m 10 2>/dev/null | grep -v "//" | grep addRow > $TMPFILE
    echo -ne $YEAR$MON$DAY $START "至" $TO "\n"
    echo -ne  "车次\t发点\t到点\t无座\t硬座\t软座\t硬卧\t软卧\t高级软卧\n" 
    while read myline
    do
        RET=$myline
        TTYPE="`echo $RET | cut -d ',' -f 3 | cut -d "(" -f 1`"
        TTYPE=${TTYPE:0:1}
        echo $RET | cut -d ',' -f 3 | cut -d "(" -f 1 | tr "\n" "\t"
        echo $RET | cut -d ',' -f 6 | tr "\n" "\t"
        echo $RET | cut -d ',' -f 7 | tr  "\n" "\t"
        if [[ "$TTYPE" == "D" || "$TTYPE" == "C" || "$TTYPE" == "G" ]] ; then
            echo $RET | cut -d ',' -f 16 | tr "\n" "\t"
            echo $RET | cut -d ',' -f 14 | tr  "\n" "\t"
            echo $RET | cut -d ',' -f 13 | tr  "\n" "\t"
            echo $RET | cut -d ',' -f 11 | tr  "\n" "\t"
            echo $RET | cut -d ',' -f 12 | tr  "\n" "\t"
            echo $RET | cut -d ',' -f 15 | tr  "\n" "\t"
        else
            echo $RET | cut -d ',' -f 16 | tr "\n" "\t"
            echo $RET | cut -d ',' -f 9 | tr "\n" "\t" | tr -d ' '
            echo $RET | cut -d ',' -f 10 | tr  "\n" "\t" | tr -d ' '
            echo $RET | cut -d ',' -f 11 | tr  "\n" "\t"
            echo $RET | cut -d ',' -f 12 | tr  "\n" "\t"
            echo $RET | cut -d ',' -f 15 | tr  "\n" "\t"
        fi
        echo -en "\n"
    done < $TMPFILE
}

prompt()
{    
    YEAR=${DATE:0:4}
    MON=${DATE:4:2}
    DAY=${DATE:6:2}

    read -p "Command (npcwstq):" COMMAND
    case $COMMAND in
        p)
            DATE=`date -d "$DATE -1day" "+%Y%m%d"`
            ;;
        n)
            DATE=`date -d "$DATE +1day" "+%Y%m%d"`
            ;;
        c)
            read -p "限定车次:" TRAINCODE
            ;;
        s)
            read -p "更改发站:" START
            ;;
        t) 
            read -p "更改到站:" TO
            ;;
        w)
            TEMP=$TO
            TO=$START
            START=$TEMP
            ;;

        q)
            exit 0
            ;;
        *)
            DATE=$COMMAND
            process_date
            ;;
    esac
    show
}

process_date()
{
    TODAY=`date "+%Y%m%d"`
    YEAR=${TODAY:0:4}
    MON=${TODAY:4:2}
    DAY=${TODAY:6:2}

    if [ -z $DATE ] ; then
        DATE=$TODAY
    elif [ `expr length $DATE` -eq 4 ] ; then
        MON=${DATE:0:2}
        DAY=${DATE:2:2}
        echo $DAY
    elif [ $DATE -lt $DAY ] ; then
        MON=`date -d "$YEAR-${MON}-15 +1 month" "+%m"`
        DAY=$DATE
    elif [ $DATE -ge $DAY ]; then
        DAY=$DATE
    fi
    
    if [ `expr length $DAY` -eq 1 ] ; then
        DAY=`echo 0$DAY`
    fi
    
    DATE=`echo $YEAR$MON$DAY`
    DATE=`date -d $DATE "+%Y%m%d"`
}

read -p "日期:" DATE
read -p "起始站:" START
read -p "到达站:" TO
read -p "车次:" TRAINCODE
process_date
show
while true ; do
    prompt
done
