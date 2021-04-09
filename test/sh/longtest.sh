for comp in  $(ls test/longtest/*.comp); do
	rm test/longtest/generatori/*
	hliðskjálf --script=magma/runcomputation.m --schema schema.info --computations=$comp --workoutput=test/longtest/generatori --nthreads=30 --memory 2	
	hliðskjálf --script=magma/runcomputation.m --schema schema.info --computations=$comp --workoutput=test/longtest/generatori --nthreads=6 --memory 10
	hliðskjálf --script=magma/runcomputation.m --schema schema.info --computations=$comp --workoutput=test/longtest/generatori --nthreads=2 --memory 30
	magma -b path:=test/longtest/generatori magma/printgenerators.m >test/longtest/vettorigeneratori.unprocessed
	awk 'BEGIN {ORS = "\t"} {switch ($1) { case "Generators:" : print "Generators: [...]"; break; case "g:" : ORS = "\n"; print; ORS = "\t"; break; case "Loading" : break; default: print }}' test/longtest/vettorigeneratori.unprocessed  | sort 	>test/longtest/vettorigeneratori`basename $comp .comp`.test 
	rm test/longtest/vettorigeneratori.unprocessed 
done

for out in $(ls test/longtest/*.ok); do
	file_to_check=`basename $out .ok`
	diff test/longtest/$file_to_check.test test/longtest/$file_to_check.ok
	if [ $? -eq 0 ]; then echo $file_to_check OK;
          else echo $file_to_check ERROR; fi
done

