%%
figure
plot(dig1_z,'b')
hold on
plot(dig2_z,'k')
plot(dig4_z,'g')
plot(pd_z,'r')
line(get(gca,'xlim'),[slot_z_wrt_pellet,slot_z_wrt_pellet])