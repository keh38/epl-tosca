% function analyze_di_dt(fn)

[dt, t] = compile_dt_data(fn);

% fnPML = strrep(fn, '.txt', '.CSV');
% tpm = parse_pml(fnPML);

figure;
figsize([10 3]);
plot(t-t(1), dt, 'b.');
xlabel('Time (s)');
ylabel('DI \DeltaT (ms)');

idx = find(dt > 20);
y = rem(t(idx), 2);

figure;
hist(y, 0:0.02:2);
xaxis(0, 2);
xlabel('Time(\DeltaT > 20ms)');
ylabel('Number');
