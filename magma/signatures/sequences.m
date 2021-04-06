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
/* This function allows iterating through nondecreasing sequences 1\leq i_1\leq ... \leq i_h\leq x 
	It takes a nondecreasing sequence [i_1,...,i_h], which is modified into the next sequence if it exists, or the empty sequence [].
  The parameter max is the upper bound x for elements of the sequence.
 */
NextSequence:=procedure(~sequence, max); //SeqEnum, int
		i:=#sequence;
		while (i gt 0) and (sequence[i] eq max)  do
			i-:=1;
		end while;
		if i eq 0 then
			sequence:=[]; 
			return;
		end if;
		sequence[i]+:=1;
		while i lt #sequence do
			sequence[i+1]:=sequence[i];
			i+:=1;
		end while;
end procedure;


