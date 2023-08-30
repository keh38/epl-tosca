function Y = tosca_extract_ai_subset(AI, signalName, stateNumber, T)

if nargin < 3, stateNumber = -1; end
if nargin < 4, T = Inf; end

isig = find(strcmpi(AI.names, signalName));

if stateNumber < 0
   itrial = find(strcmpi(AI.names, 'Trial'));
   istart = find(diff(AI.data(:, itrial)) > 1, 1);
   imax = size(AI.data, 1);
else
   istate = find(strcmpi(AI.names, 'State'));
   istateMarkers = find(diff(AI.data(:, istate)) > 1);
   istart = istateMarkers(stateNumber);
   if stateNumber < length(istateMarkers)
      imax = istateMarkers(stateNumber + 1);
   else
      imax = size(AI.data, 1);
   end
end

if isfinite(T)
   ifilt = AI.t >= AI.t(istart) && AI.t <= AI.t(istart) + T;
else
   ifilt = istart : imax;
end

Y = AI.data(ifilt, isig);



