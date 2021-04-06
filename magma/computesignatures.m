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

	This script is meant to be invoked from the command line, e.g:
	magma d:=10 maxG:=100 magma/signatures/computesignatures.m
	It computes and stores on disk signatures up to a given maximum genus for fixed group order.
	Useful in order to parallelize the computation
*/

load "magma/signatures/signatures.m";

if not assigned d then error "variable d should be assigned an integer representing group order"; end if;
if not assigned maxG then maxG:="128"; end if;

print "computing signatures for d=",d,", g\\leq ",maxG;

groupOrder:=StringToInteger(d);
maxG:=StringToInteger(maxG);

ComputeAndSaveSignatures(groupOrder,maxG);

quit;
