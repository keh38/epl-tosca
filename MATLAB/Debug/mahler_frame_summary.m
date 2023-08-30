for kt = 1:length(tl.trials)
   for ks = 1:length(tl.trials{kt}.states)
      fprintf('Trial %d, State %d: %d reps, %d frames\n', ...
         kt, ks, tl.trials{kt}.states(ks).nrep, length(tl.trials{kt}.states(ks).frameNumbers));
   end
end