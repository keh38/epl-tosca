function Trxn = tosca_find_reaction_times(Params, Data, eventName, Tmax)
% TOSCA_FIND_REACTION_TIMES -- find reaction times from .di data
% Usage: Trxn = tosca_find_reaction_times(Params, Data, eventName, Tmax)
% 
% Inputs:
%   Params, Data : structures returned by TOSCA_READ_RUN
%   eventName    : name of response event, e.g. 'Lick'
%   Tmax         : response window length, seconds
%
% Output:
%   Trxn : reaction times in milliseconds
%
% $Rev: 3415 $
% $Date: 2022-10-13 13:10:00 -0400 (Thu, 13 Oct 2022) $
%

rxn_time_min_s = 0;
rxn_time_window_s = Tmax;

Trxn = NaN(size(Data));

for k = 1:length(Data)
   if isnan(Data{k}.N), continue; end

   % Find the target state in the history
   itarg = find(strcmp(strtrim(Data{k}.History(1:2:end)), Params.Tosca.Target_state));
   
   if isempty(itarg)
      fprintf('Target state not found in trial %d\n', Data{k}.N);
   else
      % Read .di data
      s = tosca_read_trial(Params, Data, Data{k}.N);

      % Find state changes
      istateChange = [1 find(diff(s.State_Change) > 0.5)];

      % Find start of target state
      itargStart = istateChange(itarg);

      % Find response window
      t = s.Time_s - s.Time_s(itargStart);
      ifilt = t >= rxn_time_min_s & t <= (rxn_time_min_s + rxn_time_window_s);

      % Find first occurrence of response event in the response window
      iresp = find(diff(s.(eventName)(ifilt)) > 0, 1);

      if ~isempty(iresp)
         t = t(ifilt);
         Trxn(k) = t(iresp) * 1000;
      end
   end
end