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

This file defines a function generatorsFromDb(d,n,M) which reads the database for entries d,n,M, returning true,generators,G if entry found or false, message,G if no entry found in database
*/

load "magma/db/readfromdb.m";
load "magma/db/parsegenerators.m";

PATH_TO_DB:="db";


/*given integers d,n and a signature.
	if an entry is in the database, return true,generators,G
	if no entry is present in the database, return false, message,G
	the message can be "not present in database" for missing entries or a reason explaining why the existence of a spherical system of generators with the requested signature can be excluded a priori, namely:
	"order" for entries not included because the group does not have elements of order m for some m in the signature,
	"KW" if entry is excluded by Kulkarni-Wiman,
	"abelianization" if the abelianization cannot be generated by a set of elements with the indicated signature
*/
generatorsFromDb:=function(d,n,signature)
	G:=SmallGroup(d,n);	
	test,reason:=Admissible(G,signature);
	if not test then return test,reason,G; end if;
	signatureAsString:=Sprint(Sort([x: x in signature]));
	retval, entry_or_message:=fromDb(PATH_TO_DB,d,[* Sprint(n),signatureAsString *]);
	if retval then return true, generatorsFromGroupAndString(G,entry_or_message[3]),G;
	else return false, entry_or_message,G;
	end if;
end function;
