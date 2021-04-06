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
 
This file exposes a function to determine whether a subset of a group generates the whole group, caching the result to optimize later invocations with the same set.

X: a subset of a group
G: the group
subsetsThatGenerate: a list of sets that are already known to generate G. This list is updated by the function.
subsetsThatDoNotGenerate: a list of sets that are already known not to generate G. This list is updated by the function.
result: a variable to contain true if X generates G, false otherwise.

The result is stored in the variable result, since Magma does not allow simultaneous use of pass-by-reference variables and return values.
*/
DetermineWhetherSubsetGenerates:=procedure(X,G,~subsetsThatGenerate,~subsetsThatDoNotGenerate,~result)
	if X in subsetsThatGenerate then 
		result:= true;
	elif X in subsetsThatDoNotGenerate then
		result:= false;
	elif sub<G|X> eq G then
		Include(~subsetsThatGenerate,X);
		result:= true;
	else
		Include(~subsetsThatDoNotGenerate,X);
		result:= false;
	end if;
end procedure;

