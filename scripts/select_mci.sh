# Имя МЦИ, которое надо выгрузить
nameMCI=$@

# Select для доп информации
/opt/firebird/bin/isql -sql_dialect 1 -u kpo -p kpo301 192.168.16.195:/archive/kpm/KIVK_CM_2024/TestStandKPI/DB/MIS/bdCM.gdb <<< "set heading on;select ABONENT,NAMEMCI,NAMESP,NPAKET,NWORD,PAKET,ROAD from arhmci WHERE NAMEMCI = '${nameMCI}';"

# Находим айдишники блобов
output=$(/opt/firebird/bin/isql -sql_dialect 1 -u kpo -p kpo301 192.168.16.195:/archive/kpm/KIVK_CM_2024/TestStandKPI/DB/MIS/bdCM.gdb <<< "set heading off;set blob off;select CODMCI,FORMA1 from arhmci WHERE NAMEMCI = '${nameMCI}';")
line=$(echo "$output" | tr -d '\n' | sed 's/^[ \t]*//;s/[ \t]*$//;s/[ \t]+/ /g')
set -- $line
blobCodes=$1
blobDoc=$2

# Дамп блобов в айдишникам
/opt/firebird/bin/isql -sql_dialect 1 -u kpo -p kpo301 192.168.16.195:/archive/kpm/KIVK_CM_2024/TestStandKPI/DB/MIS/bdCM.gdb <<< "blobdump ${blobCodes} ${nameMCI}_CODES.txt; blobdump ${blobDoc} ${nameMCI}_DOC.txt;"

fileName=${nameMCI}_DOC.txt
iconv -f iso8859-5 -t utf8 $fileName -o $fileName
