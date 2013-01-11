function [t_out,a] = AirActivityCounter(t_in,E,n,ROI,numPeaks,sig_est,cubicflag)
%Inputs:
%   t_in = timestamps corresponding to each entry in E
%   E = energy (or bin #), should be same size as t_in
%   ROI = 2x1 array.  Peak of interest must be higher than ROI(1), less
%       than ROI(2)
%   n = number of total counts per data point
%   See PeakFit.m for description of remaining inputs
%
%Outputs
%   t_out = timestamps corresponding to a
%   a - a(i) is the activity at time t_out(i)

%I
t_out = zeros(floor(ceil(length(t_in))/n),1);
a = t_out;

i = 1;
while i <= length(t_out)
    j = 1;
    
end

end