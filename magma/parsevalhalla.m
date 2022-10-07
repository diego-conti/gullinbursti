load "magma/include/genus.m";

ParametersFormat:=recformat< d: Integers(), n: Integers(), M : SeqEnum>;

ReadParameters:=function(line)
	result:=rec<ParametersFormat|>;
	components:=Split(line,";");
	if #components lt 3 then error "Each line in datafile should have the form d;n;[m_1,...,m_r]", components; end if;
	result`d:=StringToInteger(components[1]);
	result`n:=StringToInteger(components[2]);
	result`M:=eval(components[3]);
	if ExtendedType(result`M) ne SeqEnum[RngIntElt] then error "Each line in datafile should have the form d;n;[m_1,...,m_r], with the m_i integers", result`M; end if;
	return result;
end function;

InValhalla:=function(csvfile) 
	result:=[* *];
	file:=Open(csvfile,"r");
	while true do
		line:=Gets(file);
		if IsEof(line) then break; end if;
		result:=ReadParameters(line);
		print result`d,result`n,result`M,"g=",Genus(result`M,result`d);
	end while;
	delete file;
	return result;
end function;

InValhalla(path);

