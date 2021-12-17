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
Defines a function IterateOverSequencesIn to iterate through sequences [g_1,...,g_r], with each g_i in a fixed set X_i.

The function takes the sequence [X_1,..,X_r], a procedure f, an argument argA passed by value and three arguments arg1,arg2,arg3 passed by reference; it invokes f(g_1,...,g_r,argA,~arg1,~arg2,~arg3) for every choice of g_1\in X_1,.., g_r\in X_r

A similar function IterateWhileEmptyOverSequencesIn is also defined, working in a similar way, except that the third argument is required to be a container, and iteration is stopped as soon as the container is nonempty
*/

_IterateOverSequencesContaining:=procedure(sequence,X,~f,argA,~arg1,~arg2,~arg3)
	if IsEmpty(X) then
		f(sequence,argA,~arg1,~arg2,~arg3);
	else 
		X1:=X[1];
		X2_to_Xr:=Remove(X,1);
		for g in X1 do
			$$(Append(sequence,g),X2_to_Xr,~f,argA,~arg1,~arg2,~arg3);
		end for;
	end if;
end procedure;

IterateOverSequencesIn:=procedure(X,~f,argA,~arg1,~arg2,~arg3)
	_IterateOverSequencesContaining([],X,~f,argA,~arg1,~arg2,~arg3);
end procedure;


_IterateWhileEmptyOverSequencesContaining:=procedure(sequence,X,~f,argA,~arg1,~arg2,~set)
	if IsEmpty(X) then
		f(sequence,argA,~arg1,~arg2,~set);
	else 
		X1:=X[1];
		X2_to_Xr:=Remove(X,1);
		for g in X1 do
			$$(Append(sequence,g),X2_to_Xr,~f,argA,~arg1,~arg2,~set);
			if not IsEmpty(set) then return; end if; 
		end for;
	end if;
end procedure;

IterateWhileEmptyOverSequencesIn:=procedure(X,~f,argA,~arg1,~arg2,~set)
	_IterateWhileEmptyOverSequencesContaining([],X,~f,argA,~arg1,~arg2,~set);
end procedure;



