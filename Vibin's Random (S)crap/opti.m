function opti();
fig = figure;
ax = axes;
axis([0 100 -5 5]);
b = uicontrol('Style', 'togglebutton', 'String', 'RUN',...
        'Position', [20 20 50 20],...
        'Callback', {@buttonpress,ax});
end
function buttonpress(hObject,event,ax)
    switch get(hObject,'Value')
        case 0
            set(hObject,'String','HALT')
        case 1
            set(hObject,'String','RUN')
            cla(ax);
    end
    axes(ax)
    hold on;
    t=0;
    while get(hObject,'Value') || t>30;    
        t=t+1;
        y=sin(2*pi*t/10);
        plot(t,y,'.');
        pause(.1);
    end
end