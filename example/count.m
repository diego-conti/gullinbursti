//count topological types in a db file; assumes all lines contain at least one entry
load "magma/include/genus.m";

entryFromCsv:=function(line)
	valuesInLine:=Split(line,";");
	return valuesInLine;
end function;

entry:=function(line)
	d,n,M,gens:=Explode(entryFromCsv(line));
  return StringToInteger(d),StringToInteger(n),eval(M),Split(gens,":");
end function;

genus:=function(line)
	d,n,M,gens:=entry(line);
	return Integers() ! Genus(M,d),#gens;
end function;

CountGeneratorsFromFile:=procedure(fileName)
	typesWithGenus:=[];
	file:=Open(fileName,"r");
	line:=Gets(file);
	while not IsEof(line) do
		g,n:=genus(line);
		if not IsDefined(typesWithGenus,g) then
			typesWithGenus[g]:=0;
		end if;		
		typesWithGenus[g]+:=n;
		line:=Gets(file);
	end while;
	for i in [2..#typesWithGenus] do
	if IsDefined(typesWithGenus,i) then 
		print i, "&", typesWithGenus[i], "\\\\";
	end if;
	end for;
end procedure;

if assigned file then 
	CountGeneratorsFromFile(file);
else
	print "variable file should indicate a file containing nonempty entries in db";
end if;
quit;
