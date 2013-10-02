function obj = mytsd(varargin)
%Constructor for mytsd class object

if (nargin == 0)
    error('Beep boop beep');
    
end

obj = init;
obj = class(obj, 'mytsd');
if (nargin == 1)
    obj.data = cell2mat(varargin(1));
    obj.timestamps = 1:length(cell2mat(varargin(1)));
elseif (nargin == 2)
    obj.timestamps = cell2mat(varargin(1));
    obj.data = cell2mat(varargin(2));
else    
    obj.timestamps = cell2mat(varargin(1));
    obj.data = cell2mat(varargin(2));    
    obj.header = varargin(3);
end   

function obj = init()
    obj.data = [];
    obj.timestamps = [];
    obj.header = [];