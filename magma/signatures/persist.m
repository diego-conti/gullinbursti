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
 This file implements disk storage and retrieval of magma objects. It exposes two functions:

PersistToFile(path,parameters,object) takes an existing directory, a sequence of integers and a magma object; it creates a file inside the directory, with name determined by the parameters, and stores the magma object in it.
ReadFromFile(path,parameters) takes an existing directory and a sequence of integers; it returns the magma object stored in the file indexed by the parameters

Functions with name starting with _ are considered part of the implementation.
*/

//identifies the format used to save data
_Schema:="Centone 1";

/*Container for MAGMA objects to be persisted. The MAGMA object is serialized to disk between the schema description and a SeqEnum descriving content, in order to minimize the impact of file corruption*/
_PersistentData:=recformat< schema: MonStgElt, object, parameters:SeqEnum>;


/*Create a filename from a sequence of parameters (typically integers)*/
FilenameFromParameters:=function(parameters) 
	return &cat [IntegerToString(i) cat "." : i in parameters] cat "data";
end function;

/* Write an object to file
	path: an existing folder where data should be saved
	parameters: a sequence of integers describing content
	object: a magma object

Note: this function is for internal use.
*/
_WriteToFile:=procedure(path,parameters,object)
	curdir:=GetCurrentDirectory();
	try 
		ChangeDirectory(path);
		PrintFileMagma(FilenameFromParameters(parameters),object: Overwrite:=true);
	catch e
		ChangeDirectory(curdir);
		error "error writing to file", e`Object;
	end try;
		ChangeDirectory(curdir);
end procedure;

/* Read an object from file
	path: the directory containing the data
	parameters: a sequence of integers describing content

Return a magma object

Note: this function is for internal use.
*/

_ReadFromFile:=function(path,parameters)
	curdir:=GetCurrentDirectory();
	try 
		ChangeDirectory(path);
		object:=Read(FilenameFromParameters(parameters));
	catch e
		ChangeDirectory(curdir);
		error "error reading from file", e`Object;
	end try;
	ChangeDirectory(curdir);
	return object;
end function;

_VerifyConsistencyWithSchema:=procedure(~persistedObject,~parameters) 
	if not Sprint(Format(persistedObject)) cmpeq Sprint(_PersistentData) then
		error "persistedObject is not a rec<_PersistentData>";
	end if;
	if not persistedObject`schema eq _Schema then
		error "wrong schema, " cat _Schema cat " expected";
	end if;
	if not persistedObject`parameters eq parameters then
		error "wrong parameters, " cat Sprint(parameters) cat " expected";
	end if;
end procedure;

/* Read an object from file
	path: the directory containing the data
	parameters: a sequence of integers describing content

Return a magma object
*/

ReadFromFile:=function(path,parameters)
	if not ExtendedType(parameters) eq SeqEnum[RngIntElt] then
		error "LeggiDaFile: parameters should be a sequence of integers";
	end if;
	persistedObject:=eval(_ReadFromFile(path,parameters));
	_VerifyConsistencyWithSchema(~persistedObject,~parameters);
	return persistedObject`object;
end function;


/* Write an object to file
	path: an existing folder where data should be saved
	parameters: a sequence of integers describing content
	object: a magma object

Note: this function is for internal use.
*/
PersistToFile:=procedure(path, parameters, object)
	persistentObject:=rec<_PersistentData|>;
	persistentObject`schema:=_Schema;	
	persistentObject`object:=object;
	persistentObject`parameters:=parameters;
	_WriteToFile(path,parameters,persistentObject);
end procedure;

