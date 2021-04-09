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
	This script takes a path as a parameter, e.g.
	magma path:=test magma/processgenerators.m
	prints all the generators that have been written in directory test
*/
load "magma/include/processgenerators.m";
load "magma/include/genus.m";

if not assigned path then error "variable path should point to a directory containing the output of runcomputation.m"; end if; 

IterateThroughDirectory:=procedure(directory,f)
		pipe:=POpen("ls " cat directory cat " -1","r");
		while true do
			line:=Gets(pipe);
			if IsEof(line) then break; end if;
			f(directory cat "/" cat line);
		end while;
		delete pipe;
end procedure;

PrintGenerators:=procedure(csvfile)
		for generators in GeneratorsInFile(csvfile) do
			print "Group: ",generators`d,",",generators`n;
			M:=Sort([Order(g): g in Rep(generators`X)]);
			print "signature:",M;
			for x in generators`X do 
				print "Generators: ",x; 
			end for;
			print "g:",Genus(M,generators`d);
		end for;
end procedure;

IterateThroughDirectory(path,PrintGenerators);
quit;

