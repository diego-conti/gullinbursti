for csv in  $(ls test/longtest/*.csv); do
	rm test/longtest/generatori/*
	bin/hliðskjálf --input=$csv --output=test/longtest/generatori --nthreads=30 --memory 2 --ignore-known-examples --db ""
	bin/hliðskjálf --input=$csv --output=test/longtest/generatori --nthreads=6 --memory 10 --ignore-known-examples --db ""
	bin/hliðskjálf --input=$csv --output=test/longtest/generatori --nthreads=2 --memory 30 --ignore-known-examples --db ""
	magma -b directory:=test/longtest/generatori test/magma/testnumerovettorigeneratori.m >test/longtest/numerovettorigeneratori.unsorted
	sort test/longtest/numerovettorigeneratori.unsorted >test/longtest/numerovettorigeneratori`basename $csv .csv`.test
done

for csv in  $(ls test/longtest/*.csv); do
	rm test/longtest/generatori/*
	bin/hliðskjálf --input=$csv --output=test/longtest/generatori --nthreads=30 --memory 2 --ignore-known-examples --db "" --only-test-coleman-oort=testVersion
	bin/hliðskjálf --input=$csv --output=test/longtest/generatori --nthreads=6 --memory 10 --ignore-known-examples --db "" --only-test-coleman-oort=testVersion
	bin/hliðskjálf --input=$csv --output=test/longtest/generatori --nthreads=2 --memory 30 --ignore-known-examples --db "" --only-test-coleman-oort=testVersion
	magma -b directory:=test/longtest/generatori test/magma/testnumerovettorigeneratori.m >test/longtest/numerovettorigeneratori.unsorted
	sort test/longtest/numerovettorigeneratori.unsorted >test/longtest/numerovettorigeneratori`basename $csv .csv`.co.test
done

for out in $(ls test/longtest/*.ok); do
	file_to_check=`basename $out .ok`
	diff test/longtest/$file_to_check.test test/longtest/$file_to_check.ok
	if [ $? -eq 0 ]; then echo $file_to_check OK;
          else echo $file_to_check ERROR; fi
done

