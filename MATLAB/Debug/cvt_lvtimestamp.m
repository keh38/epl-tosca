function [H, M, S] = cvt_lvtimestamp(ts)
% CVT_LVTIMESTAMP -- parse LabVIEW timestamp.
% Usage: [H, M, S] = cvt_lvtimestamp(val)
% 
% LV timestamp is number of seconds elapsed since 
% 12:00 a.m., Friday, January 1, 1904 (universal time)
%

val = ts;

d = floor(val / (24*3600));
val = val - d*24*3600; % strip off days leaving time today

hr = floor(val / 3600);

mn = floor((val - hr*3600) / 60);


sec = val - hr*3600 - mn*60;

hr = hr - 4; % UTC -> EDT

if nargout == 0,
   fprintf('%.6f = %02d:%02d:%02.3f\n', ts, hr, mn, sec);
elseif nargout == 1,
   H = hr*3600 + mn*60 + sec;
else
   H = hr;
   M = mn;
   S = sec;
end
