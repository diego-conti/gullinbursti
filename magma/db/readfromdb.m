/***************************************************************************
	Copyright (C) 2021 by Diego Conti, diego.conti@unimib.it

	This file is part of hliðskjálf.
	Hliðskjálf is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
*****************************************************************************/

//return an entry corresponding to a ;-separated line in the db. For this example, we just return the line as a sequence of strings 
entryFromCsv:=function(line)
	valuesInLine:=Split(line,";");
	return valuesInLine;
end function;

fileSize:=function(file)
	pos:=Tell(file);
	Seek(file,0,2);
	result:=Tell(file);
	Seek(file,pos,0);
	return result;
end function;

compareDBKeys:=function(secondaryInputs,line)
	valuesInLine:=Split(line,";");
	if #valuesInLine lt #secondaryInputs then error line, "Invalid line in database: at least ", #secondaryInputs, " entries per line expected"; end if;
	for i in [1..#secondaryInputs] do
		if secondaryInputs[i] lt valuesInLine[i] then return -1;
		elif secondaryInputs[i] gt valuesInLine[i] then return 1;
		end if;
	end for;
	return 0;
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

//search in the files by a bysection method
findInFile:=function(secondaryInputs,file)
	lesserBound:=0;
	upperBound:=fileSize(file);	
	while lesserBound lt upperBound do 
		positionOfLine,endOfLine,line:=bisect(file,lesserBound,upperBound);	
		compare:=compareDBKeys(secondaryInputs,line);		
		if compare lt 0 then upperBound:=positionOfLine; 
		elif compare gt 0 then lesserBound:=endOfLine;
		else return true,entryFromCsv(line);
		end if;
	end while;
	return false, NOT_PRESENT_IN_DATABASE;
end function;

//given the primary and secondary inputs:
//if an entry is in the database, return true,entry
//if no entry is present in the database, return false, NOT_PRESENT_IN_DATABASE
fromDb:=function(pathToDb,primaryInput,secondaryInputs)
	test,file:=OpenTest(pathToDb cat "/" cat IntegerToString(primaryInput),"r");
	if not test then return false,NOT_PRESENT_IN_DATABASE; end if;
	retval, db_entry_or_message:=findInFile(secondaryInputs,file);
	delete file;
	return retval, db_entry_or_message;
end function;

