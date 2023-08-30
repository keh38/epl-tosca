function [codes, times, S] = toscasyn_next_trial_events(S)

codes = [];
times = [];

% Find next pair of trial markers (which bookend the trial we're analyzing)
itr = find(S.codes == -3, 2);

if isempty(itr)
   return;
end

if length(itr) == 1
   itr(2) = length(S.codes);
end

% Extract event codes and times for this trial
codes = S.codes(itr(1):itr(2));
times = S.times(itr(1):itr(2));

% Find window state
istate = find(codes == -2);

% For the last state, there is an implicit state change at the final trial
% delimiter
if length(istate)==S.state && codes(end)==-3
   istate(end+1) = length(codes);
end

% Must have the marker for the state we're analyzing, plus the state
% following, to be sure we have all the data
if length(istate) < S.state + 1
   codes = [];
   times = [];
   return;
end

% Made it this far, we have good data. Remove it from the unanalyzed data.
S.codes = S.codes(itr(2):end);
S.times = S.times(itr(2):end);

codes = codes(istate(S.state) : istate(S.state+1));
times = times(istate(S.state) : istate(S.state+1));

irep = find(codes == -1);
if length(irep) == 1
   irep(2) = length(codes);
end
codes = codes(irep(S.rep) :  irep(S.rep+1));
times = times(irep(S.rep) :  irep(S.rep+1));

times = times - times(1);



