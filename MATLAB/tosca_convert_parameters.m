function tosca_convert_parameters(fn)

try
   fclose all;
   
   c = parse_ini_config(fn);
   if ~contains(fn, '.old')
      copyfile(fn, strrep(fn, '.ini', '.old.ini'));
   else
      fn = strrep(fn, '.old', '');
   end
      
   old = c.Tosca_Params;
   
   stateNames = cell(length(old.Flowchart), 1);
   targetState = '';
   
   if isfield(old.Flowchart(1), 'Flow_Element')
      for k = 1:length(old.Flowchart)
         fc(k) = old.Flowchart(k).Flow_Element;
      end
      old.Flowchart = fc;
   end

   for k = 1:length(old.Flowchart)
      name = old.Flowchart(k).Name;
      n = 2;
      while true
         if ~any(strcmp(stateNames, name))
            break;
         end
         name = [old.Flowchart(k).Name ' ' num2str(n)];
         n = n + 1;
      end
      stateNames{k} = name;
      if old.Flowchart(k).Target > 0
         targetState = name;
      end
   end
   
   sigmanNames = cell(length(old.Output_States), 1);
   for k = 1:length(old.Output_States)
      sigmanNames{k} = old.Output_States(k).Data_2.Name;
   end
   
   masker = [];
   if ~strcmpi(old.Masker.Channel, 'off')
      imask = -1;
      for k = 1:length(old.Output_States(1).Data_2.StimChans)
         if strcmp(old.Output_States(1).Data_2.StimChans(k).Name, old.Masker.Channel)
            imask = k;
            masker = old.Output_States(1).Data_2.StimChans(k);
            break;
         end
      end
      if imask >=0
         old.Output_States(1).Data_2.StimChans(imask).Waveform.Type = 'OFF';
      end
   end
   
   AOFs = old.DAQ.AO_Sampling_Rate_Hz;
   
   tmpfile = fullfile(fileparts(fn), 'tmp.ini');
   fp = fopen(tmpfile, 'wt');
   fprintf(fp, '[Metadata]\nVersion=2920\n');
   fprintf(fp, '[Tosca]\n');
   fprintf(fp, 'Tosca.Version=0\n');
   
   fprintf(fp, 'Tosca.Flowchart=<%d>\n', length(old.Flowchart));
   for k = 1:length(old.Flowchart)
      isig = strcmp(sigmanNames, old.Flowchart(k).Name);
      convert_flowchart_element(fp, k, ...
         old.Flowchart(k), ...
         stateNames,...
         old.Output_States(isig).Data_2, ...
         AOFs);
   end
   
   fprintf(fp, 'Tosca.First state=%s\n', stateNames{2});
   
   fprintf(fp, 'Tosca.Input Events=<%d>\n', length(old.Input_Events));
   for k = 1:length(old.Input_Events)
      convert_input(fp, k, old.Input_Events(k).Input_Event);
   end
   
   nf = 0;
   if isfield(old, 'Flags')
      nf = length(old.Flags);
   end
   fprintf(fp, 'Tosca.Flags=<%d>\n', nf);
   for k = 1:nf
      fprintf(fp, 'Tosca.Flags %d.Flag.Name=%s\n', k-1, old.Flags(k).Name);
      fprintf(fp, 'Tosca.Flags %d.Flag.Default=%g\n', k-1, old.Flags(k).Default);
   end
   
   fprintf(fp, 'Tosca.DAQ.AO Fs (Hz)=%g\n', old.DAQ.AO_Sampling_Rate_Hz);
   fprintf(fp, 'Tosca.DAQ.DO Fs (Hz)=%g\n', old.DAQ.DO_Sampling_Rate_Hz);
   fprintf(fp, 'Tosca.DAQ.Poll Rate (Hz)=%g\n', old.DAQ.Poll_Rate_Hz);
   
   fprintf(fp, 'Tosca.Schedule Mode=%s\n', old.Schedule.Mode);
   fprintf(fp, 'Tosca.Description=%s\n', old.Description);
   fprintf(fp, 'Tosca.MATLAB function=%s\n', old.MATLAB_function);
   
   fprintf(fp, 'Tosca.Imaging.mode=%s\n', old.Imaging.mode);
   fprintf(fp, 'Tosca.Imaging.FrameRateHz=%s\n', old.Imaging.FrameRateHz);
   
   fprintf(fp, 'Tosca.Connect.Tracking=%s\n', logical_to_string(old.DAQ.Tracking));
   fprintf(fp, 'Tosca.Connect.Synapse=%s\n', logical_to_string(old.DAQ.Synapse));
   fprintf(fp, 'Tosca.Connect.Pupil=%s\n', logical_to_string(~strcmpi(old.DAQ.Pupil, 'off')));
   fprintf(fp, 'Tosca.Connect.Loco=%s\n', logical_to_string(old.DAQ.Loco));
   if isfield(old.DAQ, 'Retrieve')
      fprintf(fp, 'Tosca.Connect.Retrieve=%s\n', logical_to_string(old.DAQ.Retrieve));
   else
      fprintf(fp, 'Tosca.Connect.Retrieve=FALSE\n');
   end
   
   fprintf(fp, 'Tosca.Target state=%s\n', targetState);
   fprintf(fp, 'Tosca.Link to=\n');
   
   convert_adapt(fp, old.Adapt);
   convert_schedule(fp, old.Schedule);
   
   fprintf(fp, 'Tosca.Pretrial.Path=%s\n', old.Pretrial.Path);
   fprintf(fp, 'Tosca.Pretrial.Args=<%d>\n', length(old.Pretrial.Args));
   for k = 1:length(old.Pretrial.Args)
      fprintf(fp, 'Tosca.Pretrial.Args %d=%s\n', k-1, old.Pretrial.Args{k});
   end
   
   if isempty(masker)
      fprintf(fp, 'Tosca.Masker.Version=0\n');
      fprintf(fp, 'Tosca.Masker.Channel=\n');
      fprintf(fp, 'Tosca.Use masker=FALSE\n');
   else
      convert_masker(fp, masker);
      fprintf(fp, 'Tosca.Use masker=TRUE\n');
   end
   
   
   
   fprintf(fp, '\n[FSM]\n');
   fprintf(fp, 'FSM.Graph.Version=0\n');
   fprintf(fp, 'FSM.Graph.Nodes=<%d>\n', length(old.Flowchart));
   for k = 1:length(old.Flowchart)
      isig = strcmp(sigmanNames, old.Flowchart(k).Name);
      convert_node(fp, k, old.Flowchart(k), old.Output_States(isig).Data_2, stateNames, targetState);
   end
   
   edges = [];
   for k = 1:length(old.Flowchart)
      e = create_outgoing(k, old.Flowchart, stateNames);
      if isempty(edges)
         edges = e;
      elseif ~isempty(e)
         edges = [edges e];
      end
   end
   for k = 1:length(old.Flowchart)
      edges = create_incoming(edges, k, old.Flowchart, stateNames);
   end
   
   fprintf(fp, 'FSM.Graph.Edges=<%d>\n', length(edges));
   for k = 1:length(edges)
      convert_edge(fp, k, edges(k));
   end
   
   fclose(fp);
   
   movefile(tmpfile, fn, 'f');
catch ex
   fclose all;
   rethrow(ex);
end

%--------------------------------------------------------------------------
function convert_flowchart_element(fp, num, fe, stateNames, sigman, AOFs)

prefix = sprintf('Tosca.Flowchart %d.State', num-1);
fprintf(fp, '%s.Version=0\n', prefix);
fprintf(fp, '%s.Name=%s\n', prefix, stateNames{num});
fprintf(fp, '%s.TTL-only=FALSE\n', prefix);

fprintf(fp, '%s.Timeouts=<%d>\n', prefix, length(fe.Timeouts));
for k = 1:length(fe.Timeouts)
   convert_timeout(fp, prefix, k, fe.Timeouts(k), stateNames, fe.Target);
end
fprintf(fp, '%s.Term=<%d>\n', prefix, length(fe.Term_Cond));
for k = 1:length(fe.Term_Cond)
   convert_term(fp, prefix, k, fe.Term_Cond(k).Cluster, stateNames, fe.Target);
end

convert_sigman(fp, prefix, sigman, AOFs);
grating = [];
if isfield(sigman, 'Grating')
   grating = sigman.Grating;
end
convert_grating(fp, prefix, grating);

fprintf(fp, '%s.Execute script=FALSE\n', prefix);

%--------------------------------------------------------------------------
function convert_timeout(fp, prefix, num, to, stateNames, isTarget)

prefix = sprintf('%s.Timeouts %d.Timeout', prefix, num-1);
fprintf(fp, '%s.Version=0\n', prefix);
fprintf(fp, '%s.Type=%s\n', prefix, to.Type);

linkTo = '';
if to.Next > -1
   linkTo = stateNames{to.Next + 1};
end
fprintf(fp, '%s.Link to=%s\n', prefix, linkTo);
fprintf(fp, '%s.Expr=%s\n', prefix, expression_to_string(to.Expr));
fprintf(fp, '%s.Units=%s\n', prefix, to.Units);

fprintf(fp, '%s.TTL=<%d>\n', prefix, length(to.TTL));
for k = 1:length(to.TTL)
   convert_ttl(fp, prefix, k, to.TTL(k));
end

result = '';
color = hex2dec('808080');

if isTarget
   switch to.Type
      case 'Normal'
         result = 'No go';
         color = hex2dec('FF0000');
         
      case 'CS+'
         result = 'Miss';
         color = hex2dec('FF0000');
         
      case 'CS-'
         result = 'Withhold';
         color = hex2dec('00FF00');
   end
end

fprintf(fp, '%s.Result=%s\n', prefix, result);
fprintf(fp, '%s.Color=%d\n', prefix, color);

%--------------------------------------------------------------------------
function convert_term(fp, prefix, num, term, stateNames, isTarget)

prefix = sprintf('%s.Term %d.Term', prefix, num-1);
fprintf(fp, '%s.Version=0\n', prefix);
fprintf(fp, '%s.Type=%s\n', prefix, term.Type);
fprintf(fp, '%s.Source=%s\n', prefix, term.Name);

linkTo = '';
if term.Next > -1
   linkTo = stateNames{term.Next + 1};
end
fprintf(fp, '%s.Link to=%s\n', prefix, linkTo);

fprintf(fp, '%s.End after (ms)=%g\n', prefix, term.End_after_ms);
fprintf(fp, '%s.Latency (ms)=%g\n', prefix, term.Latency_ms);
fprintf(fp, '%s.Action=%s\n', prefix, term.Action);
fprintf(fp, '%s.Nttl=%d\n', prefix, term.Nttl);
fprintf(fp, '%s.Tttl=%g\n', prefix, term.Tttl);
fprintf(fp, '%s.one shot=%d\n', prefix, term.one_shot);

fprintf(fp, '%s.TTL=<%d>\n', prefix, length(term.TTL));
for k = 1:length(term.TTL)
   convert_ttl(fp, prefix, k, term.TTL(k));
end

fprintf(fp, '%s.End on rep=%d\n', prefix, term.End_on_rep);

result = '';
color = hex2dec('808080');

if isTarget
   switch term.Type
      case 'Normal'
         result = 'Go';
         color = hex2dec('00FF00');
         
      case 'CS+'
         result = 'Hit';
         color = hex2dec('00FF00');
         
      case 'CS-'
         result = 'False Alarm';
         color = hex2dec('FF0000');
   end
end

fprintf(fp, '%s.Result=%s\n', prefix, result);
fprintf(fp, '%s.Color=%d\n', prefix, color);

%--------------------------------------------------------------------------
function convert_ttl(fp, prefix, num, ttl)

prefix = sprintf('%s.TTL %d.TTL', prefix, num-1);
fprintf(fp, '%s.Version=2\n', prefix);
fprintf(fp, '%s.Class=TTLController\n', prefix);
fprintf(fp, '%s.Name=%s\n', prefix, ttl.Name);
fprintf(fp, '%s.Start.When=%s\n', prefix, ttl.Start.When);
fprintf(fp, '%s.Start.Expr=%s\n', prefix, expression_to_string(ttl.Start.Expr));
fprintf(fp, '%s.Stop.When=%s\n', prefix, ttl.Stop.When);
fprintf(fp, '%s.Stop.Expr=%s\n', prefix, expression_to_string(ttl.Stop.Expr));
fprintf(fp, '%s.Pulse.Active=%s\n', prefix, logical_to_string(ttl.Pulse.Active));
fprintf(fp, '%s.Pulse.IPI=%d\n', prefix, expression_to_string(ttl.Pulse.IPI));
fprintf(fp, '%s.Pulse.Width=%g\n', prefix, ttl.Pulse.Width_ms);

%--------------------------------------------------------------------------
function convert_sigman(fp, prefix, sigman, fs)

prefix = sprintf('%s.SigMan', prefix);
fprintf(fp, '%s.Version=0\n', prefix);
fprintf(fp, '%s.Fs (Hz)=%g\n', prefix, fs);
fprintf(fp, '%s.Interval (ms)=%g\n', prefix, sigman.T_s * 1000);

isc = [];
for k = 1:length(sigman.StimChans)
   if ~strcmpi(sigman.StimChans(k).Waveform.Type, 'off')
      isc(end+1) = k;
   end
end

fprintf(fp, '%s.Channels=<%d>\n', prefix, length(isc));
for k = 1:length(isc)
   convert_channel(fp, prefix, k, sigman.StimChans(isc(k)));
end

%--------------------------------------------------------------------------
function convert_channel(fp, prefix, num, chan)

prefix = sprintf('%s.Channels %d.Channel', prefix, num-1);
fprintf(fp, '%s.Version=0\n', prefix);
fprintf(fp, '%s.Name=%s\n', prefix, chan.Name);
fprintf(fp, '%s.Destination=%s\n', prefix, chan.Name);
fprintf(fp, '%s.AltPol=%s\n', prefix, logical_to_string(chan.Advanced.AltPol));
if isfield(chan.Advanced, 'Persist')
   fprintf(fp, '%s.Persist=%s\n', prefix, logical_to_string(chan.Advanced.Persist));
else
   fprintf(fp, '%s.Persist=FALSE\n', prefix);
end

if strcmp(chan.Waveform.Type, 'FM Sweep')
   chan.Burst.Active = true;
   chan.Burst.Ramp_ms = chan.Waveform.FMSweep.Ramp_ms;
end

convert_waveform(fp, prefix, chan.Waveform);
convert_gate(fp, prefix, chan.Burst);
convert_level(fp, prefix, chan.Level);
convert_am(fp, prefix, chan.SAM);
convert_filter(fp, prefix, chan.Filter);

fprintf(fp, '%s.Invert=FALSE\n', prefix);

%--------------------------------------------------------------------------
function convert_masker(fp, chan)

prefix = sprintf('Tosca.Masker');
fprintf(fp, '%s.Version=0\n', prefix);
fprintf(fp, '%s.Name=%s\n', prefix, chan.Name);
fprintf(fp, '%s.Destination=%s\n', prefix, chan.Name);
fprintf(fp, '%s.AltPol=%s\n', prefix, logical_to_string(chan.Advanced.AltPol));
fprintf(fp, '%s.Persist=%s\n', prefix, logical_to_string(chan.Advanced.Persist));

convert_waveform(fp, prefix, chan.Waveform);
convert_gate(fp, prefix, chan.Burst);
convert_level(fp, prefix, chan.Level);
convert_am(fp, prefix, chan.SAM);
convert_filter(fp, prefix, chan.Filter);

fprintf(fp, '%s.Invert=FALSE\n', prefix);

%--------------------------------------------------------------------------
function convert_waveform(fp, prefix, wf)

prefix = sprintf('%s.Waveform', prefix);
fprintf(fp, '%s.Version=0\n', prefix);
fprintf(fp, '%s.Class=%s\n', prefix, wf.Type);

switch wf.Type
   case 'File'
      fprintf(fp, '%s.Filename=%s\n', prefix, wf.File.Filename);

   case 'FM Sweep'
      fprintf(fp, '%s.Rate=%g\n', prefix, wf.FMSweep.Rate_oct_s);
      fprintf(fp, '%s.Fmin (Hz)=%g\n', prefix, wf.FMSweep.Fmin_Hz);
      fprintf(fp, '%s.Fmax (Hz)=%g\n', prefix, wf.FMSweep.Fmax_Hz);
      fprintf(fp, '%s.Linear=%s\n', prefix, logical_to_string(wf.FMSweep.Linear));
      fprintf(fp, '%s.ConstFreqRamp=TRUE\n', prefix);
      
   case 'Noise'
      fprintf(fp, '%s.Seed=%g\n', prefix, wf.Noise.Seed);
      fprintf(fp, '%s.Tokens=0\n', prefix);
      fprintf(fp, '%s.InvFilt=%s\n', prefix, logical_to_string(wf.Noise.InvFilt));
      fprintf(fp, '%s.Aweight=%s\n', prefix, logical_to_string(wf.Noise.Aweight));
      
   case 'Tone'
      fprintf(fp, '%s.Frequency (kHz)=%g\n', prefix, wf.Tone.Frequency_kHz);
      fprintf(fp, '%s.Phase (cycles)=0\n', prefix);
      
   case 'Pulse Train'
      switch lower(wf.Pulse_Train.Polarity)
         case 'pos-neg'
            shape = '[1 -1]';
            width = ['[' num2str(wf.Pulse_Train.Pulse_width_us*[1 1],'%g ') ']'];
         case 'neg-pos'
            shape = '[-1 1]';
            width = ['[' num2str(wf.Pulse_Train.Pulse_width_us*[1 1],'%g ') ']'];
         case 'pos'
            shape = '[1]';
            width = ['[' num2str(wf.Pulse_Train.Pulse_width_us) ']'];
         case 'neg'
            shape = '[-1]';
            width = ['[' num2str(wf.Pulse_Train.Pulse_width_us) ']'];
      end
      
      fprintf(fp, '%s.Shape=%s\n', prefix, shape);
      fprintf(fp, '%s.Width (us)=%s\n', prefix, width);
      fprintf(fp, '%s.Rate (Hz)=%g\n', prefix, wf.Pulse_Train.Pulse_rate_Hz);
      
   otherwise
      error('Unexpected waveform type: %s', wf.Type);
end

%--------------------------------------------------------------------------
function convert_gate(fp, prefix, g)

prefix = sprintf('%s.Gate', prefix);
fprintf(fp, '%s.Version=0\n', prefix);

shape = 'OFF';
if g.Active
   shape = 'Sine-squared';
end
fprintf(fp, '%s.Shape=%s\n', prefix, shape);
fprintf(fp, '%s.Delay (ms)=%g\n', prefix, g.Delay_ms);
fprintf(fp, '%s.Duration (ms)=%g\n', prefix, g.Duration_ms);
fprintf(fp, '%s.Ramp (ms)=%g\n', prefix, g.Ramp_ms);
fprintf(fp, '%s.Repeat=%s\n', prefix, logical_to_string(g.Repeat));
fprintf(fp, '%s.Rate (Hz)=%g\n', prefix, g.Rate_Hz);
fprintf(fp, '%s.Trepeat (ms)=%g\n', prefix, g.Trepeat_ms);

%--------------------------------------------------------------------------
function convert_level(fp, prefix, level)

prefix = sprintf('%s.Level', prefix);
fprintf(fp, '%s.Version=0\n', prefix);
fprintf(fp, '%s.Level=%g\n', prefix, level.Level);
fprintf(fp, '%s.Units=%s\n', prefix, level.Units);

%--------------------------------------------------------------------------
function convert_am(fp, prefix, am)

prefix = sprintf('%s.AM', prefix);
fprintf(fp, '%s.Version=0\n', prefix);

amclass = 'AM';
if am.Active
   amclass = 'SAM';
end

fprintf(fp, '%s.Class=%s\n', prefix, amclass);
fprintf(fp, '%s.Correct level=TRUE\n', prefix);
fprintf(fp, '%s.Depth (0-1)=%g\n', prefix, am.Depth);
fprintf(fp, '%s.Frequency (Hz)=%g\n', prefix, am.Frequency_Hz);
fprintf(fp, '%s.Phase (0-1)=%g\n', prefix, am.Init_Phase_cycles);

%--------------------------------------------------------------------------
function convert_filter(fp, prefix, f)

prefix = sprintf('%s.Filter', prefix);
fprintf(fp, '%s.Version=0\n', prefix);

fprintf(fp, '%s.Type=%s\n', prefix, f.Type);
fprintf(fp, '%s.CF (kHz)=%g\n', prefix, f.CF_kHz);
fprintf(fp, '%s.BW (kHz)=%g\n', prefix, f.BW_kHz);
fprintf(fp, '%s.Units=%s\n', prefix, f.BWUnits);
fprintf(fp, '%s.Class=Butterworth\n', prefix);
fprintf(fp, '%s.Order=4\n', prefix);
fprintf(fp, '%s.Cascade=FALSE\n', prefix);

%--------------------------------------------------------------------------
function convert_grating(fp, prefix, grating)

prefix = sprintf('%s.Grating', prefix);

if ~isempty(grating)
   fprintf(fp, '%s.Type=%s\n', prefix, grating.Type);
   fprintf(fp, '%s.Orientation (deg)=%g\n', prefix, grating.Orientation_deg);
   fprintf(fp, '%s.Spatial frequency (cpd)=%g\n', prefix, grating.Spatial_frequency_cpd);
   fprintf(fp, '%s.Velocity (Hz)=%g\n', prefix, grating.Velocity_Hz);
   fprintf(fp, '%s.Contrast=%g\n', prefix, grating.Contrast);
   fprintf(fp, '%s.Background intensity=%g\n', prefix, grating.Background_intensity);
   fprintf(fp, '%s.Duration (ms)=%g\n', prefix, grating.Duration_ms);
   fprintf(fp, '%s.Phase (cycles)=%g\n', prefix, grating.Phase_cycles);
else
   fprintf(fp, '%s.Type=%OFF\n', prefix);
end

%--------------------------------------------------------------------------
function convert_input(fp, num, ie)

prefix = sprintf('Tosca.Input Events %d.Input Event', num-1);
fprintf(fp, '%s.Name=%s\n', prefix, ie.Name);

fprintf(fp, '%s.Criteria=<%d>\n', prefix, length(ie.Criteria));
for k = 1:length(ie.Criteria)
   convert_input_criterion(fp, prefix, k, ie.Criteria(k));
end

fprintf(fp, '%s.Operators=<%d>\n', prefix, length(ie.Operators));
for k = 1:length(ie.Operators)
   fprintf(fp, '%s.Operators %d=%s\n', prefix, k-1, ie.Operators{k});
end

if isfield(ie, 'Accumulator')
   fprintf(fp, '%s.Accumulator.active=%s\n', prefix, logical_to_string(ie.Accumulator.active));
   fprintf(fp, '%s.Accumulator.N=%d\n', prefix, ie.Accumulator.N);
   fprintf(fp, '%s.Accumulator.T=%g\n', prefix, ie.Accumulator.T);
   fprintf(fp, '%s.Accumulator.Imax=%g\n', prefix, ie.Accumulator.Imax);
   if isfield(ie.Accumulator, 'latency')
      fprintf(fp, '%s.Accumulator.latency=%g\n', prefix, ie.Accumulator.latency);
   end
else
   fprintf(fp, '%s.Accumulator.active=FALSE\n', prefix);
end

%--------------------------------------------------------------------------
function convert_input_criterion(fp, prefix, num, c)

prefix = sprintf('%s.Criteria %d.Criteria', prefix, num-1);
fprintf(fp, '%s.DigInput=%d\n', prefix, c.DigInput);
fprintf(fp, '%s.State=%s\n', prefix, c.State);
fprintf(fp, '%s.Time (ms)=%g\n', prefix, c.Time_ms);
fprintf(fp, '%s.Name=%s\n', prefix, c.Name);

%--------------------------------------------------------------------------
function convert_adapt(fp, adapt)

prefix = sprintf('Tosca.Adapt');
fprintf(fp, '%s.Switch after=%d\n', prefix, adapt.Switch_after);
fprintf(fp, '%s.Switch type=%s\n', prefix, adapt.Switch_type);
fprintf(fp, '%s.Tracks=<%d>\n', prefix, length(adapt.Tracks));
for k = 1:length(adapt.Tracks)
   convert_track(fp, prefix, k, adapt.Tracks(k));
end

%--------------------------------------------------------------------------
function convert_track(fp, prefix, num, track)

prefix = sprintf('%s.Tracks %d.Track', prefix, num-1);
fprintf(fp, '%s.chan=%s\n', prefix, track.chan);
fprintf(fp, '%s.param=%s\n', prefix, track.param);
fprintf(fp, '%s.state=%s\n', prefix, track.state);
fprintf(fp, '%s.Start=%g\n', prefix, track.Start);
fprintf(fp, '%s.Step=%g\n', prefix, track.Step);
fprintf(fp, '%s.Mode=%s\n', prefix, track.Mode);
fprintf(fp, '%s.Pcatch=%g\n', prefix, track.Pcatch);
fprintf(fp, '%s.Ndown=%d\n', prefix, track.Ndown);
fprintf(fp, '%s.Nup=%d\n', prefix, track.Nup);
fprintf(fp, '%s.Nreverse=%d\n', prefix, track.Nreverse);
fprintf(fp, '%s.Min=%g\n', prefix, track.Min);
fprintf(fp, '%s.Max=%g\n', prefix, track.Max);

fprintf(fp, '%s.Catch=<%d>\n', prefix, length(track.Catch));
for k = 1:length(track.Catch)
   convert_adapt_var(fp, prefix, 'Catch', k, track.Catch(k).var);
end

fprintf(fp, '%s.do all catch=%g\n', prefix, logical_to_string(track.do_all_catch));
fprintf(fp, '%s.name=%s\n', prefix, track.name);

fprintf(fp, '%s.Vars=<%d>\n', prefix, length(track.Vars));
for k = 1:length(track.Vars)
   convert_adapt_var(fp, prefix, 'Vars', k, track.Vars(k).var);
end

fprintf(fp, '%s.compute=%s\n', prefix, track.compute);
fprintf(fp, '%s.of last=%d\n', prefix, track.of_last);
fprintf(fp, '%s.Step2=%s\n', prefix, expression_to_string(track.Step2));
fprintf(fp, '%s.after=%d\n', prefix, track.after);

%--------------------------------------------------------------------------
function convert_adapt_var(fp, prefix, name, num, v)

prefix = sprintf('%s.%s %d.var', prefix, name, num-1);
fprintf(fp, '%s.state=%s\n', prefix, v.state);
fprintf(fp, '%s.chan=%s\n', prefix, v.chan);
fprintf(fp, '%s.param=%s\n', prefix, v.param);
fprintf(fp, '%s.expr=%s\n', prefix, expression_to_string(v.expr));


%--------------------------------------------------------------------------
function convert_schedule(fp, sched)

prefix = sprintf('Tosca.Schedule');
fprintf(fp, '%s.Blocks=%d\n', prefix, sched.Blocks);
fprintf(fp, '%s.order=%s\n', prefix, sched.order);
fprintf(fp, '%s.balance=%s\n', prefix, logical_to_string(sched.balance));
fprintf(fp, '%s.Families=<%d>\n', prefix, length(sched.Families));

for k = 1:length(sched.Families)
   if isfield(sched.Families(k), 'Family')
      convert_family(fp, prefix, k, sched.Families(k).Family);
   else
      convert_family(fp, prefix, k, sched.Families(k));
   end
end

if isfield(sched, 'herald') && sched.herald, warning('Herald functionality is deprecated.'); end

%--------------------------------------------------------------------------
function convert_family(fp, prefix, num, fam)

prefix = sprintf('%s.Families %d.Family', prefix, num-1);
if isnumeric(fam.Name)
   fprintf(fp, '%s.Name=%g\n', prefix, fam.Name);
else
   fprintf(fp, '%s.Name=%s\n', prefix, fam.Name);
end
fprintf(fp, '%s.Number=%d\n', prefix, fam.Number);
fprintf(fp, '%s.Vars=<%d>\n', prefix, length(fam.Vars));
for k = 1:length(fam.Vars)
   convert_var(fp, prefix, k, fam.Vars(k));
end

fprintf(fp, '%s.Mask=<%d %d>\n', prefix, size(fam.Mask, 1), size(fam.Mask, 2));
for kr = 1:size(fam.Mask, 1)
   for kc = 1:size(fam.Mask, 2)
      fprintf(fp, '%s.Mask %d %d=%s\n', prefix, kr-1, kc-1, logical_to_string(fam.Mask(kr,kc)));
   end
end

fprintf(fp, '%s.one each=%s\n', prefix, logical_to_string(fam.one_each));

%--------------------------------------------------------------------------
function convert_var(fp, prefix, num, v)

if isstruct(v) && isfield(v, 'Element')
   v = v.Element;
end

prefix = sprintf('%s.Vars %d.Element', prefix, num-1);
fprintf(fp, '%s.state=%s\n', prefix, v.state);
fprintf(fp, '%s.chan=%s\n', prefix, v.chan);
fprintf(fp, '%s.param=%s\n', prefix, v.param);
fprintf(fp, '%s.expr=%s\n', prefix, expression_to_string(v.expr));
fprintf(fp, '%s.dim=%s\n', prefix, v.dim);
fprintf(fp, '%s.value=%s\n', prefix, expression_to_vector_string(v.expr));


%% FSM
%--------------------------------------------------------------------------
function convert_node(fp, num, node, sigman, stateNames, targetState)

prefix = sprintf('FSM.Graph.Nodes %d.Node', num-1);
fprintf(fp, '%s.Version=0\n', prefix);
fprintf(fp, '%s.Name=%s\n', prefix, stateNames{num});

color = 13948116;
shape = 'Default';

if num == 1
   shape = 'End';
elseif num == 2
   shape = 'Start';
elseif isequal(stateNames{num}, targetState)
   color = 6599167;
end

badges = {};
for k = 1:length(sigman.StimChans)
   if ~strcmpi(sigman.StimChans(k).Waveform.Type, 'off')
      badges{end+1} = 'Audio';
      break;
   end
end
if isfield(sigman, 'Grating') && ~strcmpi(sigman.Grating.Type, 'off')
   badges{end+1} = 'Visual';
end

fprintf(fp, '%s.BannerColor=%d\n', prefix, color);
fprintf(fp, '%s.Width=60\n', prefix);
fprintf(fp, '%s.Height=40\n', prefix);
fprintf(fp, '%s.FontSize=8\n', prefix);
fprintf(fp, '%s.Center.X=%d\n', prefix, round(0.5*(node.rect.left + node.rect.right)));
fprintf(fp, '%s.Center.Y=%d\n', prefix, round(0.5*(node.rect.top + node.rect.bottom)));

fprintf(fp, '%s.Shape=%s\n', prefix, shape);
fprintf(fp, '%s.Badges=<%d>\n', prefix, length(badges));
for k = 1:length(badges)
   fprintf(fp, '%s.Badges %d=%s\n', prefix, k-1, badges{k});
end

%--------------------------------------------------------------------------
function edges = create_outgoing(src, flowchart, stateNames)

ytop = round(0.5*(flowchart(src).rect.top + flowchart(src).rect.bottom)) - 20;
xleft = round(0.5*(flowchart(src).rect.left + flowchart(src).rect.right)) + 30;

dy = 10;

edges = struct('y', [], 'src', {}, 'trg', {}, 'pts', [], ...
   'type', {}, 'style', {}, 'fill', [], ...
   'label', {}, 'label_x', [], 'label_y', [], ...
   'annot', {});
for k = 1:length(flowchart(src).Timeouts)
   to = flowchart(src).Timeouts(k);
   if to.Next >= 0
      edges(end+1).y = round(0.5*(to.rect.top + to.rect.bottom));
      edges(end).src = stateNames{src};
      edges(end).trg = stateNames{to.Next + 1};
      edges(end).type = to.Type;
      edges(end).style = 'Circle';
      edges(end).fill = 16777215;
      edges(end).label = 'Timeout';
      edges(end).label_y = to.rect.top;
      edges(end).annot = create_annot(to.TTL);
   end
end
for k = 1:length(flowchart(src).Term_Cond)
   term = flowchart(src).Term_Cond(k).Cluster;
   if term.Next >= 0
      edges(end+1).y = round(0.5*(term.rect.top + term.rect.bottom));
      edges(end).src = stateNames{src};
      edges(end).trg = stateNames{term.Next + 1};
      edges(end).type = term.Type;
      edges(end).style = 'Diamond';
      edges(end).fill = 16777124;
      edges(end).label = term.Name;
      edges(end).label_y = term.rect.top;
      edges(end).annot = create_annot(term.TTL);
   end
end

if isempty(edges)
   return;
end

ix = xleft * ones(1, 5);
if isempty(flowchart(src).Links.backward)
   ix(2:4) = ix(2:4) + 10;
end

switch length(edges)
   case 1
      idx = 2;
   case 2
      idx = [1 3];
   case 3
      idx = [0 2 4];
   case 4
      idx = [0 1 3 4];
   case 5
      idx = 0:4;
   otherwise
      error('too many outgoing')
end
ix = ix(idx + 1);

[~, isrt] = sort([edges.y]);
edges = edges(isrt);
for k = 1:length(edges)
   edges(k).pts = [ix(k) ytop + dy * idx(k)];
end

%--------------------------------------------------------------------------
function annot = create_annot(TTL)

annot = struct('name', {}, 'style', {});
for kt = 1:length(TTL)
   annot(end+1).name = TTL(kt).Name;
   if ~strcmp(TTL(kt).Start.When, 'Never')
      annot(end).style = 'On';
   end
   if ~strcmp(TTL(kt).Stop.When, 'Never')
      if ~isempty(annot(end).style)
         annot(end).style = [annot(end).style '-Off'];
      else
         annot(end).style = [annot(end).style 'Off'];
      end
   end
end

%--------------------------------------------------------------------------
function edges = create_incoming(edges, trg, flowchart, stateNames)

idx = find(strcmp({edges.trg}, stateNames{trg}));

if isempty(idx)
   return;
end

ytop = round(0.5*(flowchart(trg).rect.top + flowchart(trg).rect.bottom)) - 20;
xright = round(0.5*(flowchart(trg).rect.left + flowchart(trg).rect.right)) - 30;

ix = xright * ones(1, 7);
ix([1 7]) = ix([1 7]) + 12;
if isequal(flowchart(trg).Links.forward, -1)
   ix(3:5) = ix(3:5) - 10;
end
dy = 10 * [0 0 1 2 3 4 4];

switch length(idx)
   case 1
      iy = 3;
   case 2
      iy = [2 4];
   case 3
      iy = [1 3 5];
   case 4
      iy = [1 2 4 5];
   case 5
      iy = 1:5;
   case 6
      iy = 1:6;
   case 7
      iy = 0:6;
   otherwise
      error('too many incoming')
end
ix = ix(iy + 1);
dy = dy(iy + 1);

[~, isrt] = sort([edges(idx).y]);
for k = 1:length(isrt)
   iii = idx(isrt(k));
   w = xright - edges(iii).pts(1,1);
   
   edges(iii).pts = [edges(iii).pts; ...
      xright - round(0.75*w) edges(iii).y; ...
      xright - round(0.25*w) edges(iii).y;...
      ix(k) ytop + dy(k)];
   edges(iii).label_x = xright - round(0.5*w);
end

%--------------------------------------------------------------------------
function convert_edge(fp, num, edge)

typeStr = edge.type;
color = 0;
switch edge.type
   case 'Normal'
      typeStr = 'Any';
   case 'CS+'
      color = 38144;
   case 'CS-'
      color = 12582912;
end

prefix = sprintf('FSM.Graph.Edges %d.Edge', num-1);
fprintf(fp, '%s.Version=0\n', prefix);

fprintf(fp, '%s.Label.Version=0\n', prefix);
fprintf(fp, '%s.Label.Text=%s\n', prefix, edge.label);
fprintf(fp, '%s.Label.Location.x=%d\n', prefix, edge.label_x);
fprintf(fp, '%s.Label.Location.y=%d\n', prefix, edge.label_y);
fprintf(fp, '%s.Label.Color=%d\n', prefix, color);
fprintf(fp, '%s.SourceName=%s\n', prefix, edge.src);
fprintf(fp, '%s.TargetName=%s\n', prefix, edge.trg);

fprintf(fp, '%s.Points=<%d>\n', prefix, size(edge.pts, 1));
for kp = 1:size(edge.pts, 1)
   fprintf(fp, '%s.Points %d.point.x=%d\n', prefix, kp-1, edge.pts(kp, 1));
   fprintf(fp, '%s.Points %d.point.y=%d\n', prefix, kp-1, edge.pts(kp, 2));
end

fprintf(fp, '%s.Color=%d\n', prefix, color);
fprintf(fp, '%s.Style=Solid\n', prefix);
fprintf(fp, '%s.SourceEnd.Version=0\n', prefix);
fprintf(fp, '%s.SourceEnd.EndStyle=%s\n', prefix, edge.style);
fprintf(fp, '%s.SourceEnd.FillColor=%d\n', prefix, edge.fill);
fprintf(fp, '%s.SourceEnd.LineColor=%d\n', prefix, color);
fprintf(fp, '%s.TargetEnd.Version=0\n', prefix);
fprintf(fp, '%s.TargetEnd.EndStyle=Arrow\n', prefix);
fprintf(fp, '%s.TargetEnd.FillColor=%d\n', prefix, 0);
fprintf(fp, '%s.TargetEnd.LineColor=%d\n', prefix, color);
fprintf(fp, '%s.Type=%s\n', prefix, typeStr);

fprintf(fp, '%s.Annotations.Version=0\n', prefix);
fprintf(fp, '%s.Annotations.Items=<%d>\n', prefix, length(edge.annot));
for k = 1:length(edge.annot)
   fprintf(fp, '%s.Annotations.Items %d.Annotation.Name=%s\n', prefix, k-1, edge.annot(k).name);
   fprintf(fp, '%s.Annotations.Items %d.Annotation.Style=%s\n', prefix, k-1, edge.annot(k).style);
end
fprintf(fp, '%s.Annotations.Show=TRUE\n', prefix);

%--------------------------------------------------------------------------
function e = expression_to_string(e)
if isnumeric(e)
   e = num2str(e);
end
%--------------------------------------------------------------------------
function s = expression_to_vector_string(e)
if isnumeric(e)
   s = sprintf('<%d>%g', 1, e);
else
   try
      v = eval(e);
   catch
      v = eval(['[' e ']']);
   end
   s = [sprintf('<%d>', length(v)) sprintf('%g,', v)];
   s = s(1:end-1);
end
%--------------------------------------------------------------------------
function s = logical_to_string(value)
s = 'FALSE';
if value > 0
   s = 'TRUE';
end
