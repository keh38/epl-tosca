function [counts, S] = toscasyn_get_counts(S)

counts = [];

[codes, times, S] = toscasyn_next_trial_events(S);

if isempty(codes),
   return;
end

counts = zeros(S.numChan, 1);
for k = 1:S.numChan,
   counts(k) = sum(codes==k & times>=S.onset & times<=S.onset+S.width);
end



