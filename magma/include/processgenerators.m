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
	This file exposes a function GeneratorsInFile, which takes as an argument the path of a file containing the output of runcomputation.m; it returns a list of records of type GeneratorsFormat.
*/

EXCLUDED_STRING:="I";

GeneratorsFormat:=recformat<G,X,d,n>;	//G=SmallGroup(d,n); X is a list of spherical systems of generators

_RemoveSurroundingBrackets:=function(bracketedString,opening,closing,separator)
	matches,pattern,insideBrackets:=Regexp(opening cat "(.*)" cat closing,bracketedString);
	if not matches then error bracketedString," not a bracket-enclosed list"; end if;
	if IsEmpty(insideBrackets) then return []; end if;
	if #insideBrackets ne 1 then error bracketedString," not a bracket-enclosed list"; end if;
	return Split(insideBrackets[1],separator);
end function;

_GroupElementFromString:=function(G,g) 
	if Type (G) eq GrpPerm then return eval("G ! " cat g);
	else return elt<G|eval(g)>;
	end if;
end function;

_ReplaceOuterCommasWithColons:=function(string) 
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
		
_GroupElements:=function(vector)
	modified,modifiedString:=_ReplaceOuterCommasWithColons(vector);
	if modified then
		return _RemoveSurroundingBrackets(modifiedString,"\\[","\\]",":");
	else
		return [];
	end if;	
end function;	


_GeneratorsFromLine:=function(dAsString,nAsString,csvlist) 
	d:=StringToInteger(dAsString);
	n:=StringToInteger(nAsString);
	G:=SmallGroup(d,n);
	vectors:=_RemoveSurroundingBrackets(csvlist,"{","}",":");
	if IsEmpty(vectors) or vectors[1] eq EXCLUDED_STRING then return rec<GeneratorsFormat|X:={}>; end if;
	generators:=rec<GeneratorsFormat|>;
	generators`G:=G;
	generators`X:={[_GroupElementFromString(G,g) : g in _GroupElements(v)] : v in vectors};
	generators`d:=d;
	generators`n:=n;	
	return generators;
end function;

_GetLineWithBalancedBraces:=function(file)
	line:=Gets(file);
	if IsEof(line) or "{" notin line then return line; end if;
	while "}" notin line do
		additional_line:=Gets(file);
		if IsEof(additional_line) then return line; end if;
		line cat:=additional_line;
	end while;
	return line;
end function;

GeneratorsInFile:=function(csvfile) 
	result:=[* *];
	file:=Open(csvfile,"r");
	while true do
		line:=_GetLineWithBalancedBraces(file);
		if IsEof(line) then break; end if;
		valuesInLine:=Split(line,";");
		generators:=_GeneratorsFromLine(valuesInLine[1],valuesInLine[2],valuesInLine[7]);
		if not IsEmpty(generators`X) then
			Append(~result,generators);
		end if;
	end while;
	delete file;
	return result;
end function;


