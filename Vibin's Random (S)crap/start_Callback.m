 function start_Callback(hObject, eventdata, handles)
 % disable the start button
 set(hObject,'Enable','off');
 % enable the halt button
 set(handles.halt,'Enable','on');
 % flag that the loop is running
 handles.doLoop = true;
 guidata(hObject,handles);
 % start loop
 fprintf('starting while loop\n');
 while true
   % do stuff 
   pause(0.001);
   % should we continue?
   handles = guidata(hObject);
   if ~handles.doLoop
       break;
   end
 end
 fprintf('exiting while loop\n');
 % enable the start button
 set(hObject,'Enable','on');
 % disable the halt button
 set(handles.halt,'Enable','off');