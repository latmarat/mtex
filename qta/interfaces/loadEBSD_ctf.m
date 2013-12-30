function ebsd = loadEBSD_ctf(fname,varargin)
% read HKL *.ctf file
%
% Syntax
%   ebsd = loadEBSD_ctf(fname,'convertSpatial2EulerReferenceFrame')
%   ebsd = loadEBSD_ctf(fname,'convertEuler2SpatialReferenceFrame')
%
% Input
%  fname - file name
%
% Flags
%  convertSpatial2EulerReferenceFrame - change x and y values such that
%  spatial and Euler reference frame coincide, i.e., rotate them by 180
%  degree
%  convertEuler2SpatialReferenceFrame - change the Euler angles such that
%  spatial and Euler reference frame coincide, i.e., rotate them by 180
%  degree

ebsd = EBSD;

try
  % read file header
  hl = file2cell(fname,100);
  
  % check that this is a channel text file
  if isempty(strmatch('Channel Text File',hl{1}));
    error('MTEX:wrongInterface','Interface ctf does not fit file format!');
  elseif check_option(varargin,'check')
    return
  end
  
  
  phase_line = find(~cellfun('isempty',strfind(hl,'Phases')));
  
  nphase = sscanf(hl{phase_line},'%s\t%u');
  nphase = nphase(end);
  
  ss = symmetry;
  
  % Crystallogaphic Parameters of all phases
  Laue = {'-1','2/m','mmm','4/m','4/mmm',...
    '-3','-3m','6/m','6/mmm','m3','m3m'};
  
  % phases to be ignored
  ignorePhase = get_option(varargin,'ignorePhase',[]);
  
  for K = 0:nphase
    
    if any(K==ignorePhase) || K == 0,
      cs{K+1} = 'notIndexed';
    else
      
      % load phase
      mpara = regexpsplit(hl{phase_line+K},'\t');
      
      
      abc = sscanf( strrep(mpara{1},',','.'),'%f;%f;%f'); % Lattice ABC
      abg = sscanf( mpara{2},'%f;%f;%f'); % Lattice alpha beta gamma
      
      % Phase name
      mineral = mpara{3};
      
      % Laue group (class) number
      laue = Laue{sscanf(mpara{4},'%u')};
      cs{K+1} = symmetry(laue,abc(:)',abg(:)','mineral',mineral); %#ok<AGROW>
    end
  end
  
  ebsd = loadEBSD_generic(fname,'cs',cs,'ss',ss,'bunge','degree',...
    'ColumnNames',{'Phase' 'X' 'Y' 'Bands' 'Error' 'Euler 1' 'Euler 2' 'Euler 3' 'MAD' 'BC' 'BS'}, ...
    'Columns',1:11,'phaseMap',0:nphase,'IgnorePhase',ignorePhase,varargin{:});
  
  
  % x||a*, z||c
  %
catch
  interfaceError(fname)
end

% change reference frame
if check_option(varargin,'convertSpatial2EulerReferenceFrame')
  ebsd = rotate(ebsd,rotation('axis',xvector,'angle',180*degree),'keepEuler');
elseif check_option(varargin,{'convertEuler2SpatialReferenceFrame','wizard'}) 
  ebsd = rotate(ebsd,rotation('axis',xvector,'angle',180*degree),'keepXY');
else
  warning(['.ctf files have usualy inconsistent conventions for spatial ' ...
    'coordinates and Euler angles. You may want to use one of the options ' ...
    '''convertSpatial2EulerReferenceFrame'' or ''convertEuler2SpatialReferenceFrame'' to correct for this']);  
end
