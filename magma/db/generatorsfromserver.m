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

This file defines a function generatorsFromServer that reads the generators from the database available at pascal.unipv.it:3000.
*/
load "magma/db/parsegenerators.m";
load "magma/include/getfromserver.m";

SERVER:="pascal.unipv.it";
PORT:=3000;

signatureAsHtmlString:=function(M) 
	space:="%20";
	result:="[" cat space cat Sprint(M[1]);
	for i in [2..#M] do 
		result cat:="," cat space cat Sprint(M[i]);
	end for;
	result cat:=space cat "]";
	return result;
end function;

generatorsFromServer:=function(d,n,signature)
	G:=SmallGroup(d,n);	
	test,reason:=Admissible(G,signature);
	if not test then return test,reason,G; end if;
	path:="/d/" cat Sprint(d) cat "/n/" cat Sprint(n) cat "/M/" cat signatureAsHtmlString(Sort([x: x in signature]));
	page:=getWebPage(SERVER,path,PORT);
	return true,generatorsFromGroupAndString(G,page),G;
end function;
