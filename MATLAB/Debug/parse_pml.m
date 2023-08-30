function T = parse_pml(fn)

fp = fopen(fn, 'rt');
fgetl(fp);

C = textscan(fp, '%s', 'Delimiter', ',');

C = reshape(C{1}, 7, [])';

fclose(fp);


T = NaN(size(C,1), 1);
for k = 1:size(C,1),
   v = datevec(strrep(C{k, 1}, '"', ''));
   T(k) = v(4)*3600 + v(5)*60 + v(6);
end
