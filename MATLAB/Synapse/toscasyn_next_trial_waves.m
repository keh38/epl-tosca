function [Y, S] = toscasyn_next_trial_waves(S)

Y = [];

if length(S.totr) < S.nextTrial
   return;
end

tost = S.tost(S.tost >= S.totr(S.nextTrial));
if length(tost) < S.stateNum
   return;
end

i1 = find(S.t >= tost(S.stateNum), 1);

if isempty(i1) || i1+S.npts > length(S.t)
   return;
end

Y = S.waves(i1 + (0:S.npts-1), :);

S.t = S.t(i1+S.npts:end);
S.waves = S.waves(i1+S.npts:end, :);

S.nextTrial = S.nextTrial + 1;
