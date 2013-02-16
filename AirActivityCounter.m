function [t_out,a,ci] = AirActivityCounter(t_in,bin,conv,N,binROI,...
    numPeaks,sig_est,plotflag,cubicflag)
%Inputs:
%   t_in = timestamps corresponding to each entry in E
%   bin = bin #'s for each event, should be same size as t_in
%   conv - see binToE, will be used to convert bin #s to energies
%   N = number of total counts per data point (higher = less data points,
%       but more accurate.  lower = more data points, less accurate)
%   binROI = 2x1 array of integers indicating the lower and upper bin numbers.
%       Peak of interest should be >=ROI(1) and <=ROI(2).
%   See PeakFit.m for description of remaining inputs
%
%Outputs
%   t_out = timestamps corresponding to a
%   a - a(i) is the activity at time t_out(i)
%   ci - ci(:,i) gives the 1 sigma confidence intervals below and above
%       a(i).  ci(1,i) is the upper limit and ci(2,i) is the lower limit

%This is the largest that t_out and a can be:
t_out = zeros(ceil(length(t_in)/N),1);
a = t_out;
ci = zeros(2,length(t_out));

%i will track the t_out and a index.
%j will track the t_in and bin index.
i = 1; j = 1;
while i <= length(t_out) && j<=length(t_in)
    counts = zeros(binROI(2),1);
    t_start = t_in(j);
    
    %k will track the number of counts in the current data point.
    k = 1;
    
    while k < N && j <= length(t_in)
        if bin(j)>=binROI(1) && bin(j)<=binROI(2)
            counts(bin(j)) = counts(bin(j)) + 1;
            k = k+1;
        end
        j = j+1;
    end
    
    %Disregard last set of data: (We will most likely be cut off since the
    %   data length isn't an exact multiple of n)
    %   Here we check by seeing if the last data point has N counts.  If it
    %   has fewer, it is ignored.
    if k < N
        break;
    end
    
    t_end = (t_in(j-1)+t_in(j-2))/2;
    dt = t_end-t_start;
    %This data point's timestamp will be the average of the first and last
    %   timestamps we looked at:
    t_out(i) = (t_start+t_end)/2;
    
    %Perform a peakfit:
    res = PeakFit(binToE(binROI(1):binROI(2),conv),...
        counts(binROI(1):binROI(2)),binToE(binROI,conv),numPeaks,...
        sig_est,plotflag,cubicflag);
    a(i) = res.src1cnts/dt;
    ci(:,i) = res.ci(:,1)/dt;
    
    i = i+1;
end

%Remove excess entries:
a = a(1:i-1);
t_out = t_out(1:i-1);
ci = ci(:,1:i-1);

end