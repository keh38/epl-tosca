function ptb_interface(init_string)

if ~isdeployed
    addpath('Grating');
%     javaaddpath('./TCPThread_KeepOpen.jar');
    javaaddpath('./TCPThread.jar');
end

if nargin > 0
   fprintf('init_string = %s\n', init_string);
   [dist, screenID, diodeSize, diodeLocation, background] = parse_init_options(init_string);
   ptb = ptb_InitializeGratingDisplay(dist, screenID, diodeSize, diodeLocation, background);
end

grating.type = 'OFF';
log = ClearLog();

tcp_thread = TCPThread('localhost', 4926);
start(tcp_thread);

pause(1);

try
   while (true)
%       java.lang.Thread.sleep(2);
      pause(0.002);
      msg = char(tcp_thread.getMessage());
      
      if ~isempty(msg)

         if length(msg) > 4 && strcmpi(msg(1:4), 'init')
            [dist, screenID, diodeSize, diodeLocation, background] = parse_init_options(msg(6:end));
            ptb = ptb_InitializeGratingDisplay(dist, screenID, diodeSize, diodeLocation, background);
            
         elseif length(msg) > 6 && strcmpi(msg(1:6), 'buffer')
            grating = InitializeGrating(msg(8:end), ptb);
            
         elseif strcmpi(msg, 'draw')
            log = Display(grating, ptb, tcp_thread, log);
            grating.type = 'OFF';
            
         elseif length(msg) > 8 && strcmpi(msg(1:8), 'startlog')
            c = strsplit(msg, ':');
            
            tremote = str2double(c{2});
            treceived = datetime(datenum(str2double(c{3})/1000), 'ConvertFrom', 'posixtime', 'TimeZone', 'local');

            log = ClearLog(tremote, treceived);
            log.active = true;
            
         elseif length(msg) > 6 && strcmpi(msg(1:6), 'endlog')
            log = SaveLog(log, msg(8:end));
            
         elseif strcmpi(msg, 'release')
            Screen('CloseAll');
            
         elseif strcmp(msg, 'Quit')
            Screen('CloseAll');
            break;
         end
         disp(msg);
         
      end
   end
   
catch ex
   Screen('CloseAll');
   tcp_thread.setError();
   rethrow(ex);
end
%--------------------------------------------------------------------------
function log = Display(grating, ptb, tcp, log, tmsg)  

if nargin < 5, tmsg = NaN; end

try
   while true
      if strcmpi(grating.type, 'off')
         vbl = Screen('Flip', ptb.win);
         log = LogOffTime(log);
         return;
      end

      phase = grating.phase_cycles;
      
      numFrames = round(1e-3 * grating.duration_ms / ptb.ifi);
      if numFrames == 0, numFrames = Inf; end
      
      newGrating = false;
      
      frameNum = 0;

      log = LogDrawTime(log);
      
      while frameNum < numFrames
         % Draw the grating, centered on the screen, with given rotation 'angle'
         Screen('DrawTexture', ptb.win, ptb.gratingtex, [], [], 360-grating.orientation_degrees, ...
            [], [], [], [], ptb.rotateMode, ...
            [phase, grating.cyclesPerPixel, grating.contrast, grating.typeInt ...
            grating.background 0 0 0] ...
            );
         
         if ptb.useDiodeRect
            Screen('FillRect', ptb.win, 255*[1 1 1 0], ptb.diodeRect);
         end
         
         phase = phase + grating.phaseIncrement;
         
         % Show it at next retrace:
         if frameNum == 0
            vbl = Screen('Flip', ptb.win);
            log = LogOnTime(log);
         else
            vbl = Screen('Flip', ptb.win, vbl + 0.5 * ptb.ifi);
         end
         frameNum = frameNum + 1;
         
         msg = char(tcp.getMessage());
         
         if length(msg) > 6 && strcmpi(msg(1:6), 'buffer')
            grating = InitializeGrating(msg(8:end), ptb);
            newGrating = true;
         end
         
         if isequal(msg, 'Draw') || isequal(msg, 'Clear'), break; end
      end
      
      if ~newGrating, break; end
   end
   
   if numFrames > 1
     vbl = Screen('Flip', ptb.win, vbl + 0.5 * ptb.ifi);
     log = LogOffTime(log);
   end
   
catch ex
   Screen('CloseAll');
   tcp.setError();
   rethrow(ex);
end

%--------------------------------------------------------------------------
function [D, ID, SZ, LOC, BG] = parse_init_options(init_string)

A = sscanf(init_string, '%f:%d:%f:%d:%s%s');
D = A(1);
ID = A(2);
BG = A(3);
SZ = A(4);
LOC = lower(char(A(5:end)'));

%--------------------------------------------------------------------------
function G = InitializeGrating(init_string, ptb)

icolon = find(init_string == ':');
G.type = init_string(1:icolon-1);

A = sscanf(init_string(icolon+1:end), '%f,');

switch G.type
   case 'OFF'
      G.typeInt = 0;
   case 'Square'
      G.typeInt = 1;
   case 'Sine'
      G.typeInt = 2;
end

G.orientation_degrees = A(1);
G.spatialFrequency_cpd = A(2);
G.velocity_Hz = A(3);
G.contrast = A(4);
G.background = A(5);
G.duration_ms = A(6);
G.phase_cycles = A(7);

G.phaseIncrement = G.velocity_Hz * ptb.ifi;
G.cyclesPerPixel = G.spatialFrequency_cpd * ptb.degrees_per_pixel;

%--------------------------------------------------------------------------
function log = ClearLog(tremote, tlocal)

if nargin < 1, tremote = 0; end
if nargin < 2, tlocal = 0; end

log.active = false;
log.tlocal = tlocal;
log.tremote = tremote;
log.numOn = 0;
log.numOff = 0;
log.numDraw = 0;
log.Ton = NaN(1e5, 1);
log.Toff = log.Ton;
log.Tdraw = log.Ton;

%--------------------------------------------------------------------------
function log = LogDrawTime(log)

if ~log.active, return; end

log.numDraw = log.numDraw + 1;
% log.Tdraw(log.numDraw) = toc(log.tlocal) + log.tremote;
% dt = seconds(datetime('now') - log.tlocal);
% log.Tdraw(log.numDraw) = dt + log.tremote;
log.Tdraw(log.numDraw) = datenum(datetime('now'));

%--------------------------------------------------------------------------
function log = LogOnTime(log)

if ~log.active, return; end

log.numOn = log.numOn + 1;
% log.Ton(log.numOn) = toc(log.tlocal) + log.tremote;
% dt = seconds(datetime('now') - log.tlocal);
% log.Ton(log.numOn) = dt + log.tremote;
log.Ton(log.numOn) = datenum(datetime('now'));

%--------------------------------------------------------------------------
function log = LogOffTime(log)

if ~log.active, return; end

log.numOff = log.numOff + 1;
% log.Toff(log.numOff) = toc(log.tlocal) + log.tremote;
% dt = seconds(datetime('now') - log.tlocal);
% log.Toff(log.numOff) = dt + log.tremote;
log.Toff(log.numOff) = datenum(datetime('now'));

%--------------------------------------------------------------------------
function vbl = SaveLog(vbl, fn)

vbl.Ton = vbl.Ton(1:vbl.numOn);
vbl.Toff = vbl.Toff(1:vbl.numOff);
vbl.Tdraw = vbl.Tdraw(1:vbl.numDraw);

folder = fileparts(fn);
if ~exist(folder, 'dir')
   mkdir(folder);
end
save(fn, 'vbl');

vbl.active = false;

%--------------------------------------------------------------------------
% END OF PTB_INTERFACE.M
%--------------------------------------------------------------------------
