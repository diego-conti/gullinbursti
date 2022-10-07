/***************************************************************************
	Copyright (C) 2021 by Diego Conti

	This file is part of Hliðskjálf.
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
***************************************************************************

This code should be loaded into the work script.

The work script should read the computations to be done from dataFile and write the output of each computation to standard output using the function WriteComputation.

A function ReadComputation is also provided to read the output of WriteComputation (for usage without Hliðskjálf).

*/

if assigned printVersion then print "undefined"; quit; end if;

if not assigned dataFile then error "variable dataFile should point to a valid data file"; end if;
if not assigned megabytes then error  "variable megabytes should indicate a memory limit in MB (or 0 for no limit)"; end if;

MAX_LENGTH:=1000;

_JoinIntoOneLine:=function(lineWithNewlines)
	if Index(lineWithNewlines,"\n") eq 0 then return lineWithNewlines; end if;
	lines:=Split(lineWithNewlines,"\n");
	result:=lines[1];
	for i in [2..#lines] do
		result cat:=" " cat lines[i];
	end for;
	return result;
end function;

WriteComputation:=procedure(lineWithNewlines)
	line:=_JoinIntoOneLine(lineWithNewlines);
	if #line le MAX_LENGTH then print "LINE",line;
	else
		k:=1;
		while k le #line do
			print "PART",Substring(line,k,MAX_LENGTH);
			k+:=MAX_LENGTH;
		end while;
		print "OVER";
	end if;	
end procedure;

_SplitLine:=function(line)
	firstFiveChars:=Substring(line,1,5);
	if #line gt 5 then 
		rest:=Substring(line,6,#line);
	else
		rest:="";		
	end if;
	return firstFiveChars,rest;
end function;

_ParseLine:=function(line,part)
	firstFiveChars, rest:=_SplitLine(line);	
	case firstFiveChars:
		when "LINE ":
			return rest,true;
		when "PART ":
			return Append(part,rest), false;
		when "OVER":
			return part, true;
	end case;
	error "invalid line", line;
end function;

ReadComputation:=function(file)
	line:=Gets(file);
	if IsEof(line) then return line; end if;
	parsed, complete:=_ParseLine(line,"");
	while not complete do
		parsed, complete:=_ParseLine(line,parsed);
	end while;
	return parsed;
end function;

SetMemoryLimit(StringToInteger(megabytes)*1024*1024);
SetQuitOnError(true);
SetColumns(MAX_LENGTH+20);

