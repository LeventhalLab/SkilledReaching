%%


z_csv = fullfile('/Users/dan/Documents/GitHub/SkilledReaching/VA_Merit_spring_2020','avgdata.csv');

z_table = readtable(z_csv);

off_means = mean(table2array(z_table(1:5,:)));
on_means = mean(table2array(z_table(6:10,:)));

delta_z = on_means - off_means;

mean(delta_z)
std(delta_z)