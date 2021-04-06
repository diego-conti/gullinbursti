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
	Functions to keep track of memory and time usage in computations
*/
ResetTimeAndMemoryUsage:=procedure(~timeVariable)
	timeVariable:=Cputime();
	ResetMaximumMemoryUsage();
end procedure;


MBUsedAndTimeSinceLastReset:=function(timeVariable)
	elapsedTime:=Cputime()-timeVariable;
	return Sprint(elapsedTime) cat "; " cat Sprint(Truncate(GetMaximumMemoryUsage()/(1024*1024)));
end function;

