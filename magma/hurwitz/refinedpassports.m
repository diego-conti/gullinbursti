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

This file contains some functions which are used both by the generic version of the algorithm (computegeneratorsnonabelian.m) and the version optimized for abelian groups (computegeneratorsabelian.m)
*/
load "magma/include/generalizeddihedral.m";

_groupDataFormat:=recformat<group,classMap,classSizes,gModulesData,characterTable,lastOrder,signatureElementsWithLastOrder,dihedral>;

//immutable data used in the computation of generators
GroupData:=function(G)
	return rec<_groupDataFormat | group:=G,classMap:=ClassMap(G),
		classSizes:=[#Conjugates(G,ClassRepresentative(G,i)) : i in [1..Nclasses(G)]],
		gModulesData:=GModulesData(G),characterTable:=CharacterTable(G), dihedral:=IsDihedral(G)
	>;
end function;

/* return an associative array mapping an integer m to the set of conjugacy classes in G with order m*/
ConjugacyClassesByOrder:=function(G)
		result:=AssociativeArray();
		for class in [1..Nclasses(G)] do
			order:=Order(ClassRepresentative(G,class));
			if not IsDefined(result,order) then result[order]:={}; end if;
			Include(~result[order],class);
		end for;
		return result;
end function;

_ActionOfAutomorphismOnConjugacyClass:=function(groupData,automorphism,class)
		representative:=ClassRepresentative(groupData`group, class);		
		return groupData`classMap(automorphism(representative));
end function;

/* given a set of conjugacy classes, return a group of permutations of the set that acts in the same way as Aut(G) */
AutGOnConjugacyClasses:=function(groupData,classes)
	G:=groupData`group;
	AutG:=AutomorphismGroup(G);
	generators:=[
  	[_ActionOfAutomorphismOnConjugacyClass(groupData,aut,class) : class in classes]
  	 : aut in Generators(AutG)
	  ];
	Sigma:=PermutationGroup<classes|generators>;
	return Sigma;
end function;

FrobeniusSum:=function(characterTable,refinedPassport);
	return &+[
							(1/character[1])^(#refinedPassport-2)* &*[character[class] : class in refinedPassport]
							: 
							character in characterTable 
						];
end function; 


