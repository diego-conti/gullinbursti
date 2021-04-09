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

_AddIfSphericalSystemsOfGeneratorsInConjugacyClasses:=procedure(conjugacyClasses,groupData,~subsetsThatGenerate,~subsetsThatDoNotGenerate,~generators) 
	local subsetGenerates;
	G:=groupData`group;	
	v:=[ClassRepresentative(G,C) : C in conjugacyClasses];
	if IsId(&*v) then		
		DetermineWhetherSubsetGenerates({g : g in v},G,~subsetsThatGenerate,~subsetsThatDoNotGenerate,~subsetGenerates);
		if subsetGenerates then	
			Include(~generators, v);
		end if;
	end if;
end procedure;
	
FindGeneratorsAbelian:=function(G,M)
	subsetsThatGenerate:={};
	subsetsThatDoNotGenerate:={};
	generators:={};
	groupData:=GroupData(G);
	allConjugacyClassesByOrder:=ConjugacyClassesByOrder(G);
	conjugacyClasses:=&join [allConjugacyClassesByOrder[x] : x in {m: m in M}];
	setsAndMultiplicities:=SetsAndMultiplicities(M,allConjugacyClassesByOrder);
	IterateOverMultisetsWithCommonUnderlyingSet(setsAndMultiplicities, [], AutGOnConjugacyClasses(groupData,conjugacyClasses), _AddIfSphericalSystemsOfGeneratorsInConjugacyClasses, _FlushKnownGeneratingSets, groupData,  ~subsetsThatGenerate, ~subsetsThatDoNotGenerate, ~generators);
	return generators;
end function;	



	
	
