function TR = tosca_trace(varargin)
% TOSCA_TRACE
% Usage 1: tosca_trace(fn, trialNum)
% Usage 2: tosca_trace(p, d, trialNum);
%
% $Rev: 3425 $
% $Date: 2022-11-30 08:19:16 -0500 (Wed, 30 Nov 2022) $
%


if nargin == 2
   fn = varargin{1};
   trialNum = varargin{2};
   [d,p] = tosca_read_run(fn);
else
   p = varargin{1};
   d = varargin{2};
   trialNum = varargin{3};
   fn = p.Info.Filename;
end
   
s = tosca_read_trial(p, d, trialNum);
tr = tosca_read_trace_data(fn, false);

% itrial = find(tr.Event == 1);
% i1 = itrial(trialNum);
% 
% i2 = itrial(find(tr.Time(itrial) < max(s.Time_s), 1, 'last'));
% if isempty(i2) || i2 == i1
%    if trialNum < length(itrial)
%       i2 = itrial(trialNum + 1);
%    else
%       i2 = length(tr.Time);
%    end
% end
% ifilt = i1:i2;
% 
% tr.Time = tr.Time(ifilt);
% tr.Event = tr.Event(ifilt);
% tr.Message = tr.Message(ifilt);
% tr.Data = tr.Data(ifilt);
% tr.Source = tr.Source(ifilt);
tr = tr(trialNum);

if nargout
   TR = tr(trialNum);
   return;
end

tosca_plot_trial(s, tr);
