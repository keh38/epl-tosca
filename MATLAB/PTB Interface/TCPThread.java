import java.io.*;
import java.net.*;
import java.util.*;
import java.sql.Timestamp;

public class TCPThread extends Thread
{
	String _ipAddress;
	int _port;
	List<String> _messages;
	Boolean _isError;
	
    public TCPThread(String ipAddress, int port)
    {
		_ipAddress = ipAddress;
		_port = port;
    }
	public String getMessage()
	{
		String msg = "";
		if (_messages.size() > 0)
		{
			msg = _messages.remove(0);
		}
		return msg;
	}
	
	public void setError()
	{
		_isError = true;
	}
	
    @Override
    public void run()
    {
		int msgLen;
		boolean running = false;
		String message;
		_messages = new ArrayList<String>();
		
		_isError = false;
		
        try
        {
			Thread.sleep(100);
			ServerSocket serverSocket = new ServerSocket(_port);

			running = true;
			System.out.println("TCP server started");
			
			while (running)
			{
				Socket connectionSocket = serverSocket.accept();
				DataInputStream inFromClient = new DataInputStream(connectionSocket.getInputStream());
				DataOutputStream outToClient = new DataOutputStream(connectionSocket.getOutputStream());
				
				msgLen = inFromClient.readInt();

				byte[] msgBytes = new byte[msgLen];
				inFromClient.readFully(msgBytes);	

				message = new String(msgBytes);

				if (message.equals("Ping"))
				{
				}
				else if (message.contains("Close"))
				{
				}
				else if (message.contains("StartLog"))
				{
					_messages.add(message + ":" + System.currentTimeMillis());
				}
				else if (message.contains("Quit"))
				{
					_messages.add(message);
					running = false;
				}
				else if (message.equals("Status"))
				{
					outToClient.writeShort(_isError ? 0 : 1);
				}
				else
				{
					_messages.add(message);
				}

				//Timestamp timestamp = new Timestamp(System.currentTimeMillis());
				//System.out.println(timestamp);
				//System.out.println("Message: " + message);

				outToClient.writeInt(1);

				outToClient.close();
				connectionSocket.close();
			}
			
			System.out.println("Quitting TCP server");
			serverSocket.close();
			
        } catch (Exception ex) {
            System.out.println(ex.toString());
			//serverSocket.close();
			_messages.add("Quit");
        }
    }
}