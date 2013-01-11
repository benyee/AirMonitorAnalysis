%This script will be used to acquire data using the LynxDAQ GUI.
clc; clear all; close all;

%Name of directory where data files are located: (Need a slash at the end)
%For Ben's PC:
%dir = 'C:\Users\al gore\Dropbox\UCB Air Monitor\Data\Bkg_20121123withpump\';
%For Ben's MAC:
dir = '/Users/benyee/Dropbox/UCB Air Monitor/Data/Bkg_20121123withpump/';

%Base name of data files: (The data is usually split into multiple
%   files, without the file number and without the .txt)
%For example, if the first file name is data_0.txt, the 2nd one should be
%   data_1.txt, but you should set data_file equal to data_
data_file = 'cavepumpfilter_20121120__2113_56_624_';
%What's the index of the last file?
lastfileindex = 61;

%Each cell will store data from a single file.  We'll keep track of how
%   long each data file is using totaldatalength.
tempdata = cell(1,lastfileindex+1);
totaldatalength = 0;
for i = 1:lastfileindex+1
    tempdata{i} = load([dir data_file num2str(i-1) '.txt']);
    totaldatalength = totaldatalength + size(tempdata{i},1);
end

%Combine all the cells into one matrix:
data = zeros(totaldatalength,2);
marker = 1;
for i = 1:lastfileindex+1
    nextmarker = marker+size(tempdata{i},1);
    data(marker:nextmarker-1,:) = tempdata{i};
    marker = nextmarker;
end
%Now all the data has been consolidated into one matrix named data


%Region of interest:
lower_chan = 2000;
upper_chan = 3000;
ROI = [lower_chan upper_chan];

%Convert bin # to energy:
%E = A + B*ch + C*ch^2 where ch is the bin # (channel)
%Need to find these parameters experimentally later.
conv.A = 0;
conv.B = 1;
conv.C = 0;
E = conv.A + conv.B*data(:,2) + conv.C*data(:,2).^2;

%I think it would be good to write an activity counter function.  Inputs
% would be data and ROI.  Outputs would be time and activity.
counts = 0;
activity = zeros(1000,1);