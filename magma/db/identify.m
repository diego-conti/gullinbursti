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

load "magma/db/generatorsfromdb.m";
load "magma/hurwitz/computegeneratorsnonabelian.m";

AutGOnConjugacyClasses:=function(groupData,classes)
	Aut:=AutomorphismGroup(groupData`group);
	A,r:=FPGroup(Aut);
	generatorsOfA:=[g: g in Generators(A)];
	generators:=[
  	[_ActionOfAutomorphismOnConjugacyClass(groupData,r(aut),class) : class in classes]
  	 : aut in generatorsOfA
	  ];
	Sigma:=sub<SymmetricGroup(classes) | {g: g in generators}>;	//the sequence of generators is converted into a set to work around some bug of Magma
	n,d:=Explode( IdentifyGroup(Sigma));
	test,f:=IsIsomorphic(Sigma,SmallGroup(n,d));
	return Sigma,A,r,hom<A ->Sigma | [generatorsOfA[i] -> Sigma ! generators[i] : i in [1..#generators]] >;	//a list of arrows g->f(g) is passed rather than a vector with a list of generators to work around another bug in Magma.
end function;

_generatorsFormat:=recformat<
	G,
	classMap,
	d,
	n,
	gens
>;

RefinedPassport:=function(generatorsData,generators)
	return [generatorsData`classMap(g): g in generators];
end function;

/* like the primitive IsConjugate, but also works for multisets*/
_IsMultisetConjugate:=function(G, x,y) 
	O:=Orbit(G,x);
	if y in O then return IsConjugate(G,O,x,y);
	else return false,Identity(G);
	end if;
end function;

_GeneratorsWithSameRefinedPassport:=function(generatorsData)
	M:=[Order(g): g in generatorsData`gens];
	test,generatorsInDb:=generatorsFixedGroupFromDb(generatorsData`G,generatorsData`d,generatorsData`n,M);
	if not test then error "system of generators not found in database, ",generatorsInDb; end if;
	
	groupData:=GroupData(generatorsData`G);
	allConjugacyClassesByOrder:=ConjugacyClassesByOrder(generatorsData`G);
	conjugacyClasses:=&join [allConjugacyClassesByOrder[x] : x in {m: m in M}];
	Sigma,AutG,r,f:=AutGOnConjugacyClasses(groupData,conjugacyClasses);
	
	refinedPassportAsMultiset:={* c: c in RefinedPassport(generatorsData, generatorsData`gens) *};
	for x in generatorsInDb do 
		refinedPassport:=RefinedPassport(generatorsData,x);
		test, g:=_IsMultisetConjugate(Sigma,refinedPassportAsMultiset,{* c : c in refinedPassport *});
		if test then 
			automorphism:=r(g@@f);
			gens:=[automorphism(x): x in generatorsData`gens];
			if 	{* generatorsData`classMap(g): g in gens *} ne {* c : c in refinedPassport *} then
				print "error trying to pass from X=",generatorsData`gens, " to refined passport ",refinedPassport;
				print "refined passport of X is ",RefinedPassport(generatorsData, generatorsData`gens);
				print "element of Sigma",g;
				print Sigma;
				print "automorphism",automorphism;
				print "it acts as ",[_ActionOfAutomorphismOnConjugacyClass(groupData,automorphism,class) : class in conjugacyClasses];
				error "logic error";
  		end if;
			return gens, {D: D in generatorsInDb | RefinedPassport(generatorsData,D) eq refinedPassport};
		end if;
	end for;
	error "refined passport is not in Aut(G)-orbit of one of the refined passports in database";
end function;
	
//given two refined passports D1 and D2, return an element of the free group in r generators which maps D1 to D2
_MatchRefinedPassports:=function(D1,D2)
	sigma:=PermutationMapping(D1,D2);
	r:=#D1;
	freeGroup:=FreeGroup(r-1);
	azionetrecce:=hom<freeGroup->SymmetricGroup(r) | [SymmetricGroup(r) ! (i,i+1) : i in [1..r-1]]>;
	return sigma @@ azionetrecce;
end function;

_IdentifySphericalSystemsOfGeneratorsInConjugacyClasses:=function(groupData,orderedConjugacyClasses,generatorsToIdentify,representatives) 
	local subsetsThatGenerate,subsetsThatDoNotGenerate;
	subsetsThatGenerate:={};
	subsetsThatDoNotGenerate:={};
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
	if IsEmpty(X) then error "no spherical system of generators found in refined passport"; end if;
	hurwitzEquivalenceGroup:=_HurwitzEquivalenceGroup(groupData,X,orderedConjugacyClasses);	
	orbit:=Orbit(hurwitzEquivalenceGroup,generatorsToIdentify);
	for x in representatives do
		if x in orbit then return x; end if;
	end for;
	error "cannot find representative";
end function;


_Identify:=function(generatorsData)
	gens, gensInDb:=_GeneratorsWithSameRefinedPassport(generatorsData);
	if IsEmpty(gensInDb) then error "system of generators not found in database"; end if;
	reorderedRefinedPassport:=RefinedPassport(generatorsData,Rep(gensInDb));	//we assume the refined passport is exactly the same for all entries in gens, not only up to order.
	sigma:=_MatchRefinedPassports(RefinedPassport(generatorsData,gens),reorderedRefinedPassport);
	reorderedGens:=BraidAction(gens,sigma);
	groupData:=GroupData(generatorsData`G);
	return _IdentifySphericalSystemsOfGeneratorsInConjugacyClasses(groupData,reorderedRefinedPassport,reorderedGens,gensInDb);
end function;


IdentifyInDb:=function(generators,group)
	Gd,Gn:=Explode(IdentifyGroup(group));
	smallgroup:=SmallGroup(Gd,Gn);
	test,isomorphism:=IsIsomorphic(group,smallgroup);
	generatorsData:=rec<_generatorsFormat | G:=smallgroup, classMap:=ClassMap(smallgroup), d:=Gd, n:=Gn, gens:=isomorphism(generators)>;
	return _Identify(generatorsData),smallgroup;
//	return (isomorphism^-1)(_Identify(generatorsData));
end function;
