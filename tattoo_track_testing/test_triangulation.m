%%
[points3d,reprojectedPoints,errors] = triangulate_DL(mp(:,:,2),mp(:,:,1),P1,P2);

figure
imshow(BGimg_ud);
hold on
plot(reprojectedPoints(:,1,1),reprojectedPoints(:,2,1),'marker','*','linestyle','none')
plot(reprojectedPoints(:,1,2),reprojectedPoints(:,2,2),'marker','*','linestyle','none')

%%
figure
plot3(points3d(:,1),points3d(:,2),points3d(:,3),'marker','*','linestyle','none')
xlabel('x');ylabel('y');zlabel('z')
hold on
%%
ii = 6;
plot3(points3d(ii,1),points3d(ii,2),points3d(ii,3),'marker','*','linestyle','none')
