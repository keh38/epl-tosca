function TL = tosca_add_ao_frames_to_log(TL)
% Extracts analog frame triggers from AI data. For widefield imaging on
% Mahler.

if isfield(TL.trials{1}.states(1), 'frameNumbers')
   return;
end

frameOffset = 0;
for kt = 1:length(TL.trials)
   ai = tosca_read_ai(TL.params, TL.trials, kt);
   npts = size(ai.data, 1);

   istate = find(strcmp(ai.names, 'State'));
   tstate = [find(diff(ai.data(:, istate)') > 2) inf];

   ifr = find(strcmp(ai.names, 'Frame Trigger'));
   tfr = find(diff(ai.data(:, ifr)') > 2);
   tfr = tfr(tfr >= tstate(1));

   % read next file to get tail end
   if kt < length(TL.trials)
      ai = tosca_read_ai(TL.params, TL.trials, kt+1);
      nextState = find(diff(ai.data(:, istate)') > 2, 1);
      tailEnd = find(diff(ai.data(:, ifr)') > 2);
      tfr = [tfr  npts + tailEnd(tailEnd < nextState)];
   end

   frameNum = 1:length(tfr);

   for ks = 1:length(tstate)-1
      ifilt = tfr >= tstate(ks) & tfr < tstate(ks+1);
      TL.trials{kt}.states(ks).frameNumbers = frameOffset + frameNum(ifilt);
   end

   frameOffset = frameOffset + length(tfr);

end
