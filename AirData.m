%This script will be used to analyze data acquired using the LynxDAQ GUI.

%If data hasn't been loaded, load the data.
if exist('data')~=1
    clc; clear all; %close all;

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
        progressbar(i/(lastfileindex+1));
    end

    %Combine all the cells into one matrix:
    data = zeros(totaldatalength,2);
    marker = 1;
    for i = 1:lastfileindex+1
        nextmarker = marker+size(tempdata{i},1);
        data(marker:nextmarker-1,:) = tempdata{i};
        marker = nextmarker;
        progressbar(i/(lastfileindex+1));
    end
    %Now all the data has been consolidated into one matrix named data
end


%Region of interest:
binROI = [3900 4100];

%Convert bin # to energy:
%E = A + B*ch + C*ch^2 where ch is the bin # (channel)
%Need to find these parameters experimentally later.
conv.A = 0;
conv.B = 1;
conv.C = 0;

[t,a,err] = AirActivityCounter(data(:,2),data(:,1),conv,2000,binROI);
figure(gcf+1);
errorbar((t-t(1))/3600,a,err,'*--');
xlabel('Hours'); ylabel('Activity (Bq)');