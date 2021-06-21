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

This script runs the code that classifies spherical systems of generators corresponding to a given set of signatures and groups, e.g:
magma processId:=1 dataFile:=data.csv outputPath:=co memory:=1 magma/runcomputation.m
invokes the computation on the signatures contained in the file data.csv, using a maximum memory of 1 GB and writing the output to co/1.csv.
The script performs one computation at a time; if memory runs out during a computation, the script terminates. The offending data can be recovered by comparing the dataFile to the output.
The output is written to stdout

It takes the following parameters:
processId a unique string identifying the process. Useful for parallelization; it determines the name of the file to be used for output
dataFile a file containing the computations to be performed, each line having the form d;n;[m_1,...,m_r], corresponding to SmallGroup(d,n) and signature [m_1,...,m_r]
megabytes the memory limit in MB
*/

load "magma/hurwitz/computegenerators.m";
load "magma/include/admissible.m";
load "magma/include/memoryandtimeusage.m";
load "magma/include/hliðskjálflayer.m";

if assigned printVersion then print "v1"; quit; end if;

ParametersFormat:=recformat< d: Integers(), n: Integers(), M : SeqEnum>;

ReadParameters:=function(line)
	result:=rec<ParametersFormat|>;
	components:=Split(line,";");
	if #components ne 3 then error "Each line in datafile should have the form d;n;[m_1,...,m_r]", components; end if;
	result`d:=StringToInteger(components[1]);
	result`n:=StringToInteger(components[2]);
	result`M:=eval(components[3]);
	if ExtendedType(result`M) ne SeqEnum[RngIntElt] then error "Each line in datafile should have the form d;n;[m_1,...,m_r], with the m_i integers", result`M; end if;
	return result;
end function;

EXCLUDED_STRING:="I";

ListToCsv:=function(containerOfPrintable, separator) 
	result:="";
	if IsEmpty(containerOfPrintable) then return result; end if;
	result:=Sprint(containerOfPrintable[1]);	
	for i in [2..#containerOfPrintable] do
		result cat:=separator;
		result cat:=Sprint(containerOfPrintable[i]);
	end for;
	return result;
end function;

WriteLineToOutput:=procedure(parameters, runningTime, data)
	firstPart:=[* parameters`d, parameters`n, parameters`M,MBUsedAndTimeSinceLastReset(runningTime),VERSION *];
	line:= ListToCsv(firstPart,";") cat ";{" cat ListToCsv(data,":") cat "}";
	WriteComputation(line);
end procedure;

FindGeneratorsFromParameters:=procedure(parameters)
	local runningTime;
	ResetTimeAndMemoryUsage(~runningTime);	
  G:=SmallGroup(parameters`d,parameters`n);
  admissible,reasonToExclude:=Admissible(G,parameters`M);
	if admissible then
		generators:=SetToSequence(FindGenerators(G,parameters`M));
		WriteLineToOutput(parameters,runningTime,generators);
	else 
		WriteLineToOutput(parameters,runningTime,[EXCLUDED_STRING, reasonToExclude]);
	end if;
end procedure;

FindGeneratorsFromFile:=procedure(fileName)
	file:=Open(fileName,"r");
	line:=Gets(file);
	while not IsEof(line) do
		FindGeneratorsFromParameters(ReadParameters(line));
		line:=Gets(file);
	end while;
end procedure;

FindGeneratorsFromFile(dataFile);

quit;
