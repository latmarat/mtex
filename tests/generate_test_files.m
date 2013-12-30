function generate_test_files(varargin)

cs = symmetry('-3m');
ss = symmetry('-1');

% crystal directions
h = [Miller(1,0,0,cs),Miller(0,0,1,cs)];

% specimen directions
r = equispacedS2Grid('resolution',5*degree,'hemisphere');

% ODF
odf = unimodalODF(idquaternion,cs,ss);

% pole figures
pf = calcPoleFigure(odf,h,r) %#ok<NOPRT>

% debug mode
setMTEXpref('debugMode');

setMTEXpref('tempdir',fullfile(mtex_path,'c','test'));

% generate files
disp('Press Strg-C to generate test files!')
calcODF(pf)

deleteMTEXpref('debugMode');
