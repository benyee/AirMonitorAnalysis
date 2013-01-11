function [t_out,a] = AirActivityCounter(t_in,bin,conv,n,binROI,numPeaks,sig_est,cubicflag)
%Inputs:
%   t_in = timestamps corresponding to each entry in E
%   E = bin #'s for each event, should be same size as t_in
%   conv - see binToE, will be used to convert bin #s to energies
%   n = number of total counts per data point (higher = less data points,
%       but more accurate.  lower = more data points, less accurate)
%   binROI = 2x1 array of integers indicating the lower and upper bin numbers.
%       Peak of interest should be >=ROI(1) and <=ROI(2).
%   See PeakFit.m for description of remaining inputs
%
%Outputs
%   t_out = timestamps corresponding to a
%   a - a(i) is the activity at time t_out(i)

%This is the largest that t_out and a can be:
t_out = zeros(ceil(length(t_in)/n),1);
a = t_out;

%i will track the t_out and a index.
%j will track the t_in and bin index.
i = 1; j = 1;
while i <= length(t_out) && j<=length(t_in)
    counts = zeros(binROI(2),1);
    t_start = t_in(j);
    k = 1;
    
    while k <= n && j <= length(t_in)
        if bin(j)>=binROI(1) && bin(j)<=binROI(2)
            counts(bin(j)) = counts(bin(j)) + 1;
            k = k+1;
        end
        j = j+1;
    end
    
    %Disregard last set of data: (We will most likely be cut off since the
    %   data length isn't an exact multiple of n)
    if k<=n
        break;
    end
    
    t_end = t_in(j-1);
    dt = t_start-t_end;
    %This data point's timestamp will be the average of the first and last
    %   timestamps we looked at:
    t_out(i) = (t_start+t_end)/2;
    
    %Will modify this later.  For now it's just an overall activity.
    a(i) = sum(counts)/dt;
    i = i+1;
end

%Remove excess entries:
a = a(1:i-1);
t_out = t_out(1:i-1);

end