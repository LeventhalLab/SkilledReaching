close all;
f = figure;
w = waitforbuttonpress;
% pause(5);
while w == 0 || w == 1;
    pause off;
if w == 0;
    disp('Button click')     
elseif w == 1;
    disp('Key press')
% else
%     break
end
clear w;
w = waitforbuttonpress;
% pause(2);
% if waitfor(w);
%     pause off;
% else
%     break
% end
% pause(w);
% if w == 0 || w == 1;
%     pause off;
% else
%     pause(5);
%     break    
% end
end
