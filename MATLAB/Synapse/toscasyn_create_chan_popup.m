function h = toscasyn_create_chan_popup(fig, numChan, callback)
% Create a popup in the toolbar for selecting spike channel for analysis.
%
hToolbar = findall(fig, 'tag', 'FigureToolBar');

jToolbar = get(get(hToolbar,'JavaContainer'),'ComponentPeer');
% if ~isempty(jToolbar)
   h = javax.swing.JComboBox({'1'});
   h.setMaximumSize(java.awt.Dimension(75, 25));
   
   set(handle(h, 'CallbackProperties'), 'ActionPerformedCallback', callback);

   jToolbar(1).addSeparator();
   jToolbar(1).add(h);
   jToolbar(1).repaint;
   jToolbar(1).revalidate;

   h.removeAllItems();
   for k = 1:numChan
      h.addItem(num2str(k));
   end
% end
