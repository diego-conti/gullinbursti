for file in db/*; do awk -v file=`basename $file` -F ';' '{if ($3!="{}"){print file ";" $1 ";" $2 ";" $3}}' $file ; done > all.txt
magma file:="all.txt" example/count.m
