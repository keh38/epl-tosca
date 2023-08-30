function ToscaMicroManagerInterface(varargin)
% TOSCAMICROMANAGERINTERFACE - TCP interface between remote instance of
% Tosca and local instance of Micro Manager.

ipAddress = '10.11.12.13';
port = 52247;
verbosity = 'full';

ParseArgin(varargin);

switch verbosity,
   case 'quiet',
      verbosity = 0;
   case 'connect',
      verbosity = 1;
   otherwise,
      verbosity = 100;
end

gui = OpenMicroManager();
RunTCPServer(ipAddress, port, gui, verbosity);

%--------------------------------------------------------------------------
function gui = OpenMicroManager()

origDir = pwd;

cd 'C:\Program Files\Micro-Manager-1.4\';
import org.micromanager.internal.MMStudio;
gui = MMStudio(false);
gui.openAcqControlDialog;

mmc = gui.getCore;
mmc.setProperty('Andor sCMOS Camera', 'TriggerMode', 'External');
% mmc.setProperty('Andor sCMOS Camera', 'TriggerMode', 'Internal (Recommended for fast acquisitions)');

cd(origDir);
javaaddpath('./MyJavaThread.jar');

%--------------------------------------------------------------------------
function RunTCPServer(ipAddress, port, gui, verbosity)

sockaddr = java.net.InetSocketAddress(ipAddress, port);
serverSocket = java.net.ServerSocket();
serverSocket.bind(sockaddr);

% mjt = MyJavaThread(gui);

try
   while true,
      
      if verbosity > 0,
         fprintf('Listening...');
      end
      socket = serverSocket.accept();
   
      cmd = read_string(socket);
      if verbosity > 0,
         fprintf('command ''%s'' received at %s\n', cmd, datestr(now, 'HH:MM:SS'));
      end
      
      if strcmpi(cmd, 'quit'), break; end
      
      try
          ProcessCommand(cmd, socket, gui, verbosity);
      catch
      end
      
   end
catch 
end

socket.close();
serverSocket.close();

%--------------------------------------------------------------------------
function ProcessCommand(cmd, socket, gui, verbosity)

global mjt

switch cmd,
   case 'Ping',
      tcpwrite(socket, int32(1));
   case 'Set frames',
      frames = read_int(socket);
      tcpwrite(socket, int32(1));
      
      if verbosity > 1,
         fprintf('   frames=%d\n', frames);
      end
      a = gui.acquisitions();
      s = a.getAcquisitionSettings;
      s.numFrames = frames;
      a.setAcquisitionSettings(s);
      
   case 'Start',
      name = read_string(socket);
      root = read_string(socket);
      tcpwrite(socket, int32(1));

      root = strrep(root, 'C:', 'D:');
      
      if verbosity > 1,
         fprintf('   name=%s, root=%s\n', name, root);
      end
      
      if ~exist(root, 'dir'),
          mkdir(root);
      end
      
      mjt = MyJavaThread(gui);
      mjt.setPath(name, root);
      start(mjt);

    case 'Stop',
      tcpwrite(socket, int32(1));
      e = gui.getAcquisitionEngine();
      e.stop(true);
      d = gui.displays();
      d.closeAllDisplayWindows(false);
      
      ds = mjt.Data;
      ds.close();
      
   otherwise,
      fprintf('*** Unrecognized command: %s\n', cmd);
end

%--------------------------------------------------------------------------
function S = read_string(socket)

try
   ch = java.nio.channels.Channels.newChannel(socket.getInputStream());
   
   buf = java.nio.ByteBuffer.allocate(4);
   nread = ch.read(buf);
   buf.flip();
   n = buf.getInt();

   buf = java.nio.ByteBuffer.allocate(n);
   nread = ch.read(buf);
   
   S = char(buf.array()');

catch
   disp('Error reading string');
   S = '';
end

%--------------------------------------------------------------------------
function val = read_int(socket)

try
   ch = java.nio.channels.Channels.newChannel(socket.getInputStream());
   
   buf = java.nio.ByteBuffer.allocate(4);
   nread = ch.read(buf);
   buf.flip();
   val = buf.getInt();

catch
   disp('Error reading string');
   val = -1;
end
%--------------------------------------------------------------------------
%  END OF TOSCAMICROMANAGERINTERFACE.M
%--------------------------------------------------------------------------
