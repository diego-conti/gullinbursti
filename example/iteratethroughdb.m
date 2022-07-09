load "magma/db/generatorsfromdb.m";
load "magma/signatures/signatures.m";

noGeneratorsByG:=[];

for g in [30..33] do
numberOfGeneratorsFound:=0;
for signature in Signatures(g) do
	M:=signature`M;
	d:=signature`d;
	if assigned(VERBOSE) then print M,d; end if;
	for n in [1..NumberOfSmallGroups(d)] do
		test,generatorsOrMessage,G:=generatorsFromDb(d,n,M);
		if not test then
			if assigned(VERBOSE) then  print d,n,M, "excluded because :",generatorsOrMessage; end if;
		elif IsEmpty(generatorsOrMessage) then
			if assigned(VERBOSE) then print d,n,M, "no generators"; end if;
		else
			if assigned(VERBOSE) then 
				print "found some generators for ",d,n,M;
				print generatorsOrMessage;
			end if;
			numberOfGeneratorsFound +:= #generatorsOrMessage;
		end if;
	end for;
end for;
print g, "&", numberOfGeneratorsFound, "\\\\";
noGeneratorsByG[g]:=numberOfGeneratorsFound;
end for;	

print "generators by g", noGeneratorsByG;
for i in [2..#noGeneratorsByG] do
	if IsDefined(noGeneratorsByG,i) then 
		print i, "&", noGeneratorsByG[i], "\\\\";
	end if;
end for;
quit;
