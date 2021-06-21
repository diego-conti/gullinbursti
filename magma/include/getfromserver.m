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

This file defines a function getWebPage that reads a web page at a given URL */

getWebPage:=function(URL,path,port)
	S:=Socket(URL,port);
	Write(S,"GET " cat path cat "\n\n");
	r:=Read(S);
	result:="";
	while not IsEof(r) do
		result cat:=r;
		r:=Read(S);
	end while;
	CRLF:=CodeToString(13) cat CodeToString(10);
	i:=Position(result,CRLF cat CRLF);
	if i eq 0 then error "unexpected HTTP response", result; end if;
	return Substring(result,i+4,#result-(i+3));
end function;

