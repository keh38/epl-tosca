% Rewrite Run .txt file
% movefile(P.Info.Filename, strrep(P.Info.Filename, '.txt', '.orig.txt'));

fpOld = fopen(strrep(P.Info.Filename, '.txt', '.orig.txt'), 'rt');
fpNew = fopen(P.Info.Filename, 'wt');

nd = 0;

while ~feof(fpOld),
   line = fgets(fpOld);
   
   if length(line)>6 && strcmp(line(1:6), 'Result'),
      fprintf(fpNew, 'Result=%s\n', Data{nd}.Result);
   else
      fprintf(fpNew, '%s', line);
   end
   
   if length(line)>7 && strcmp(line(1:7), 'Version'),
      fprintf(fpNew, 'AlignmentChecked=TRUE\n');
   end
   
   if length(line)>6 && strcmp(line(1:6), '[Block'),
      nd = nd + 1;
      fprintf(fpNew, 'N=%d\n', Data{nd}.N);
   end
   
end
fclose(fpOld);
fclose(fpNew);
