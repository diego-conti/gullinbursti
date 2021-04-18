magma -b minG:=3 maxG:=4 outFile:=test/segnature.test magma/createlistofcomputations.m
sort test/segnature.test >test/segnature34.test
magma -b minG:=10 maxG:=10 outFile:=test/segnature.test magma/createlistofcomputations.m
sort test/segnature.test >test/segnature10.test
magma -b minG:=60 maxG:=60 outFile:=test/segnature.test magma/createlistofcomputations.m
sort test/segnature.test >test/segnature60.test
rm test/segnature.test

for comp in  $(ls test/comp/*.comp); do
	rm test/generatori/*
	hliðskjálf --script=magma/runcomputation.m --schema schema.info --computations=$comp --workoutput=test/generatori --nthreads=30 --total-memory 60 --stdio
	magma -b path:=test/generatori magma/printgenerators.m >test/vettorigeneratori.unprocessed
	awk 'BEGIN {ORS = "\t"} {switch ($1) { case "Generators:" : print "Generators: [...]"; break; case "g:" : ORS = "\n"; print; ORS = "\t"; break; case "Loading" : break; default: print }}' test/vettorigeneratori.unprocessed  | sort 	>test/numerovettorigeneratori`basename $comp .comp`.test 
	rm test/vettorigeneratori.unprocessed 
done


for out in $(ls test/*.ok); do
	file_to_check=`basename $out .ok`
	diff test/$file_to_check.test test/$file_to_check.ok
	if [ $? -eq 0 ]; then echo $file_to_check OK;
          else echo $file_to_check ERROR; fi
done

