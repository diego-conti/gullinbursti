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
***************************************************************************

This file defines a function generatorsFromGroupAndString that takes as input a group and a string and outputs the corresponding systems of generators
*/

load "magma/include/admissible.m";

removeSurroundingBrackets:=function(bracketedString,opening,closing,separator)
	matches,pattern,insideBrackets:=Regexp(opening cat "(.*)" cat closing,bracketedString);
	if not matches then error bracketedString," not a bracket-enclosed list"; end if;
	if IsEmpty(insideBrackets) then return []; end if;
	if #insideBrackets ne 1 then error bracketedString," not a bracket-enclosed list"; end if;
	return Split(insideBrackets[1],separator);
end function;

groupElementFromString:=function(G,g) 
	if Type (G) eq GrpPerm then return eval("G ! " cat g);
	else return elt<G|eval(g)>;
	end if;
end function;

replaceOuterCommasWithColons:=function(string) 
	modifiedString:="";
	modified:=false;
	level:=0;
	for i in [1..#string] do
		if string[i] eq "," and level eq 0 then
			modifiedString cat:=":";
			modified:=true;
		else
			modifiedString cat:=string[i];
		end if;
		if string[i] eq ")" then 
			level-:=1;
		elif string[i] eq "(" then 
			level+:=1;
		end if;
	end for;
	return modified,modifiedString;
end function;
		
groupElements:=function(vettore)
	modified,modifiedString:=replaceOuterCommasWithColons(vettore);
	if modified then
		return removeSurroundingBrackets(modifiedString,"\\[","\\]",":");
	else
		return removeSurroundingBrackets(modifiedString,"\\[","\\]",",");
	end if;	
end function;	

generatorsFromGroupAndString:=function(G,csvlist) 
	vettori:=removeSurroundingBrackets(csvlist,"{","}",":");
	return {[groupElementFromString(G,g) : g in groupElements(vettore)] : vettore in vettori};
end function;
