folder = 'C:\Program Files\Micro-Manager-2.0beta\plugins\Micro-Manager';
jarList = dir(fullfile(folder, '*.jar'));

fp = fopen('mmjava.txt', 'wt');
for k = 1:length(jarList),
    fprintf(fp, '%s\n', fullfile(folder, jarList(k).name));
end
fclose(fp);