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

This script creates a CSV file that encodes the list of computations to be performed. It is meant to be invoked from the command line; for example:
magma maxG:=40 outFile:=computations.csv magma/signatures/createlistofcomputations.m
writes all on computations.csv all computations for g\leq 40.

It takes parameters minG (default 2), maxG, minR (default 3), maxR (default infinity), outFile.
For each signature (d,[m_1,...,m_r]) with genus g and r branch points, minG\leq g \leq maxG, minR\leq r\leq maxR, r<=2*g+2 it writes on the file the line
d;n;[m_1,..,m_r]
where n is the number of groups of order d, i.e. n=NumberOfSmallGroups(d)
*/

load "magma/signatures/signatures.m";

if not assigned maxG then error "define maxG (and possibly minG, defaulting to 2) before invoking this program"; end if;
if not assigned minG then minG:="2"; end if;
if not assigned maxR then maxR:="-1"; end if;
if not assigned minR then minR:="3"; end if;
if not assigned outFile then error "define outFile before invoking this program"; end if;
if maxR ne "-1" then 
	print "creating list of computations, ",minG,"\\leq g \\leq ",maxG, ", ",minR,"\\leq r \\leq ",maxR,":";
else 
	print "creating list of computations, ",minG,"\\leq g \\leq ",maxG, ", ",minR,"\\leq r",":";
end if;

minG:=StringToInteger(minG);
maxG:=StringToInteger(maxG);
maxR:=StringToInteger(maxR);
minR:=StringToInteger(minR);

WriteLine:=procedure(d,n,M,file)
	riga:=Sprint(d) cat ";" cat Sprint(n) cat ";" cat Sprint(M);
	Puts(file,riga);
end procedure;

RangeOfSmallGroups:=function(d)
	return "1.." cat Sprint(NumberOfSmallGroups(d));
end function;

if assigned onlyAbelian then 

WriteComputationsOrderD:=procedure(d,M,file)
	P := SmallGroupProcess(d);
	for n in [1..NumberOfSmallGroups(d)] do
		G := Current(P);
		if IsAbelian(G) then 
				WriteLine(d,Sprint(n) cat ".." cat Sprint(n),M,file);
		end if;
		Advance(~P);
	end for;
end procedure;

else

WriteComputationsOrderD:=procedure(d,M,file)
	WriteLine(d,RangeOfSmallGroups(d),M,file);
end procedure;

end if;

WriteComputations:=procedure(g,file)
	boundR:=2*g+2;
	if maxR gt 0 then boundR:=Min(boundR,maxR); end if;
	for r in [minR..boundR] do
	for signature in Signatures_g_r(g,r) do
		d:=signature`d;
		WriteComputationsOrderD(d,signature`M,file);
	end for;
	end for;
end procedure;


file:=Open(outFile,"w");

for g in [minG..maxG] do		
		WriteComputations(g,file);
end for;

delete file;

quit;
