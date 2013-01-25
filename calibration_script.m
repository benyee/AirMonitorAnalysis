%Calibration Analysis Script
close all; clc; clear all;

%Where is the calibration spectrum located?
path = '/Users/benyee/Dropbox/UCB Air Monitor/Data/CalibrationFilter_20121203/1714.txt';
%Load spectrum:
spec = load(path);
livetime = 259682.78;  %Live time of spectrum, in seconds

%Background spectrum, for reference:
bkgpath = '/Users/benyee/Dropbox/UCB Air Monitor/Data/cavenopump.txt';
bkgspec = load(bkgpath);
bkglivetime = 164682.65;


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
dt = 52*24*3600+22*3600+56*60;
%Current activity:
act = act_0.*exp(-log(2)./hl*dt);

%Variables to store counts:
cts = zeros(size(act));
bkgcts = cts;
cts_err = cts;
bkgcts_err = cts;

%Cycle through each peak:
for i = 1:length(act)
    
end

eff = (cts-bkgcts)./act;
err = sqrt(cts_err.^2+bkgcts_err.^2)./act;