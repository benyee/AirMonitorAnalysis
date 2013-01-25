%Calibration Analysis Script

%Where is the calibration spectrum located?
dir = '';
%Load spectrum:
spec = load(dir);
livetime = 100000;  %Live time of spectrum, in seconds

%Background spectrum, for reference:
bkgdir = '';
bkgspec = load(backdir);
bkglivetime = 100000;


%Calibration information:
%Energies of calibration lines, given by calibration info sheet:
E = [59.5 88.0 122.1 165.9 279.2 391.7 661.7 898.0 1173.2 1332.5 1836.1];
%Corresponding bin numbers in spectrum:
peaks = round(E);
%Activities given in the calibration info sheet:
act_0 = [669.3 945.7 503.9 713.8 1525 979.6 643.6 2372 1208 1208 2512];
%Half-lives, in days, as given by calibration info sheet:
hl = [1.58e5 462.6 271.8 137.6 46.61 115.1 10980 106.6 1925 1925 106.6];
hl = hl*24*3600; %Half-lives, in seconds
%Time between calibration sheet validation and measurement, in seconds:
dt = 0;
%Current activity:
act = act_0.*exp(-log(2)./hl*dt);
