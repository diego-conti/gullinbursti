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
	Functions implementing the action of the braid group on systems of generators
*/


	//(g_1,...,g_n)->(g_1,....,g_{i+1}, g_{i+1}^{-1} g_i g_{i+1}, ...,g_n)
	HurwitzMove:=function(seq,i)
		temp:=seq[i];
		seq[i]:=seq[i+1];
		seq[i+1]:=temp^seq[i+1];
		return seq;
	end function;

	//(h_1,...,h_n)->(h_1,....,h_i h_{i+1} h_i^{-1}, h_i, ...,h_n)
	InverseHurwitzMove:=function(seq,i)
		temp:=seq[i+1];
		seq[i+1]:=seq[i];
		seq[i]:=temp^(seq[i]^-1);
		return seq;
	end function;

	PureBraid:=function(seq, i,j)
		for k := j-1 to i+1 by -1 do
			seq:=InverseHurwitzMove(seq,k);
		end for;
		seq:=HurwitzMove(seq,i);
		seq:=HurwitzMove(seq,i);
		for k := i+1 to j-1 do
			seq:=HurwitzMove(seq,k);
		end for;
		return seq;
	end function;

//given an element h in the free group over r-1 generators, return the action on a spherical system of generators x=(g_1,..,g_r)
	BraidAction:=function(x,h) 
		image:=x;
		for generator in Eltseq(h) do
			if generator ge 1 then
				image:=HurwitzMove(image,generator);
			else 
				image:=InverseHurwitzMove(image,-generator);
			end if;
		end for;
		return image;
	end function;	
