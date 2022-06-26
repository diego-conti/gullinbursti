# Gullinbursti

A [Magma](http://magma.maths.usyd.edu.au/magma/) program to classify topological types of Galois coverings of the projective line.
 
The algorithm is explained in

[CGP] D. Conti, A. Ghigi, R. Pignatelli. Topological types of actions on curves [????](http://arxiv.org/abs/2102.12349)

[CGP2] D. Conti, A. Ghigi, R. Pignatelli. Some evidence for the Coleman-Oort conjecture. [arXiv:2102.12349](http://arxiv.org/abs/2102.12349)

If you use this code in your research, please quote our papers!

Partly based on [https://pignatelli.maths.unitn.it/papers/RegP-QByPgGamma.magma](https://pignatelli.maths.unitn.it/papers/RegP-QByPgGamma.magma) and [centone](https://github.com/diego-conti/centone)

### Main Magma scripts
The program contains four main Magma scripts:

### magma/computesignatures.m
Computes the admissible signatures and stores them on disk, in the directory signatures

### magma/createlistocomputations.m
Creates a list of computations to be passed to the main script

### magma/runcomputation.m
Main script that iterates through signatures, looking for counterexamples. The output is a CSV file where each line takes the following form:

	d;n;M;time;memory;algorithm;generators

* _d_ group order
* _n_ group number
* _M_ signature
* _time_ computation time in seconds
* _memory_ maximum memory usage in MB
* _algorithm_ string identifying the algorithm version
* _generators_ One of the following:
    * {I:reason} if computation was skipped; the string _reason_ then identifies the criterion used to exclude it;
    * {} if no spherical system of generators was found
    * otherwise, a list of spherical systems of generators, one in each orbit (i.e. each corresponding to a different topological type)

### magma/printgenerators.m
Print all topological types that have been computed

### Utilities
The program also contains the following Magma scripts:

### magma/db/generatorsfromdb.m
Retrieve the computed generators from a 'database'. The database is a folder with some plain-text file produced by the utility [yggdrasill](https://github.com/diego-conti/hlidskjalf).

### magma/db/identify.m
Identifies the entry in our database corresponding to a given system of spherical generator

## Bash scripts
The sh directory contains some bash scrips that invoke the Magma scripts with example parameters. These scripts employ awk and GNU parallel, and they have been tested on CentOS Linux 7. They should be run in the order in which they appear here:

###	sh/computesignatures.sh
Computes signatures up to d=2000, using GNU parallel to parallelize the computation

### sh/createlistofcomputations.sh
Creates some lists of computations, corresponding to 2<=g<=20, 21<=g<=30, and each value of g between 31 and 40.

### sh/runcomputations.sh
Runs the main script through a list of computations using a single process

For example, run 

	sh/runcomputations.sh 2-20.comp 
	
to compute topological types with 2<=g<=20.

### Hliðskjálf integration

The main script is designed to be run from [Hliðskjálf](https://github.com/diego-conti/hlidskjalf), to handle parallelization efficiently, e.g.

	hliðskjálf --schema schema.info --db db --computations 2-20.comp --script magma/runcomputation.m 
	yggdrasill --schema schema.info --db db --workoutput 2-20
	
This has the effect of computing (in parallel) all topological types corresponding to genus between 2 and 20, and updating the 'database' in the folder db. 
