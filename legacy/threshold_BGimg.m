function [ greenBGmask ] = threshold_BGimg( BGimg_ud, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

imFiltSize = 5;

threshPctile_strict = 95;
% threshPctile_lib = 80;
gbThresh = 30;

for iarg = 1 : 2 : nargin - 1
    switch lower(varargin{iarg})
        case 'imfiltsize'
            imFiltSize = varargin{iarg + 1};
    end
end

filtBG = imboxfilt(BGimg_ud, imFiltSize);
relBG  = relativeRGB(filtBG);

rel_grdiff = relBG(:,:,2) - relBG(:,:,1);
rel_gbdiff = relBG(:,:,2) - relBG(:,:,3);
rel_gr_img = imadjust(rel_grdiff);
rel_gb_img = imadjust(rel_gbdiff);
rel_gr_values = rel_gr_img(:);
rel_gb_values = rel_gb_img(:);
l_gr = prctile(rel_gr_values(rel_gr_values>0), threshPctile_strict);
l_gb = prctile(rel_gb_values(rel_gb_values>0), gbThresh);
    
% l_gr2 = prctile(rel_gr_values(rel_gr_values>0), threshPctile_lib);

grMask_strict = rel_gr_img > l_gr;
% grMask_lib = rel_gr_img > l_gr2;

gbMask = imbinarize(rel_gb_img,l_gb);

tempMask = grMask_strict & gbMask;
greenBGmask = processMask(tempMask,2);

end

