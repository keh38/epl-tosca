function L = tosca_read_loco(fn)
% TOSCA_READ_LOCO -- reads Tosca locomotion data.
% Usage: L = tosca_read_loco(fn)
%
% *** Inputs ***
% fn : data file path
%
% *** Outputs ***
% L       
% L.t     : time, s
% L.ch    : channel (0=speed, 1=trial marker)
% L.speed : speed, cm/s
%

if ~contains(fn, '.loco')
   fn = strrep(fn, '.txt', '.loco.txt');
end

if ~exist(fn, 'file')
   error('Tosca locomotion file not found.');
end

warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
t = readtable(fn, 'Delimiter', 'tab');

names = t.Properties.VariableNames;

L.t = t.(names{1});
L.ch = t.(names{2});
L.speed = t.(names{3});

for k = 4:length(names)
   L.(names{k}) = t.(names{k});
end


