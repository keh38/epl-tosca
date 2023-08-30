fn = 'D:\Data\Tosca\Data\YM060522M2\Session 65\YM060522M1-Session65-Run2.txt';

matFile = strrep(fn, '.txt', '.di.mat');

% [Data, P] = tosca_read_run(fn, false);
% 
% 
% disp('Tosca: backing up DI data.');
% [folder, fn] = fileparts(P.Info.Filename);
% if isempty(folder)
%    folder = pwd;
% end
% backupFolder = fullfile(folder, 'backup');
% if ~exist(backupFolder, 'dir')
%    mkdir(backupFolder);
% end
% 
% flist = dir(fullfile(folder, [fn, '-*.di.txt']));
% trialNum = NaN(size(flist));
% for k = 1:length(flist)
%    %     movefile(fullfile(folder, flist(k).name), fullfile(backupFolder, flist(k).name));
%    
%    t = regexp(flist(k).name, '-Trial([\d]+).di.txt', 'tokens');
%    trialNum(k) = str2double(t{1}{1});
% end
% 
% [~, isort] = sort(trialNum);
% flist = flist(isort);
% 
% Trace = tosca_read_trace_data(strrep(P.Info.Filename, '.txt', '.trace.txt'));
% 
% P.Info.Filename = fullfile(backupFolder, fn);
% 
% DI = [];
% for k = 1:length(flist)
%    [di, headerRow] = read_trial(fullfile(folder, flist(k).name));
%    DI = [DI; di];
% end
% 
% save(matFile, 'DI', 'headerRow', 'Trace', 'Data');

load(matFile);

tdi = DI(:, 1);
trialMarker = DI(:, 3);
itrial = find(diff(trialMarker) > 0.5);
if trialMarker(1) == 1, itrial = [1; itrial]; end


% end

function [di, headerRow] = read_trial(fn)

s = fileread(fn);
isplit = regexp(s, '\n', 'once');

headerRow = s(1:isplit);
c = textscan(headerRow, '%s', 'delimiter', '\t');
names = c{1};

c = textscan(s(isplit+1:end), '%f', 'delimiter', '\t');
% c = textscan(fp, '%f', 'delimiter', '\t');
% fclose(fp);

nc = length(names);
nr = length(c{1})/nc;

if nr ~= round(nr)
   disp('removing double tabs');
   s = regexprep(s, '\t\t', '\t');
   c = textscan(s(isplit+1:end), '%f', 'delimiter', '\t');
end

nr = floor(length(c{1})/nc);
c{1} = c{1}(1:nr*nc);

di = reshape(c{1}, nc, nr);
di = di';
end
