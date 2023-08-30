% function tcp_test

if ~isdeployed
    addpath('../Grating');
    javaaddpath('../TCPThread.jar');
end

tcp_thread = TCPThread('localhost', 4926);
start(tcp_thread);

a = datetime('now');

pause(1);

try
   while (true)
       drawnow;
%       pause(0.002);
      msg = char(tcp_thread.getMessage());
      
      if ~isempty(msg)
         disp(msg);
         
         if length(msg) > 4 && strcmpi(msg(1:4), 'ping')
            disp('ping');

         elseif length(msg) > 4 && strcmpi(msg(1:4), 'time')
            tremote = str2double(msg(10:end));
            tlocal = datetime('now');
            fprintf('\ntlocal: %f\n', second(tlocal));
            
         elseif ~isempty(strfind(msg, 'CreateLog'))
            tlocal = datetime('now');
            c = strsplit(msg, ':');
            
            tremote = str2double(c{2});
            treceived = datetime(datenum(str2double(c{3})/1000),'ConvertFrom','posixtime');
            fprintf('treceived: %f\n', second(treceived));
            fprintf('\ntlocal: %f\n', second(tlocal));
            
         elseif ~isempty(strfind(msg, 'Quit'))
            break;
         end
      end
   end
   
catch ex
   tcp_thread.setError();
   rethrow(ex);
end
