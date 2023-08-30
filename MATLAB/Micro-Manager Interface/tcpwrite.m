function [byteswritten, errorcode] = tcpwrite(socket, data, timeout)
% TCPWRITE -- writes data to byte stream on TCP socket.
% Usage: [byteswritten] = tcpconnect(socket, data, timeout)
% 
% Inputs: 
%    socket: Java TCP socket (previously created using TCPCONNECT)
%    data: data to be written to byte stream
%    timeout: milliseconds (default: 5000)
% 
% Outputs: 
%    byteswritten: number of byteswritten 
%
% Rewritten to use Java TCP functions, replacing LabVIEW-compiled mex functions 2/25/10. 
%
% $Id: tcpwrite.m 93 2012-06-26 18:42:56Z kehancock $
%

if nargin<3, timeout = 1000; end

try
	socket.setSoTimeout(timeout);
	out = java.io.DataOutputStream(socket.getOutputStream());

	switch class(data)
		case {'logical'}
			out.write(typecast(swapbytes(int32(data)), 'uint8')); % write data to stream
			out.flush();
         byteswritten = out.size();

      case {'int32'}
			out.write(typecast(swapbytes(data), 'uint8')); % write data to stream
			out.flush();
         byteswritten = out.size();
			
		case {'double'}
         data = typecast(swapbytes(data(:)'), 'uint8');
         nbytes = int32(length(data));
         out.write([typecast(swapbytes(nbytes), 'uint8') uint8(data)]);
			out.flush();
         byteswritten = out.size();
			
		case {'char'}
			nbytes = int32(length(data));
         out.write([typecast(swapbytes(nbytes), 'uint8') uint8(data)]);
         out.flush();
         byteswritten = out.size();
			
			if byteswritten ~= length(data) + 4,
				error(['Error writing ''' data ''' to TCP. ' char(10) ...
					'(' num2str(byteswritten) '/' num2str(length(data)) ' written)']);
			end
		otherwise
			error (['Unsupported data type:' class(data)]);
	end

catch exception
%    [p, f, e] = fileparts(ME.stack(1).file);
%    emsg = sprintf('Error writing data to PXI host.\n%s (%s): Line %d\n%s', ...
%       [f e], ME.stack(1).name, ME.stack(1).line, ME.message);
%    error(emsg);
   e1 = MException('Impale:TCP', 'Error writing to PXI chassis.');
   e2 = addCause(e1, exception);
   throw(e2);
end