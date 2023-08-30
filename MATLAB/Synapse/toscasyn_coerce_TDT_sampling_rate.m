function Fs_coerced = toscasyn_coerce_TDT_sampling_rate(Fs)

if Fs > 1e5
   dt = 1.28;
else
   dt = 10.24;
end

Fs_coerced = 1e6 / (round(1e6/Fs/dt) * dt);
