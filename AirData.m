% input variables: data file and region of interest
data_file = 'SampleData.txt';
lower_chan =  2000; 
upper_chan =  8000;

% load data
Data = load(data_file);
Data = Data.*1000;

% for loop to check if each data point is in region of interest
S = size(Data);
N = S(1);


Data_ROI = [];
for i = 1:N
    
    if lower_chan <= Data(i,1) <= upper_chan
        
        Data_ROI = [Data_ROI; Data(i, 1:2)]
      
    else
    
    end
end
% loop doesnt store dat ain range, it just counts the amount of times you
% are in that range (redo above loop)
% check the time when you start, count each time the data is in the range
% until 1000, check that time stamp. 1000/change in time. plot that count
% rate. keep going through data uand have this happen everytime you hit
% 1000 counts in that range

