function [mean_x,sd_x,count_x] = averageXbyYbin(x,y,y_edges)
%averageXbyYbin(x,y,y_edges) bins data
%Input:
%X: 
%Y:
%Y_edges:
%--------------------------------------------------------------------------
[~,idx] = histc(y,y_edges); % idx returns which bin each point in y goes into

%Initialize to save repeated memory I/O
mean_x = zeros(size(y_edges));
sd_x = zeros(size(y_edges));
count_x = zeros(size(y_edges));

for iBin = length(y_edges):-1:1 % for each bin...    
   if sum(idx == iBin) ~= 0 % at least one sample in this bin
      mean_x(iBin) = nanmean(x(idx == iBin)); % compute average of those x's that go in it
      sd_x(iBin) = nanstd(x(idx == iBin)); % compute sd of those x's that go in it
      count_x(iBin) = numel(x(idx == iBin));
   end 
end