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
	A function to compute the genus associated to a signature
*/

_DegreeOfCanonicalBundle:=function(M,d)
	deg:=d*(-2+#M-&+[1/M[i]: i in [1..#M]]);
	return deg;
end function;

/* return the genus of a signature 

M: the signature [m_1,..,m_r]
d: the order of the group
returns g(Delta), where Delta is any spherical system of generators of an order d group with signature M 
*/
Genus := function(M,d)
	return _DegreeOfCanonicalBundle(M,d)/2+1;
end function;

