% cd 'C:\Program Files\Micro-Manager-1.4\';
cd 'C:\Program Files\Micro-Manager-2.0beta\';
import org.micromanager.internal.MMStudio;
gui = MMStudio(false);
% gui.show;
mmc = gui.getCore;

% Andor sCMOS Camera-TriggerMode