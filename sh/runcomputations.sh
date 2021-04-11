cd `dirname $0`/..
computations=100	#number of computations to be performed by each magma process
nthreads=$2
let memory=$3/$nthreads
mkdir -p co
hliðskjálf --computations $1 --valhalla bad.csv --script magma/runcomputation.m --workload $computations --schema schema.info --nthreads $nthreads --memory $memory --workoutput generators
while [ $nthreads -gt 1 ] && [ -f bad.csv ] 
#run again the computations that did not complete because memory ran out, increasing the memory limit and decreasing the number of threads
do
	rm bad.csv
	let nthreads=nthreads/2
	let memory=memory*2
	hliðskjálf --computations $1 --valhalla bad.csv --script magma/runcomputation.m --workload $computations --schema schema.info --nthreads $nthreads --memory $memory --workoutput generators
done
