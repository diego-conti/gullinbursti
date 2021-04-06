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
	
//dato un multiset di insiemi disgiunti {* A_1^^r_1, ..., A_k^^r_k *} ritorna l'insieme dei multiset con r_1 elementi in A_1, ..., r_k elementi in A_k
Selections:=function(multisetOfSets)
	local x;
	result:={};
	firstSet:=Rep(multisetOfSets);
	multiplicityOfFirstSet:=Multiplicity(multisetOfSets,firstSet);
	if #multisetOfSets eq 1 then return {{*x *} : x in firstSet}; end if;
	withoutFirstSet:=Exclude(multisetOfSets,firstSet^^multiplicityOfFirstSet);
	while not IsEmpty(firstSet) do
		withSetsEqualToFirst:=Include(withoutFirstSet, firstSet^^(multiplicityOfFirstSet-1));
		ExtractRep(~firstSet,~x);
		result join:={Include(head,x) : head in $$(withSetsEqualToFirst)};
	end while;
	return result;
end function;

	//ritorna un multiset di insiemi di elementi degli ordini giusti assumendo che esistano, altrimenti lancia un errore. Il secondo argomento è l'insieme più grande
	MultisetDiElementiDiOrdini:=function(group,ordini)
		largest:={};
		result:={* *};
		for m in MultisetToSet(ordini) do
			elementiDiOrdineM:={g : g in group | Order(g) eq m};
			if IsEmpty(elementiDiOrdineM) then error group, "non ha elementi di ordine ",m; end if;
			if #elementiDiOrdineM gt #largest then largest:=elementiDiOrdineM; end if;
		 	Include(~result,elementiDiOrdineM^^Multiplicity(ordini,m));
		end for;				 
		return result,largest;
	end function;

	//dato un multiset di ordini {*m_1^^h_1, ..., m_n^^h_n *} determina i multiset {*g_1, ... , g_r*} con \prod g_i =1 tali che per ogni j=1,...,n, esattamente h_j dei g_i hanno ordine m_j
	//ritorna una sequenza dei multiset corti associati, cioè con uno dei g_i tolto.
	MultisetCortiAProdottoUnoDiOrdini:=function(abelianGroup,multisetDiOrdini) 
		multisetDiElementiDiOrdini,largest:=MultisetDiElementiDiOrdini(abelianGroup,multisetDiOrdini);
		Exclude(~multisetDiElementiDiOrdini,largest);
		ordineUltimoElemento:=Order(Rep(largest));
		return [multiset : multiset in Selections(multisetDiElementiDiOrdini) | Order(&*multiset) eq ordineUltimoElemento];
	end function;

	CalcolaMultisetGeneratoriSferici:=procedure(~abelianGroup,ordini,~result)
		local subsetGenerates;
		result:={};
		multisetDiOrdini:={* o: o in ordini *};
		sottoinsiemiTrovatiCheGenerano:={};
		sottoinsiemiTrovatiCheNonGenerano:={};
		for v in MultisetCortiAProdottoUnoDiOrdini(abelianGroup,multisetDiOrdini) do
			DetermineWhetherSubsetGenerates({g : g in v},abelianGroup,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~subsetGenerates);
			if subsetGenerates then Include(~result,Include(v, (&*v)^-1)); end if;
		end for;
	end procedure;

	ApplyToMultisets:=function(f, X) 
		return {* f(x) : x in X *};
	end function;

	FindGeneratorsAbelian:=function(abelianGroup, M)
		local X;
		CalcolaMultisetGeneratoriSferici(~abelianGroup,M,~X);
		if IsEmpty(X) then return {}; end if;
		
		A:=AutomorphismGroup(abelianGroup);
	 // costruisco una rappresentazione di A come gruppo di permutazioni,
	 // ossia un isomorfismo r:A-->P dove P è un gruppo di permutazioni
		r,P:=PermutationRepresentation(A);
		f:=map< CartesianProduct(X,P)-> X | xAndP :-> ApplyToMultisets((r^-1)(xAndP[2]),xAndP[1])>;
		gset:=GSet(P,X,f);
											return { [g: g in Rep(orbit)] : orbit in Orbits(P,gset)};
	end function; 
	//seconda possibilità: usare ActionImage e poi prendere OrbitRepresentatives
