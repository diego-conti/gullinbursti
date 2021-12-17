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

_ElementsOfOrderTwoUpToConjugacy:=function(G)
	result:=[* *];
	for class in Classes(G) do
		order,length,rep:=Explode(class);
		if order eq 2 then Append(~result,rep); end if;
	end for;
	return result;
end function;
	
/* if G=D(A), return true, A, else return false, G*/
IsGeneralizedDihedral:=function(G)
	halfOrderG:=Order(G)/2;
	abelianNormalSubgroupsOfIndexTwo:=[* H`subgroup: H in NormalSubgroups(G) | H`order eq halfOrderG and IsAbelian(H`subgroup) *];	
	elementsOfOrderTwo:=_ElementsOfOrderTwoUpToConjugacy(G);	
	for H in abelianNormalSubgroupsOfIndexTwo do
		for sigma in elementsOfOrderTwo do
			if forall {h^sigma eq h^-1 : h in Generators(H)} then return true, H; end if;
		end for;
	end for;	
	return false,G;
end function;


IsDihedral:=function(G)
	test,A:=IsGeneralizedDihedral (G);
	return test and IsCyclic(A);
end function;
