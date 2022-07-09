/***************************************************************************
	Copyright (C) 2021 by Diego Conti, Alessandro Ghigi and Roberto Pignatelli.

	This file is part of gullinbursti.
	Gullinbursti is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
****************************************************************************

This file implements, with minor modifications, Algorithm 1 in [CGP], without excluding he case of 3 branching points and the case where one of the m_r is equal to the order of the group.

This file exposes the following functions:
ComputeSignatures(d,gMax) computes signatures for groups of order d and 1<g<=gMax and stores them on disk.
Signatures(g,r) returns the signatures with genus g and r>=3 branch points, by retrieving the signatures stored by ComputeSignatures
Signatures(g) returns the signatures with genus g, by retrieving the signatures stored by ComputeSignatures

Signatures are represented by a record containing an integer d and a nondecreasing sequence of integers M=[m_1,...,m_r].

Functions with name starting with _ are considered part of the implementation.

if the variable IGNORE_GROUP_ORDERS_NOT_IN_SMALLGROUP_DATABASE is set, then no error is returned when trying to compute signatures with group order exceeding 2000
*/

load "magma/signatures/sequences.m";
load "magma/signatures/persist.m";
load "magma/include/genus.m";

_SIGNATURES_PATH:="signatures";	//a directory where signatures are stored
_HIGHEST_GROUP_ORDER_IN_SMALLGROUP_DATABASE:=2000;

SignatureFormat := recformat< d : Integers(), M : SeqEnum >;

/* Given a list of indices in the sequence of nontrivial divisors of d, convert the list into a signature and add it to the array to contain all signatures

signatures: an array indexed by genus; signatures[g] is a list to contain all signatures of genus g
indexList: nondecreasing sequence of indices 1\leq i_1\leq ...\leq i_h\leq x, where x is the number of nontrivial positive divisors of d
d: the group order being considered
nontrivialDivisors: the sequence of divisors of d greater than 1
*/
_AddByGenus:=procedure(~signatures, indexList,d,nontrivialDivisors)
		sequenceOfDivisors:=[nontrivialDivisors[i] : i in indexList];	//convert index list into a list of divisors
		g:=Genus(sequenceOfDivisors,d);
		maxG:=#signatures;	//signatures is an array indexed by genus, so the size of the array representes the maximum genus
		integral,integerG:=IsCoercible(Integers(),g);
		if integral and integerG gt 0 and integerG le maxG then 
			signature:= rec<SignatureFormat|>;
			signature`d:=d;
			signature`M:=sequenceOfDivisors;
			Append(~(signatures[integerG]),signature);
		end if;
end procedure;

/* Compute signatures for given d,r, and 1<=g<=maxG.
Returns an array whose g-th element is the list of signatures of genus g
*/
_ComputeSignatures_d_r:=function(d,r,maxG)
	result:=[[] : n in [1..maxG]];
	allDivisors:=Divisors(d);
	nontrivialDivisors:=allDivisors[2..#allDivisors];
	sequence:=[1: x in [1..r]];
	while not IsEmpty(sequence) do 
			_AddByGenus(~result,sequence,d,nontrivialDivisors);
			NextSequence(~sequence,#nontrivialDivisors);
	end while;
	return result;
end function;

/* Compute signatures for given d,r, and 1<=g<=maxG and store the result on disk.

Note that g=1 is allowed here because the condition g>2 is only necessary in order to establish a bound on d and r.
 */
_ComputeAndSaveSignatures_d_r:=procedure(d,r,maxG)
	signatures:=_ComputeSignatures_d_r(d,r,maxG);
	PersistToFile(_SIGNATURES_PATH,[d,r],signatures);
end procedure;

_MaxBranchPoints:=function(g,d)
	return Truncate(4*(g-1)/d+4);
end function;
 
_MaxGroupOrder:=function (g,r)
	bound:=12*(g-1);
	if r gt 4 then return Min(bound,Floor(4*(g-1)/(r-4)));
	elif r eq 4 then return bound;
	else return 84*(g-1);
	end if;
end function;

//returns the possible values of d such that there is a curve with when genus g, r=3 branching points and automorphism group of order d
_GroupOrdersForThreeBranchPoints:=function (g)	
//bounds[g] denotes the maximum order of the automorphism group of a curve of genus g, see Conder: Large group actions on surfaces, Appendix 1.
	bounds:=[0,48,168,120,192,150,504,336,320,432,240,120,360,1092,504,720,1344,168,720,228,480,1008,192,216,720,750,624, 1296,672,264,720,372,1536,1320,544,672,1728,444,912,936,960,410,1512,516,1320,2160,384,408,1920,1176,1200,2448,832,456,1296,1320,1344,1368,928, 504,1440,732,1488,1512,3072,1014,576,804,2448,660,672,710,2160,876,1776,1800,912,1176,1872,948,1536,3888,1312,696,4032,1200,2064,712,2640,744,3600, 2184,768,2232,768,3420,3840,1164,2352,1320,2400,1010,4896,1236,2496,2016,1696,888,5184,1308,2640,2664,2688,936,3420,936,1856,9828,960,1734,2880,5808, 2928,1080,1488,1500,3024,1524,10752,3096,2080,1310,3960,1596,3216,6480,2176,1128,1152,1668,2184,1144,1152,1352,6912,12180,3504,3528,2368,1224,3600,812, 3648,2448,1320,1550,3744,1884,3792,1288,3840,1320,3888,1956,2624,6600,1344,1368,8064,4056,2720,6840,2064,1416,1856,3000,2640,1432,2848,1464,8640,2172,4368, 4392,1600,1512,4464,1512,1536,4536,2640,1910,5760,2316,4656,3420,4704,1608,2640,2388,4800,4824,3232,1656,7344,2050,4944,1672,4368,2904,5040,2532,3392,1720, 1728,1800,6480,2604,5232,5256,5280,1800,5328,2676,5376,5400,3616,1848,6840,2748,6072,3276,3712,1896,11232,1896,1920,5688,2176,1944,9600,2892,5808,11664,3904, 4116,2624,2964,5952,2008,12000,2510,6048,12144,6096,4896,12288,2088,6192,3108,4160,3132,2112,2136,7920,2200,6384,2152,3216,2184,5040,3252,4896,6552,4384,3750, 2304,3324,6672,6696,2688,2810,2304,3396,2400,10260,4368,2328,13824,13872,4640,6984,4672,2376,7056,2376,7104,3888,4768,4056,9000];
	return {2..Min(84*(g-1), bounds[g])};
end function;


/* Compute signatures for given d and 1<g \leq maxG and store the result on disk */
ComputeAndSaveSignatures:=procedure(d,maxG)
	for r in [3.._MaxBranchPoints(maxG,d)] do
		_ComputeAndSaveSignatures_d_r(d,r,maxG);
	end for;
end procedure;

/* Retrieve from disk and return the signatures corresponding to g,d,r */
_Signatures_g_d_r:=function(g,d,r)
	if d gt _HIGHEST_GROUP_ORDER_IN_SMALLGROUP_DATABASE then
		if assigned IGNORE_GROUP_ORDERS_NOT_IN_SMALLGROUP_DATABASE then
			return [];
		else
			error "Cannot retrieve signatures for g,d,r equal to ",g,d,r,", as database of small groups only goes up to order 2000";
		end if;	
   	signatures_d_r:=ReadFromFile(_SIGNATURES_PATH,[d,r]);
   	if g gt #signatures_d_r then
     		error "signatures only computed up to g=",#signatures_d_r;
   	end if;
   	return signatures_d_r[g];
end function;

/* Retrieve from disk and return signatures of genus g>1 */
Signatures:=function(g)
	if g le 1 then error "Signatures invoked with g=",g, ", g>1 expected"; end if;
	signatures:=[];
	for d in _GroupOrdersForThreeBranchPoints(g) do
		signatures cat:=  _Signatures_g_d_r(g,d,3);
	end for;
	for d in [2..12*(g-1)]  do
     for r in [4.._MaxBranchPoints(g,d)] do
     		signatures cat:=  _Signatures_g_d_r(g,d,r);
     end for;
	end for;
	return signatures;
end function;

/* Retrieve from disk and return signatures of genus g with r>=3 branch points*/
Signatures_g_r:=function(g,r)
	if g le 1 then error "Signatures_g_r invoked with g=",g, ", g>1 expected"; end if;
	signatures:=[];
	if r eq 3 then 
		for d in _GroupOrdersForThreeBranchPoints(g) do
			signatures cat:=  _Signatures_g_d_r(g,d,3);
		end for;
	elif r gt 3 then 
		for d in [2.._MaxGroupOrder(g,r)]  do
   		signatures cat:=  _Signatures_g_d_r(g,d,r);
		end for;
	else
		error "Signatures_g_r invoked with r=",r,", r>=3 expected";
	end if;
	return signatures;
end function;


