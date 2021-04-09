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

*/

load "magma/include/genus.m";
load "magma/include/sequences.m";
load "magma/include/sequencesuptoaction.m";
load "magma/include/subsetgenerates.m";
load "magma/hurwitz/scott.m";
load "magma/hurwitz/hurwitzmoves.m";
load "magma/hurwitz/refinedpassports.m";
	
//for a given a sequence of sets [X_1,...,X_r], add to generators sequences [g_1,...,g_r] of spherical systems of generators with g_1\in X_1, ... , g_r\in X_r
AddSphericalSystemsOfGeneratorsIn:=procedure(groupData,sets,~addIfGenerates, ~subsetsThatGenerate,~subsetsThatDoNotGenerate,~generators)
	lastSet:=sets[#sets];
	IterateOverSequencesIn(Prune(sets),~addIfGenerates,lastSet,~subsetsThatGenerate,~subsetsThatDoNotGenerate,~generators);
end procedure;


//given a group G and a multiset of conjugacy classes, return the stabilizer of the multiset inside Aut(G)
AutomorphismsPreservingConjugacyClasses:=function(G, conjugacyClasses)
		AutG:=AutomorphismGroup(G);
		r,A:=PermutationRepresentation(AutG);
		CM:=ClassMap(G);
		X:={1..Nclasses(G)};
		f:=map<CartesianProduct(X,A) -> X | xAndA :-> CM((r^-1)(xAndA[2])(ClassRepresentative(G,xAndA[1])))>;
		Y:= Orbit(A,GSet(A,X,f),conjugacyClasses);
		stabilizer:=Stabilizer(A,Y,conjugacyClasses);
		return sub<AutG | [(r^-1)(g): g in Generators(stabilizer)]>;
end function;

//given two sequences [x_1,..,x_r], [y_1,..,y_r] with the same underlying multiset, give a permutation sigma such that x_sigma_i=y_i
PermutationMapping:=function(sequence1, sequence2)	
	if #sequence1 ne #sequence2 then error sequence1, sequence2, "do not have the ame number of elements"; end if;
	sigma:=[];
	for x in sequence1 do
		i:=Index(sequence2,x);
		while i in sigma do	
			i:=Index(sequence2,x,i+1); 
		end while;
		if i eq 0 then error sequence1, "is not a permutation of ", sequence2; end if;
		Append(~sigma,i);
	end for;
	return SymmetricGroup(#sequence1) ! sigma;
end function;

_AutomorphismAppliedToConjugacyClass:=function(groupData,automorphism,class)
		rep:=ClassRepresentative(groupData`group, class);		
		return groupData`classMap(automorphism(rep));
end function;

//given an automorphism f of G and r conjugacy classes in G return a word h in the free group on r-1 generators such that, letting the free group act as braids, (g,h) preserves the conjugacy classes.
_AutomorphismAsBraid:=function(groupData,conjugacyClasses, f)
	imagesOfConjugacyClasses:=[_AutomorphismAppliedToConjugacyClass(groupData,f,C): C in conjugacyClasses];
	sigma:=PermutationMapping(imagesOfConjugacyClasses,conjugacyClasses);
	r:=#conjugacyClasses;
	freeGroup:=FreeGroup(r-1);
	azionetrecce:=hom<freeGroup->SymmetricGroup(r) | [SymmetricGroup(r) ! (i,i+1) : i in [1..r-1]]>;
	return sigma @@ azionetrecce;
end function;	
	

//given the set X of spherical systems of generators inside fixed conjugay classes, return the images in Perm(X) of a set of generators for Aut(G)
_GeneratorsOfAutG:=function(groupData,X,conjugacyClasses)
	generators:=[];
	stabilizerInAutG:=AutomorphismsPreservingConjugacyClasses(groupData`group, {* C: C in conjugacyClasses *});		
	for g in Generators(stabilizerInAutG) do 
		h:=_AutomorphismAsBraid(groupData,conjugacyClasses,g);
		Include(~generators,SymmetricGroup(X) ! [BraidAction(x	@g,h) : x in X]);
	end for;
	return generators;
end function;

//given the set X of spherical systems of generators inside fixed conjugay classes, determine the subgroup of the product of Aut(G) and the subgroup of the braid group that preserves X, and return it as a group of permutations of X. Orbits of this group represent Hurwitz equivalence classes.
_HurwitzEquivalenceGroup:=function(groupData,X,conjugacyClasses)
		r:=#conjugacyClasses;
		actionOfGeneratorsOfAutG:=_GeneratorsOfAutG(groupData,X,conjugacyClasses);
		preservingClasses:={i : i in [1..r-1] | conjugacyClasses[i] eq conjugacyClasses[i+1]};
		generatorsOfImpureBraids:=[SymmetricGroup(X) ! [HurwitzMove(x,i) : x in X] : i in preservingClasses];
		generatorsOfPureBraids:=[SymmetricGroup(X) ! [PureBraid(x,i,j) : x in X] : i in [1..r-1], j in [2..r] | i lt j and conjugacyClasses[i] ne conjugacyClasses[j]];
		return PermutationGroup< X | actionOfGeneratorsOfAutG cat generatorsOfImpureBraids cat generatorsOfPureBraids>;
end function;

_ConjugacyClassesAsSets:=function(groupData,conjugacyClasses)
	G:=groupData`group;
	return [Class(G,ClassRepresentative(G,i)) : i in conjugacyClasses];
end function;

_AddSphericalSystemsOfGeneratorsInConjugacyClasses:=procedure(groupData,orderedConjugacyClasses,~subsetsThatGenerate,~subsetsThatDoNotGenerate,~generators) 

	AddIfShortSequenceGenerates:=procedure(v,lastSet,~subsetsThatGenerate,~subsetsThatDoNotGenerate,~generators)
		local subsetGenerates;
		lastElement:=(&*v)^-1;		
		if lastElement in lastSet then 
			DetermineWhetherSubsetGenerates({g : g in v},groupData`group,~subsetsThatGenerate,~subsetsThatDoNotGenerate,~subsetGenerates);
			if subsetGenerates then	
				Include(~generators, Append(v,lastElement));
			end if;
		end if;
	end procedure;
		
	X:={};
	conjugacyClassesAsSets:=_ConjugacyClassesAsSets(groupData,orderedConjugacyClasses);
	AddSphericalSystemsOfGeneratorsIn(groupData,conjugacyClassesAsSets,~AddIfShortSequenceGenerates,~subsetsThatGenerate,~subsetsThatDoNotGenerate,~X);
	if IsEmpty(X) then return; end if;
	hurwitzEquivalenceGroup:=_HurwitzEquivalenceGroup(groupData,X,orderedConjugacyClasses);
	generators join:={orbitSizeAndRepresentative[2] : orbitSizeAndRepresentative in OrbitRepresentatives(hurwitzEquivalenceGroup)};
end procedure;

_OrderedConjugacyClasses:=function(dataToComputeGenerators,conjugacyClasses) 
	k:=0;
	for class in MultisetToSet(conjugacyClasses) do
		size:=dataToComputeGenerators`classSizes[class];	
		if size gt k then 
			biggest:=class;
			k:=size;
		end if;
	end for;				
	return [class : class in conjugacyClasses | class ne biggest ] cat [biggest : i in [1..Multiplicity(conjugacyClasses,biggest)]];
end function;

_AddSphericalSystemsOfGeneratorsInConjugacyClassesIfTest:=procedure(conjugacyClasses,groupData,~subsetsThatGenerate,~subsetsThatDoNotGenerate,~generators)
 if FrobeniusSum(groupData`characterTable,conjugacyClasses) ne 0 and ScottTest(conjugacyClasses,groupData`gModulesData) then
		orderedConjugacyClasses:=_OrderedConjugacyClasses(groupData,conjugacyClasses);
		_AddSphericalSystemsOfGeneratorsInConjugacyClasses(groupData, orderedConjugacyClasses, ~subsetsThatGenerate, ~subsetsThatDoNotGenerate, ~generators);
	end if;
end procedure;

_FlushKnownGeneratingSets:=procedure(groupData,~subsetsThatGenerate,~subsetsThatDoNotGenerate,~generators)
	if not IsEmpty(subsetsThatDoNotGenerate) then
		print "flushing", #subsetsThatGenerate, #subsetsThatDoNotGenerate;
	end if;
	subsetsThatGenerate:={};
	subsetsThatDoNotGenerate:={};	
end procedure;


FindGeneratorsNonabelian:=function(G,M)
	subsetsThatGenerate:={};
	subsetsThatDoNotGenerate:={};
	generators:={};
	groupData:=GroupData(G);
	allConjugacyClassesByOrder:=ConjugacyClassesByOrder(G);
	conjugacyClasses:=&join [allConjugacyClassesByOrder[x] : x in {m: m in M}];
	setsAndMultiplicities:=SetsAndMultiplicities(M,allConjugacyClassesByOrder);
	IterateOverMultisetsWithCommonUnderlyingSet(setsAndMultiplicities, [], AutGOnConjugacyClasses(groupData,conjugacyClasses), _AddSphericalSystemsOfGeneratorsInConjugacyClassesIfTest, _FlushKnownGeneratingSets, groupData,  ~subsetsThatGenerate, ~subsetsThatDoNotGenerate, ~generators);
		return generators;
end function;	



