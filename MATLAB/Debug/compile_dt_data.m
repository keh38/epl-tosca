function [dt, t] = compile_dt_data(fnRun)

[d,p] = tosca_read_run(fnRun);

dt = [];
t = [];
for k = 1:length(d),
   s = tosca_read_trial(p, d, k);
   if ~isempty(s),
      ts = s.Time_s;
      for kt = 1:length(ts),
         ts(kt) = cvt_lvtimestamp(ts(kt));
      end
      dt = [dt; diff(s.Time_s(:))];
      t = [t; ts(1:end-1)'];
   end
end

dt = dt * 1000;

