%%
q1 = A(450:900,750:1350,:);
q2 = A(1:350,800:1300,:);

q1_gray = rgb2gray(q1);
q2_gray = rgb2gray(flipud(q2));

figure(2);hold off;imshow(q1_gray)
figure(3);hold off;imshow(q2_gray)
% pts1=detectBRISKFeatures(q1_gray);
% pts2=detectBRISKFeatures(q2_gray);

pts1=detectHarrisFeatures(q1_gray);
pts2=detectHarrisFeatures(q2_gray);

[features1,valid_points1] = extractFeatures(q1_gray,pts1);
[features2,valid_points2] = extractFeatures(q2_gray,pts2);

indexPairs = matchFeatures(features1,features2);

figure(4); % show the matched features.