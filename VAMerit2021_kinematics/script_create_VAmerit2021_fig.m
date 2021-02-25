% script_create_VAmerit2021_fig

% select videos to pull images from

%%
early_vid = '/Volumes/Untitled/gradual_6OHDA_vids/R0382/R0382_post-saline/R0382_20201103b/R0382_20201103_14-42-22_060.avi';
late_vid = '/Volumes/Untitled/gradual_6OHDA_vids/R0382/R0382_post-6OHDA_06/R0382_20201216c/R0382_box02_20201216_17-44-21_031.avi';

vid_reader{1} = VideoReader(early_vid);
vid_reader{2} = VideoReader(late_vid);


crop_regions{1} = [900 550 300 300];
crop_regions{2} = [900 550 300 300];

figure

for i_vid = 1 : 2
    
    img{i_vid} = read(vid_reader{i_vid},300);
    
    subplot(1,2,i_vid)
    cropped_img = img{i_vid}(crop_regions{i_vid}(2):crop_regions{i_vid}(2)+crop_regions{i_vid}(4)-1,...
                             crop_regions{i_vid}(1):crop_regions{i_vid}(1)+crop_regions{i_vid}(3)-1);
                         
    
	imshow(cropped_img)
    
end