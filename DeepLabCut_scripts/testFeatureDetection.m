%%
q1 = A(450:900,750:1350,:);
q2 = A(1:350,800:1300,:);

q1_gray = rgb2gray(q1);
q2_gray = rgb2gray(flipud(q2));

figure(2);hold off;imshow(q1_gray)
figure(3);hold off;imshow(q2_gray)
% pts1=detectBRISKFeatures(q1_gray);
% pts2=detectBRISKFeatures(q2_gray);

pts1=detectSURFFeatures(q1_gray);
pts2=detectSURFFeatures(q2_gray);

figure(2)
hold on
scatter(pts1.Location(:,1),pts1.Location(:,2))

figure(3)
hold on
scatter(pts2.Location(:,1),pts2.Location(:,2))

[features1,valid_points1] = extractFeatures(q1_gray,pts1);
[features2,valid_points2] = extractFeatures(q2_gray,pts2);

indexPairs = matchFeatures(features1,features2);

matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);

figure(4); % show the matched features.
showMatchedFeatures(q1_gray,q2_gray,matchedPoints1,matchedPoints2);