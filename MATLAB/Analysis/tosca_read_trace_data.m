function TR = tosca_read_trace_data(FN, flatten)
% TOSCA_READ_TRACE_DATA -- read diagnostic trace data
%
% Usage: TR = tosca_read_trace_data(fn)
% 
% Inputs:
%   FN : filename, e.g. 'XYZ999-Session1-Run12.trace.txt'
%
% Output:
%   TR : structure array containing trace data (by trial).
%
% $Rev: 3425 $
% $Date: 2022-11-30 08:19:16 -0500 (Wed, 30 Nov 2022) $
%

if nargin < 2, flatten = false; end

if ~contains(FN, '.trace')
   FN = strrep(FN, '.txt', '.trace.txt');
end

fp = fopen(FN, 'rt');
if fp < 0
   error('Could not find file: %s', FN);
end

c = textscan(fp, '%f %d %s %f %s', 'Delimiter', '\t', 'HeaderLines', 1);
fclose(fp);

t = c{1};
e = c{2};
m = c{3};
d = c{4};
s = c{5};

TR = struct( ...
   'Time', [], ...
   'Event', [], ...
   'Message', {}, ...
   'Data', [], ...
   'Source', {} ...
);

if flatten
   TR(1).Time = t;
   TR.Event = e;
   TR.Message = m;
   TR.Data = d;
   TR.Source = s;
   return;
end

itrial = [find(e == 1); length(e)+1];

for kt = 1:length(itrial)-1
   idx = itrial(kt) : min(itrial(kt+1), length(e));
   TR(kt).Time = t(idx);
   TR(kt).Event = e(idx);
   TR(kt).Message = m(idx);
   TR(kt).Data = d(idx);
   TR(kt).Source = s{idx};
end
