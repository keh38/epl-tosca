function tosca_prune_trace_log(fn)

[d, p] = tosca_read_run(fn, false);
s = tosca_read_trial(p, d, 1);
tr = tosca_read_trace_data(fn, true);

istart = find(tr.Event == 1 & tr.Time < s.Time_s(1), 1, 'last');

fn = strrep(fn, '.txt', '.trace.txt');

text = fileread(fn);

inl = find(double(text) == 10, 1);
prunedText = text(1:inl);

idx = strfind(text, sprintf('%.6f\t1', tr.Time(istart)));
prunedText = [prunedText text(idx:end)];

movefile(fn, strrep(fn, '.txt', '.orig.txt'));

fp = fopen(fn, 'wt');
fprintf(fp, '%s', prunedText);
fclose(fp);