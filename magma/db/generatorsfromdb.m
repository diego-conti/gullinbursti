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

This file defines a function generatorsFromDb(d,n,M) which reads the database for entries d,n,M, returning true,generators,G if entry found or false, message,G if no entry found in database
*/

PATH_TO_DB:="db";

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

generatorsFromGroupAndCsv:=function(G,csvlist) 
	vettori:=removeSurroundingBrackets(csvlist,"{","}",":");
	return {[groupElementFromString(G,g) : g in groupElements(vettore)] : vettore in vettori};
end function;

fileSize:=function(file)
	pos:=Tell(file);
	Seek(file,0,2);
	result:=Tell(file);
	Seek(file,pos,0);
	return result;
end function;

compareDBKeys:=function(n,signature,line)
	valuesInLine:=Split(line,";");
	if #valuesInLine ne 3 then error line, "Invalid line in database: 3 entries per line expected"; end if;
	n2:=StringToInteger(valuesInLine[1]);
	if n lt n2 then return -1;
	elif n gt n2 then return 1;
	elif signature lt valuesInLine[2] then return -1;
	elif signature gt valuesInLine[2] then return 1;
	else return 0;
	end if;
end function;

readUntilEndOfLine:=function(position, file)
	Seek(file,position,0);
	positionOfNewline:=position;
	repeat
		c:=Read(file,1000);
		pos:=Position(c,"\n");
		if pos ne 0 then return positionOfNewline+pos; end if;		 
		positionOfNewline +:=1000; 
	until IsEof(c);
	return positionOfNewline;	//past EOF
end function;

bisect:=function(file,lesserBound,upperBound)
	average:=Truncate((lesserBound+upperBound)/2);
	positionOfLine:=readUntilEndOfLine(average,file);
	if positionOfLine ge upperBound then 
		Seek(file,lesserBound,0);
		positionOfLine:=lesserBound;
	else
		Seek(file,positionOfLine,0);		
	end if;
	line:=Gets(file);	
	endOfLine:=Tell(file);
	return positionOfLine,endOfLine,line;
end function;

NOT_PRESENT_IN_DATABASE:="not present in database";
CYCLIC:="cyclic";

findGeneratorsInFile:=function(G,n,signatureAsString,file)
	lesserBound:=0;
	upperBound:=fileSize(file);	
	while lesserBound lt upperBound do 
		positionOfLine,endOfLine,line:=bisect(file,lesserBound,upperBound);	
		compare:=compareDBKeys(n,signatureAsString,line);		
		if compare lt 0 then upperBound:=positionOfLine; 
		elif compare gt 0 then lesserBound:=endOfLine;
		else 
			valuesInLine:=Split(line,";");
			return true,generatorsFromGroupAndCsv(G,valuesInLine[3]);
		end if;
	end while;
	return false, NOT_PRESENT_IN_DATABASE;
end function;

//given integers d,n and a signature.
//if an entry is in the database, return true,generators,G
//if no entry is present in the database, return false, message,G
//the message can be "cyclic" for cyclic group or "not present in database" for missing entries.
generatorsFromDb:=function(d,n,signature)
	G:=SmallGroup(d,n);	
	test,file:=OpenTest(PATH_TO_DB cat "/" cat IntegerToString(d),"r");
	if not test then return false,NOT_PRESENT_IN_DATABASE,G; end if;
	signatureAsString:=Sprint(Sort([x: x in signature]));
	retval, generators_or_message:=findGeneratorsInFile(G,n,signatureAsString,file);
	delete file;
	return retval, generators_or_message,G;
end function;
