function [psth, S] = toscasyn_get_psth(S)

psth = [];

[codes, times, S] = toscasyn_next_trial_events(S);

if isempty(codes)
   return;
end

psth = zeros(S.numChan, S.numBins);
for k = 1:S.numChan
   psth(k, :) = hist(times(codes==k & times < max(S.bins)), S.bins);
end



