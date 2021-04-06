/*************************************************************************
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

	Functions to verify the Scott inequality
	
	GModulesData(G) returns a list of data on irreducible G-gmodules, to be cached and passed as an argument in subsequent calls to ScottTest
	ScottTest(conjugacyClasses,gModulesData) verifies whether a given choice of conjugacy classes verifies the Scott inequality.
	
	The G-modules considered are over a finite field of order p, where p is the least prime greater than ord(G).
*/

_ModuleDimension:=function(module)
	return #Generators(module);
end function;
	
_DimensionOfFixedPointSet:=function(module)
	return _ModuleDimension(Fix(module));
end function;

_GModuleDataFormat:=recformat<vG,vGstar,vg>;
_GModuleData:=function(G,module)
	R:=Representation(module);
	ambientSpaceDimension:=_ModuleDimension(module);
	Id:= IdentityMatrix(RationalField(),ambientSpaceDimension);
	return rec<_GModuleDataFormat | 
		vG:=ambientSpaceDimension-_DimensionOfFixedPointSet(module),
		vGstar:=ambientSpaceDimension-_DimensionOfFixedPointSet(Dual(module)),
		vg:=[Rank(R(ClassRepresentative(G,class))-Id) : class in [1..Nclasses(G)]]
	>;
end function;

GModulesData:=function(G) 
	p:=NextPrime(Order(G));
	modules:=IrreducibleModules(G,FiniteField(p));
	return [_GModuleData(G,modules[i]): i in [2..#modules]];	//omit first module (trivial module)
end function;

//test the Scott inequality v(g_1)+... +v(g_n)>= v(G)+v(G^*), 
_VerifiesScottInequality:=function(conjugacyClasses,gModuleData)
 return &+[gModuleData`vg[class] : class in conjugacyClasses] ge gModuleData`vG+gModuleData`vGstar;
end function;

ScottTest:=function(conjugacyClasses,gModulesData) 
	return forall {gModuleData : gModuleData in gModulesData | _VerifiesScottInequality(conjugacyClasses,gModuleData)};
end function;



