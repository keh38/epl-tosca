import org.micromanager.internal.MMStudio;
import org.micromanager.acquisition.internal.DefaultAcquisitionManager;
import org.micromanager.data.Datastore;

public class MyJavaThread extends Thread
{
	public Datastore Data;
	MMStudio _gui;
	String _name;
	String _root;
    public MyJavaThread(MMStudio gui)
    {
		_gui = gui;
    }
	public void setPath(String name, String root)
	{
		_name = name;
		_root = root;
	}
	
    @Override
    public void run()
    {
        try
        {
			Thread.sleep(100);
			Data = _gui.acquisitions().runAcquisition(_name, _root);
        } catch (Exception ex) {
            System.out.println(ex.toString());
        }
    }
}