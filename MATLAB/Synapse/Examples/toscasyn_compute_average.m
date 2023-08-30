function toscasyn_compute_average(fn)

% Initialize figure
fig = figure(1);
ud = guidata(fig);

if isempty(ud)
   ud.filename = '';
end

% If filename changed, reinitialize analysis and display
if ~isequal(ud.filename, fn)
   ud.filename = fn;
   ud.events_offset = 0;
   ud.waves_offset = 0;
   ud.waves = [];
   ud.t = [];

   ud.nextTrial = 1;
   ud.totr = [];
   ud.tost = [];
   
   ud.stateNum = 2;
   
   ud.dt = 1000 / toscasyn_coerce_TDT_sampling_rate(25000);
   ud.tlast = -ud.dt;
   ud.npts = round(500 / ud.dt);

   ud.data = [];
   ud.tdata = (0:ud.npts-1) * ud.dt;
   ud.ntr = 0;

   guidata(fig, ud);
end

% Read trial markers from where we left off last time
[codes, times, ud.events_offset] = toscasyn_read(ud.filename, ud.events_offset);
ud.totr = [ud.totr; times(codes == -3)];
ud.tost = [ud.tost; times(codes == -2)];

% Read waves from where we left off last time
[waves, ud.waves_offset] = toscasyn_read_waves(ud.filename, ud.waves_offset);
if isempty(waves)
	guidata(fig, ud);
	return;
end

ud.t = [ud.t ud.tlast + (1:size(waves,1))*ud.dt];
ud.tlast = ud.t(end);
ud.waves = [ud.waves; waves];

% Process data
while true
   [y, ud] = toscasyn_next_trial_waves(ud);
   if isempty(y), break; end

   if ud.ntr == 0
      ud.data = y;
   else
      ud.data = (ud.data * ud.ntr + y) / (ud.ntr+1);
   end
   
   ud.ntr = ud.ntr + 1;

end

guidata(fig, ud);

if ~isempty(ud.data)
   plot(ud.tdata, ud.data);
end

