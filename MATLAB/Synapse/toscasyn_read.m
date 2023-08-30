function [codes, times, offset] = toscasyn_read(fn, offset)

if nargin < 2, offset = 0; end

synFile = strrep(fn, '.txt', '.syn');
s = dir(synFile);

codes = [];
times = [];

if isempty(s) || offset >= s.bytes
   return;
end

fp = fopen(synFile, 'rb', 'ieee-be');
fseek(fp, offset, 'bof');

% only advance offset, append data if both nread's are the same

while ~feof(fp)
   ncode = fread(fp, 1, 'int32');
   if isempty(ncode), break; end
   
   if offset + 4 + ncode*2 < s.bytes
      c = fread(fp, ncode, 'int16');
   end
      
   ntime = fread(fp, 1, 'int32');
   if isempty(ntime), break; end

   if ncode ~= ntime, break; end
   
   if offset + 4 + ntime*4 < s.bytes
      t = fread(fp, ntime, 'float32');
      times = [times; t];
      codes = [codes; c];
      offset = offset + 4 + ncode*2;
      offset = offset + 4 + ntime*4;
   end
end

fclose(fp);

% Convert from seconds to ms
times = times * 1000;

% Just keep channel part of TDT unit code
maxCodes = 6;
ipos = codes > 0;
codes(ipos) = floor((codes(ipos)-1) / maxCodes) + 1;
