function readSolutionFileHEKA(obj,Level)
%--------------------------------------------------------------------------
% Gets one record of the tree and the number of children
s = getOneSolutionRecord(obj);
obj.fileData.Tree{obj.fileData.Counter, Level+1} = s;

obj.fileData.Position = obj.fileData.Position+obj.fileData.Sizes(Level+1);
fseek(obj.fileData.fh, obj.fileData.Position, 'bof');
obj.fileData.nchild=fread(obj.fileData.fh, 1, 'int32=>int32');
obj.fileData.Position=ftell(obj.fileData.fh);

end


%--------------------------------------------------------------------------
function rec=getOneSolutionRecord(obj,Level)
%--------------------------------------------------------------------------
% Gets one record
obj.fileData.Counter = obj.fileData.Counter+1;
switch Level
	case 0
		rec=getSolutionRoot(obj);
	case 1
		rec=getSolutionRecord(obj);
	case 2
		rec=getChemicalRecord(obj);
		
	otherwise
		error('Unexpected Level');
end

end

%--------------------------------------------------------------------------
function p=getSolutionRoot(obj)
%--------------------------------------------------------------------------
fh = obj.fileData.fh;

p.RoVersion			= fread(fh, 1, 'int16=>int16'); %			= 0; (* INT16 *)
p.RoDataBaseName	= deblank(fread(fh, 80, 'uint8=>char')');%  = 2; (* SolutionNameSize *)
p.RoSpare1			= fread(fh, 1, 'int16=>int16');%			= 82; (* INT16 *)
p.RoCRC				= fread(fh, 1, 'int32=>int32'); %			= 84; (* CARD32 *)
p.RootSize			= 88;%										=  88

p=orderfields(p);

end

%--------------------------------------------------------------------------
function s=getSolutionRecord(obj)
%--------------------------------------------------------------------------
fh = obj.fileData.fh;

s.SoNumber			= fread(fh, 1, 'int32=>int32');%                =   0; (* INT32 *)
s.SoName			= deblank(fread(fh, 80, 'uint8=>char')');%      =   4; (* SolutionNameSize  *)
s.SoNumeric			= fread(fh, 1, 'real*4=>double');%				=  84; (* REAL *) *)
s.SoNumericName		= deblank(fread(fh, 30, 'uint8=>char')');%      =  88; (* ChemicalNameSize *)
s.SoPH				= fread(fh, 1, 'real*4=>double');%				= 118; (* REAL *)
s.SopHCompound		= deblank(fread(fh, 30, 'uint8=>char')');%      = 122; (* ChemicalNameSize *)
s.soOsmol			= fread(fh, 1, 'real*4=>double');%				= 152; (* REAL *)
s.SoCRC				= fread(fh, 1, 'int32=>int32') ;%				= 156; (* CARD32 *)
s.SolutionSize		= 160;%											= 160

s=orderfields(s);

end

%--------------------------------------------------------------------------
function c=getChemicalRecord(obj)
%--------------------------------------------------------------------------
fh = obj.fileData.fh;

c.ChConcentration	= fread(fh, 1, 'real*4=>double');%              = 0; (* REAL *)
c.ChName			= deblank(fread(fh, 30, 'uint8=>char')');%      = 4; (* ChemicalNameSize *)
c.ChSpare1			= fread(fh, 1, 'int16=>int16');%				= 34; (* INT16 *)
c.ChCRC				= fread(fh, 1, 'int32=>int32')';%               = 36; (* CARD32 *)
c.ChemicalSize		= 40;%										    =  40

c=orderfields(c);

end
