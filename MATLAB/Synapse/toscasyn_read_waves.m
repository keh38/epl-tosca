function [waves, offset] = toscasyn_read_waves(fn, offset)

if nargin < 2, offset = 0; end

synFile = strrep(fn, '.txt', '.waves.syn');
s = dir(synFile);

waves = [];

if isempty(s) || offset >= s.bytes
   return;
end

fp = fopen(synFile, 'rb', 'ieee-be');
fseek(fp, offset, 'bof');

while ~feof(fp)
   if offset + 8 >= s.bytes
      break;
   end
   
   sz = fread(fp, [1 2], 'uint32');
      
   if offset + 8 + prod(sz)*8 > s.bytes
      break;
   end
   
   w = fread(fp, prod(sz), 'double');
   w = reshape(w, fliplr(sz));
   
   waves = [waves; w];
   offset = offset + 8 + prod(sz)*8;
end

fclose(fp);
