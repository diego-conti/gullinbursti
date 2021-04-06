magma -b minG:=3 maxG:=4 outFile:=test/segnature.test magma/createlistofcomputations.m
sort test/segnature.test >test/segnature34.test
magma -b minG:=10 maxG:=10 outFile:=test/segnature.test magma/createlistofcomputations.m
sort test/segnature.test >test/segnature10.test
magma -b minG:=60 maxG:=60 outFile:=test/segnature.test magma/createlistofcomputations.m
sort test/segnature.test >test/segnature60.test
rm test/segnature.test

for csv in  $(ls test/*.csv); do
	rm test/generatori/*
	bin/hliðskjálf --input=$csv --output=test/generatori --nthreads=30 --memory 2 --ignore-known-examples --db ""
	magma -b directory:=test/generatori test/magma/testnumerovettorigeneratori.m >test/numerovettorigeneratori.unsorted
	sort test/numerovettorigeneratori.unsorted >test/numerovettorigeneratori`basename $csv .csv`.test 
done

for csv in  $(ls test/*.csv); do
	rm test/generatori/*
	bin/hliðskjálf --input=$csv --output=test/generatori --nthreads=30 --memory 2 --ignore-known-examples --db "" --only-test-coleman-oort=testVersion
	magma -b directory:=test/generatori test/magma/testnumerovettorigeneratori.m >test/numerovettorigeneratori.unsorted
	sort test/numerovettorigeneratori.unsorted >test/numerovettorigeneratori`basename $csv .csv`.co.test 
done



for out in $(ls test/*.ok); do
	file_to_check=`basename $out .ok`
	diff test/$file_to_check.test test/$file_to_check.ok
	if [ $? -eq 0 ]; then echo $file_to_check OK;
          else echo $file_to_check ERROR; fi
done

