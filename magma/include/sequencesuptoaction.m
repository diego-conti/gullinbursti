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
	Functions to iterate through multisets taken up to the action of a group.
*/

AddToSetAndMultiplicity:=function(setsAndMultiplicities, set, multiplicity)
	return Append(setsAndMultiplicities,[* set,multiplicity *]);
end function;

OrbitRepresentativesAndStabilizers:=function(X,H)
		asGSet:=GSet(H,X);
		representatives:=[Rep(O) : O in Orbits(H,asGSet)];
		return [ [* B, Stabilizer(H,asGSet,B) *] : B in representatives];
end function;

	
	
forward IterateOverMultisetsWithElementsIn;

//Given a sequence of sets and multiplicities, [ [* A_1, n_1*], ..., [* A_k, n_k *] ], where the A_i are disjoint and the n_i nonnegative, and a group H acting on every A_i, invoke f(X,argA,~arg1,~arg2,~arg3) as X ranges in a section for the action of H on the set of all multisets with n_1 elements in A_1, ..., n_k elements in A_k.
IterateOverMultisets:=procedure(setsAndMultiplicities, multiset,H,f,argA,~arg1,~arg2,~arg3)
	if IsEmpty(setsAndMultiplicities) then f(multiset,argA,~arg1,~arg2,~arg3);
	else 
		lastSet,multiplicityOfLastSet:=Explode(setsAndMultiplicities[#setsAndMultiplicities]);
		withoutLastSet:=Prune(setsAndMultiplicities);
		if multiplicityOfLastSet eq 0 then $$(withoutLastSet,multiset,H,f,argA,~arg1,~arg2,~arg3);
		elif #lastSet eq 1 then 		//H fixes lastSet={x}, so Stab x=H
			$$(withoutLastSet,Include(multiset,Rep(lastSet)^^multiplicityOfLastSet),H,f,argA,~arg1,~arg2,~arg3);			
		else IterateOverMultisetsWithElementsIn(lastSet,multiplicityOfLastSet,withoutLastSet,multiset,H,f,argA,~arg1,~arg2,~arg3);
		end if;
	end if;
end procedure;

//Helper function for IterateOverMultisets which iterates through subsets of A taken up to H action
IterateOverMultisetsWithElementsIn:=procedure(A,n,setsAndMultiplicities, multiset,H,f,argA,~arg1,~arg2,~arg3)
	for k in [1..Min(n,#A)] do 
		for subsetAndStabilizer in OrbitRepresentativesAndStabilizers(Subsets(A,k),H) do
			B,stabB:=Explode(subsetAndStabilizer);
			IterateOverMultisets(AddToSetAndMultiplicity(setsAndMultiplicities,B,n-k),multiset join SetToMultiset(B),stabB,f,argA,~arg1,~arg2,~arg3); 
		end for;
	end for;
end procedure;

IterateOverMultisetsWithCommonUnderlyingSet:=procedure(setsAndMultiplicities,reducedSets,H,f,onChanged,argA,~arg1,~arg2,~arg3)
	if IsEmpty(setsAndMultiplicities) then 
		underlyingSet:=SetToMultiset(&join ({set[1] : set in reducedSets }));
		IterateOverMultisets(reducedSets,underlyingSet,H,f,argA,~arg1,~arg2,~arg3);
		onChanged(argA,~arg1,~arg2,~arg3);
		return;
	end if;
	lastSet,multiplicityOfLastSet:=Explode(setsAndMultiplicities[#setsAndMultiplicities]);
	for k in [1..Min(multiplicityOfLastSet,#lastSet)] do
		for subsetAndStabilizer in OrbitRepresentativesAndStabilizers(Subsets(lastSet,k),H) do
			B,stabB:=Explode(subsetAndStabilizer);				
			$$(Prune(setsAndMultiplicities),AddToSetAndMultiplicity(reducedSets,B,multiplicityOfLastSet-#B),stabB,f,onChanged,argA,~arg1,~arg2,~arg3);
		end for;
	end for;
end procedure;

SetsAndMultiplicities:=function(mu,setFromIndex)
	setsAndMultiplicities:= [];
	k:=1;
	while k le #mu do 	
		h:=k+1;
		m:=mu[k];
		while h le #mu and mu[h] eq m do
			h+:=1;
		end while;
		Append(~setsAndMultiplicities,[* setFromIndex[m], h-k *]);
		k:=h;
	end while;
	return setsAndMultiplicities;
end function;


