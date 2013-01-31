%Calibration Analysis Script
%Stephen Comment
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
peaks = round(E/1460*3977);
%Activities given in the calibration info sheet:
act_0 = [669.3 945.7 503.9 713.8 1525 979.6 643.6 2372 1208 1208 2512];
%Half-lives, in days, as given by calibration info sheet:
hl = [1.58e5 462.6 271.8 137.6 46.61 115.1 10980 106.6 1925 1925 106.6];
hl = hl*24*3600; %Half-lives, in seconds
%Time between calibration sheet validation and measurement, in seconds:
dt = 52*24*3600+22*3600+56*60;
%Current activity:
act = act_0.*exp(-log(2)./hl*dt);

%Half-Widths of each ROI: (to the left and right of "peaks")
dPL = 50*ones(size(act));
dPR = dPL;
dPR(3) = 30;
dPL(5) = 20; dPR(5) = 40;
%Number of lines in each ROI: (Most should be 1)
numPeaks = ones(size(act));
%Whether to take the left (0) or right (1) peak
whichPeak = zeros(size(numPeaks));




%Variables to store counts:
cts = zeros(size(act));
bkgcts = cts;
cts_err = cts;
bkgcts_err = cts;

%Cycle through each peak:
for i = 1:length(act)
    ROI = [peaks(i)-dPL(i) peaks(i)+dPR(i)];
   
    temp = PeakFit(ROI(1):ROI(2),spec(ROI(1):ROI(2)),ROI,numPeaks(i),5,0,0);
    cts(i) = temp.src1cnts;
    %cts_err(i) = sqrt(temp.cnts1^2+temp.bkgcnts^2);
    
    temp = PeakFit(ROI(1):ROI(2),bkgspec(ROI(1):ROI(2)),ROI,numPeaks(i),5,0,0);
    %Check to make sure that the fit isn't some weird glitch:
    if temp.bkgcnts > 0
        bkgcts(i) = temp.src1cnts;
        %bkgcts_err(i) = sqrt(temp.cnts1^2+temp.bkgcnts^2);
    end
end

eff = (cts/livetime-bkgcts/bkglivetime)./act;
err = sqrt(cts/livetime + bkgcts/bkglivetime)./act;
%err = sqrt((cts_err/livetime).^2+(bkgcts_err/bkglivetime).^2)./act;