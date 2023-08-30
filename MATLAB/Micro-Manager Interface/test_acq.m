% mmc.setProperty('Andor sCMOS Camera', 'TriggerMode', 'External');
mmc.setProperty('Andor sCMOS Camera', 'TriggerMode', 'Internal (Recommended for fast acquisitions)');
% mmc.setProperty('Andor sCMOS Camera', 'Ext (Exp) Trigger Timeout[ms]', '10000');

a = gui.acquisitions();
s = a.getAcquisitionSettings;
s.cameraTimeout = 3000;
s.numFrames = 100;
s.intervalMs = 50;
s.root = 'D:\Data';
s.prefix = 'ken';

a.setAcquisitionSettings(s);
gui.openAcqControlDialog;

jt = MyJavaThread(gui, 'fuck', 'D:\Data');
start(jt);
% ds = a.runAcquisitionNonblocking();
% ds = a.runAcquisition('duuuude', 'D:\Data');
% ds.setSavePath('D:\Data\dude');
% return

pause(2);
while true,
    if ~a.isAcquisitionRunning,
        break;
    end
end

disp('wtf');

d = gui.displays();
d.closeAllDisplayWindows(false);
% ds.close();
