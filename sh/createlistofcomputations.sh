cd `dirname $0`/..
magma -b maxG:=20 outFile:=2-20.comp magma/createlistofcomputations.m
magma -b minG:=21 maxG:=30 outFile:=21-30.comp magma/createlistofcomputations.m
for g in {31..40}
do
	magma -b minG:=$g maxG:=$g outFile:=$g.comp magma/createlistofcomputations.m
done

