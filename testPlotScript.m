%%

figure(1)
hold off
plot(dig2_z)
hold on
plot(pd_z)
line([200,1300],[slot_z_wrt_pellet,slot_z_wrt_pellet])
scatter(find(reachData.graspEnds),dig2_z(reachData.graspEnds),'b')
scatter(find(reachData.reachEnds),dig2_z(reachData.reachEnds),'r')
scatter(find(reachData.reachEnds),pd_z(reachData.reachEnds),'r')

scatter(find(reachData.graspStarts),dig2_z(reachData.graspStarts),'g')
scatter(find(reachData.graspStarts),pd_z(reachData.graspStarts),'g')
scatter(find(reachData.reachStarts),dig2_z(reachData.reachStarts),'o')

scatter(find(reachData.reach_to_grasp),dig2_z(reachData.reach_to_grasp),'p')