cd `dirname $0`/..
computations=100	#number of computations to be performed by each magma process
nthreads=$2
hliðskjálf --computations $1 --valhalla bad.csv --script magma/runcomputation.m --workload $computations --schema schema.info --nthreads $nthreads --memory 128 --total-memory $3 --workoutput generators

