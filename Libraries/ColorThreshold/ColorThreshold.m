function ColorThreshold(im)
% ColorThreshold performs custom color thresholding on the image 'image_name'.
% Arguments: 'image_name', filename of the image to threshold
%
% The user can zoom in on a region, then add/remove pixels from the thresholding
% program.  When you are satisfied, print the filter and the program will
% display the RGB or HSV statistics.  You can also handtune filters using slider
% bars for RGB or HSV filters.  The Hue filter can optionally be split for
% Hues that wraparound zero. The ROIs can be moved around as needed.
% My bitmaps came from a print screen % of an Image Graph in Code ComposerStudio.
% send suggestions/problems to abecker5@uiuc.edu
%
% NOTE: non GE423 students, switch rgb2hsvGE423 to the standard rgb2hsv
% Matlab function.

% TODO: 1.) use standard HSV
%       2.)allow function to be called with filter points.
%       3.) as soon as I move the mouse, the first image wobbles
if(nargin > 0)
    Original_img = im;
end 
close all; format compact  %my preferences
scrsz = get(0,'ScreenSize');
h1.fig = figure(1);
set(h1.fig,'Name','Original Image', 'Position',[10 scrsz(4)*.05 scrsz(3)*1/3 scrsz(4)*.9]);
set(h1.fig,'MenuBar','none');   %hide menu bars
subplot(2,1,1)
image(Original_img)
axis image
title('select your{\it region of interest} (ROI) by clicking twice','FontWeight','bold')
% Select corner points of a rectangular
% region by pointing and clicking the mouse twice
BOX = [];
% Select location of the rectangles 1st pt.
    set(gcf, 'Pointer', 'fullcross')
    waitforbuttonpress;
    [h1.x0,h1.y0] = selectOnScreenPt();
% Select second point
    set(gcf, 'Pointer', 'fleur')
    set(gcf,'WindowButtonMotionFcn', @select_p0)
    waitforbuttonpress;
    set(gcf, 'Pointer', 'arrow')
    set(gcf,'WindowButtonMotionFcn', '')
    set(gcf,'WindowButtonDownFcn', @h1butdown)
title('Original Image')

% Index into the original image to create the new image
% by getting the x and y corner coordinates as integers
ROI = Original_img(floor(min(h1.y0,h1.y1)):ceil(max(h1.y0,h1.y1)), floor(min(h1.x0,h1.x1)):ceil(max(h1.x0,h1.x1)),:);
h2.numValidPX = 0;
% Display the subsetted image with appropriate axis ratio
% this image can be clicked on to add pixels to the thresholding list
h2.fig = figure(2);                  %start horz  start vert  width    height
set(h2.fig,'Name','ROI', 'Position',[scrsz(3)*2/5 -30+scrsz(4)*.5 scrsz(3)*3/5 scrsz(4)*.5]);
set(h2.fig,'MenuBar','none');
image(ROI); axis image
title({'{\it left click} to select pixels, deselect with{\it right click}';'{\it drag} to select multiple pixels'},'FontWeight','bold')

Original_imgHSV = []; IsHSplit = 0; IsRGB = 1;%initialize variables for thresholding
h3 = initfig3();
set(0,'CurrentFigure',h1.fig);  %now that the other 2 images are initialized, add thresholded image to fig1
th_imag_axis = subplot(2,1,2); select_thesh('', '');
figure(h2.fig);
set(h2.fig, 'Pointer', 'fullcross')
h2.ValidPX = zeros(numel(ROI)/3,2); h2.Patches = zeros(numel(ROI)/3,1); %variables to show selected pixels
set(h2.fig,'WindowButtonDownFcn', @h2buttondown);
set(h2.fig,'WindowButtonUpFcn', @h2buttonup);
set(h2.fig,'CloseRequestFcn', @threshCloseFig);
set(h3.fig,'CloseRequestFcn', @threshCloseFig);

%%% END OF PROGRAM
%%%%%%%%% Start of functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function str = strThreshedVals( IsRGB, rHmin, rHmax, gSmin, gSmax, bVmin, bVmax, IsHsplit)
        if IsRGB
            str = ['R [',num2str(rHmin),':',num2str(rHmax),'], G [',num2str(gSmin),':',num2str(gSmax),'], B [',num2str(bVmin),':',num2str(bVmax),']'];
        else
            if IsHsplit
                str = ['H [0:',num2str(rHmin),',',num2str(rHmax),':255]'];
            else
                str = ['H [',num2str(rHmin),':',num2str(rHmax),']'];
            end
            str = [str,', S [',num2str(gSmin),':',num2str(gSmax),'], V [',num2str(bVmin),':',num2str(bVmax),']'];
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [h3] = initfig3()
        IsRGB = 1;
        h3.boolHandTune = false;  
        h3.fig = figure(3);                          %start horz  start vert  width    height
        set(h3.fig,'Name','Range Values', 'Position',[scrsz(3)*2/5 40 scrsz(3)*3/5 scrsz(4)*.4]);
        set(h3.fig,'MenuBar','none');
        h3.rgbplot = subplot(1,3,1);
        axis([0  4  0  255]);
        xVals = [0.8,0.8,1.8,1.8,2.8,2.8];
        yVals = [100,200,100,200,100,200];
        for n=1:6
            h3.h(n)=plot(xVals(n),yVals(n),'sk','LineWidth',2,'markerEdgecolor','k','markersize',8,'Marker','none','MarkerFaceColor',[.8 .8 .8]);
            hold on
        end
        
        h3.R = plot(1*ones(size(0)),0,'.r', 'HitTest','off');
        h3.G = plot(2*ones(size(0)),0,'.g', 'HitTest','off');
        h3.B = plot(3*ones(size(0)),0,'.b', 'HitTest','off');
        set(h3.R, 'Xdata', [], 'Ydata', []);
        set(h3.G, 'Xdata', [], 'Ydata', []);
        set(h3.B, 'Xdata', [], 'Ydata', []);
               axis([0  4  0  255]);
        set(gca,'XTick',[1,2,3]);
        set(gca,'XTickLabel',{'R','G','B'});
        title({'RGB values selected';' '});
              
        h3.hsvplot = subplot(1,3,2);     
         set(h3.fig,'CurrentAxes',h3.hsvplot);
        for n=1:6
            h3.h(n+6)=plot(xVals(n),yVals(n),'sk','LineWidth',2,'markerEdgecolor','k','markersize',8,'Marker','none','MarkerFaceColor',[.8 .8 .8]);
            hold on
        end
        h3.H = plot(1*ones(size(0)),0,'.m', 'HitTest','off');
        h3.S = plot(2*ones(size(0)),0,'.c', 'HitTest','off');
        h3.V = plot(3*ones(size(0)),0,'.k', 'HitTest','off');
        set(h3.H,'Xdata', [], 'Ydata', []);
        set(h3.S,'Xdata', [], 'Ydata', []);
        set(h3.V,'Xdata', [], 'Ydata', []);

        axis([0  4  0  255]);
        set(gca,'XTick',[1,2,3]);
        set(gca,'XTickLabel',{'H','S','V'});
        title({'HSV values selected';'\itnote: there may be wraparounds'});

        h3.buttonArea = init_RGBbut; %setup the buttons and their callbacks
        set(gcf, 'WindowButtonDownFcn', {@select_thesh})
        title({'Thresholding';' Options'}); 
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [rHmin, rHmax, gSmin, gSmax, bVmin, bVmax] = RangeValues(IsRGB, h2, IsHSplit)
    
        R = zeros(h2.numValidPX,1);
        G = zeros(h2.numValidPX,1);
        B = zeros(h2.numValidPX,1);
        H = zeros(h2.numValidPX,1);
        S = zeros(h2.numValidPX,1);
        V = zeros(h2.numValidPX,1);

        for in = 1:h2.numValidPX
            R(in) = (ROI(h2.ValidPX(in,2),h2.ValidPX(in,1),1));
            G(in) = (ROI(h2.ValidPX(in,2),h2.ValidPX(in,1),2));
            B(in) = (ROI(h2.ValidPX(in,2),h2.ValidPX(in,1),3));
            [H(in) S(in) V(in)] = rgb2hsvGE423(R(in),G(in),B(in)); %Matlab rgb2hsv is different than on robots   
        end
        if h2.numValidPX > 0
            if(IsRGB)
                rHmax = max(R);
                rHmin = min(R);
                gSmax = max(G);
                gSmin = min(G);
                bVmax = max(B);
                bVmin = min(B);
            else
                rHmax = max(H);
                rHmin = min(H);
                gSmax = max(S);
                gSmin = min(S);
                bVmax = max(V);
                bVmin = min(V);
                if(IsHSplit)
                    H = sort(H); %arranges all hues from smallest to largest
                    bigSplit = 0; % we want the largest possible split
                 
                    for splitpt = 1:255
                        ind1 = find(H <splitpt,1, 'last' );
                        ind2 = find(H>=splitpt,1, 'first');
                        if(~isempty(ind1))
                            bot = H(ind1);
                        else
                            bot = 0;
                        end
                        if(~isempty(ind2))
                            top = H(ind2);
                        else
                            top = 255;
                        end
                        if top-bot-1 > bigSplit
                            bigSplit = top-bot-1;
                            rHmax = top;
                            rHmin = bot;
                        end
                    end % end for
                end %end if hsplit
            end   
        else %end if Valid PX
            rHmax = 0;
            rHmin = 255;
            gSmax = 0;
            gSmin = 255;
            bVmax = 0;
            bVmin = 255;
        end
        
        try %update the figure 3 if it exists
            set(h3.R,'Xdata', 1*ones(size(R)), 'Ydata', R);
            set(h3.G,'Xdata', 2*ones(size(G)), 'Ydata', G);
            set(h3.B,'Xdata', 3*ones(size(B)), 'Ydata', B);

            set(h3.H,'Xdata', 1*ones(size(H)), 'Ydata', H);
            set(h3.S,'Xdata', 2*ones(size(S)), 'Ydata', S);
            set(h3.V,'Xdata', 3*ones(size(V)), 'Ydata', V);

           if h3.boolHandTune
               if IsRGB
                   rHmin = min( get(h3.h(1),'ydata'),get(h3.h(2),'ydata'));
                   rHmax = max( get(h3.h(1),'ydata'),get(h3.h(2),'ydata'));
                   gSmin = min( get(h3.h(3),'ydata'),get(h3.h(4),'ydata'));
                   gSmax = max( get(h3.h(3),'ydata'),get(h3.h(4),'ydata'));
                   bVmin = min( get(h3.h(5),'ydata'),get(h3.h(6),'ydata'));
                   bVmax = max( get(h3.h(5),'ydata'),get(h3.h(6),'ydata'));
               else
                   rHmin = min( get(h3.h(7),'ydata'),get(h3.h(8),'ydata'));
                   rHmax = max( get(h3.h(7),'ydata'),get(h3.h(8),'ydata'));
                   gSmin = min( get(h3.h(9),'ydata'),get(h3.h(10),'ydata'));
                   gSmax = max( get(h3.h(9),'ydata'),get(h3.h(10),'ydata'));
                   bVmin = min( get(h3.h(11),'ydata'),get(h3.h(12),'ydata'));
                   bVmax = max( get(h3.h(11),'ydata'),get(h3.h(12),'ydata'));
               end
           end
        catch
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%thresh takes a color filter and applies it to the given image
    function thresh(Original_img, IsRGB, rHmin, rHmax, gSmin, gSmax, bVmin, bVmax, IsHSplit, figure_handle, axes_handle)
        if(IsRGB)
         Thresh_img = Original_img(:,:,1) >= rHmin & Original_img(:,:,1) <= rHmax ...
                    & Original_img(:,:,2) >= gSmin & Original_img(:,:,2) <= gSmax ...
                    & Original_img(:,:,3) >= bVmin & Original_img(:,:,3) <= bVmax;
                threshed = cast(repmat(Thresh_img,[1,1,3]),'uint8').*Original_img; % threshold the original image
        else
            if ~exist('Original_imgHSV','var') || isempty(Original_imgHSV)
                Original_imgHSV = Original_img;
                for in = 1:numel(Original_img(:,1,1))
                    for ij = 1:numel(Original_img(1,:,1))
                        R = Original_img(in,ij,1);
                        G = Original_img(in,ij,2);
                        B = Original_img(in,ij,3);
                        [H, S, V] = rgb2hsvGE423(R,G,B);
                        Original_imgHSV(in,ij,1) = H;
                        Original_imgHSV(in,ij,2) = S;
                        Original_imgHSV(in,ij,3) = V;
                    end
                end
            end
          
            if IsHSplit
                Thresh_img = (Original_imgHSV(:,:,1) <= rHmin | Original_imgHSV(:,:,1) >= rHmax) ...
                        & Original_imgHSV(:,:,2) >= gSmin & Original_imgHSV(:,:,2) <= gSmax ...
                        & Original_imgHSV(:,:,3) >= bVmin & Original_imgHSV(:,:,3) <= bVmax;
            else
                Thresh_img = Original_imgHSV(:,:,1) >= rHmin & Original_imgHSV(:,:,1) <= rHmax ...
                        & Original_imgHSV(:,:,2) >= gSmin & Original_imgHSV(:,:,2) <= gSmax ...
                        & Original_imgHSV(:,:,3) >= bVmin & Original_imgHSV(:,:,3) <= bVmax;
            end
            threshed = cast(repmat(Thresh_img,[1,1,3]),'uint8').*Original_imgHSV; % threshold the HSV image
        end %IsRGB
        
        currfig = get(0,'CurrentFigure'); %save the currently highlighted figure
        if( nargin >= 11)
            set(0,'CurrentFigure',figure_handle)  %adjust the figure without setting it as selected
            set(figure_handle,'CurrentAxes',axes_handle);
        end
        image(threshed)
        axis image
        threshedVals = strThreshedVals( IsRGB, rHmin, rHmax, gSmin, gSmax, bVmin, bVmax, IsHSplit);
        title({strcat('Threshed Image,    ',num2str(sum(sum(Thresh_img))), ' px detected');threshedVals});
        set(0,'CurrentFigure',currfig);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[H S V] = rgb2hsvGE423(R,G,B)

        red = (double(R)-16)*255/224;
        green = (double(G)-16)*255/224;
        blue = (min(double(B)*2,240)-16)*255/224;
        minV = min(red,min(green,blue));
        value = max(red,max(green,blue));
        delta = value - minV;
        if(value~=0)
            sat = (delta*255) / value;% s
            if (delta ~= 0) 
                if( red == value )
                    hue = 60*( green - blue ) / delta;		% between yellow & magenta
                elseif( green == value )
                    hue = 120 + 60*( blue - red ) / delta;	% between cyan & yellow
                else
                    hue = 240 + 60*( red - green ) / delta;	% between magenta & cyan
                end
                if( hue < 0 )
                    hue = hue + 360;
                end
            else 
                hue = 0;
                sat = 0;
            end
        else 
            % r = g = b = 0		// s = 0, v is undefined
            sat = 0;
            hue = 0;
        end
        H = max(min(floor(((hue*255)/360)),255),0);
        S = max(min(floor(sat),255),0);
        V = max(min(floor(value),255),0);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function buttonArea  = init_RGBbut(src, eventdata) %#ok<*INUSD>
        IsRGB = 1;
        IsHSplit = 0;
        buttonArea.plot = subplot(1,3,3);
        set(gca,'XTick',[]);    %turn off ticks
        set(gca,'YTick',[]);
        buttonArea.butBkgOnC = [.5 .5 .5];
        buttonArea.butBkgOffC = [.8 .8 .8];
        butX = [0,1,1,0,0];
        butY = [0,0,0.5,0.5,0];
        buttonArea.butFontOffC = [.7 .7 .7];
        buttonArea.butFontOnC = [0.0 0.0 0.0];
        buttonArea.RGBbut       = patch(butX,butY+0.5,buttonArea.butBkgOnC);
        buttonArea.RGBtext      = text(0.1,0.75,{'Using RGB'},'FontSize',14);
        
        buttonArea.HSVbut       = patch(butX,butY,buttonArea.butBkgOffC);
        buttonArea.HSVtext      = text(0.1,0.25,{'Use HSV'},'FontSize',14, 'Color',buttonArea.butFontOffC);  
        
        buttonArea.HSVSPLITbut  = patch(butX,butY-0.5,buttonArea.butBkgOffC);
        buttonArea.HSVSPLITtext = text(0.1,-0.25,{'Split H'},'FontSize',14, 'Color',buttonArea.butFontOffC); 
        
        buttonArea.HANDTUNEbut  = patch(butX,butY-1,buttonArea.butBkgOffC);
        buttonArea.HANDTUNEtext = text(0.1,-0.75,{'Hand Tune Limits'},'FontSize',10, 'Color',buttonArea.butFontOffC);
        
        buttonArea.PRINTbut  = patch(butX,butY-1.5,buttonArea.butBkgOffC);
        buttonArea.PRINTtext = text(0.1,-1.25,{'Print Filter'},'FontSize',14, 'Color',buttonArea.butFontOffC);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[] = select_thesh(src, eventdata) 
        if (h3.buttonArea.plot == gca)
            cp=get(gca,'CurrentPoint');
            y0 = cp(1,2);
            if(y0 >0.5)
                IsRGB = 1;
                set(h3.buttonArea.RGBbut,'FaceColor',h3.buttonArea.butBkgOnC );
                set(h3.buttonArea.HSVbut,'FaceColor',h3.buttonArea.butBkgOffC );
                set(h3.buttonArea.RGBtext,'String','Using RGB', 'Color',h3.buttonArea.butFontOnC);
                set(h3.buttonArea.HSVtext,'String','Use HSV', 'Color',h3.buttonArea.butFontOffC);
            elseif(y0 > 0)
                IsRGB = 0;
                set(h3.buttonArea.HSVbut,'FaceColor',h3.buttonArea.butBkgOnC );
                set(h3.buttonArea.RGBbut,'FaceColor',h3.buttonArea.butBkgOffC );
                set(h3.buttonArea.HSVtext,'String','Using HSV', 'Color',h3.buttonArea.butFontOnC);
                set(h3.buttonArea.RGBtext,'String','Use RGB', 'Color',h3.buttonArea.butFontOffC);
            elseif(y0 > -0.5)
                IsHSplit = ~IsHSplit;
                if(~IsHSplit)
                    set(h3.buttonArea.HSVSPLITbut,'FaceColor',h3.buttonArea.butBkgOffC);
                    set(h3.buttonArea.HSVSPLITtext,'Color',h3.buttonArea.butFontOffC);
                else
                    set(h3.buttonArea.HSVSPLITbut,'FaceColor',h3.buttonArea.butBkgOnC);
                    set(h3.buttonArea.HSVSPLITtext,'Color',h3.buttonArea.butFontOnC);
                end
            elseif(y0 > -1)
                if h3.boolHandTune
                    h3.boolHandTune = false;
                    set(h3.buttonArea.HANDTUNEbut,'FaceColor',h3.buttonArea.butBkgOffC);
                    set(h3.buttonArea.HANDTUNEtext,'Color',h3.buttonArea.butFontOffC);
                else
                    h3.boolHandTune = true;
                    set(h3.buttonArea.HANDTUNEbut,'FaceColor',h3.buttonArea.butBkgOnC);
                    set(h3.buttonArea.HANDTUNEtext,'Color',h3.buttonArea.butFontOnC);
                end
            elseif(y0 >-1.5) %print the filter coefficients
                set(h3.buttonArea.PRINTbut,'FaceColor',h3.buttonArea.butBkgOnC);
                set(h3.buttonArea.PRINTtext,'Color',h3.buttonArea.butFontOnC);

                [rHmin, rHmax, gSmin, gSmax, bVmin, bVmax] = RangeValues(IsRGB, h2, IsHSplit);
                threshedStr = strThreshedVals( IsRGB, rHmin, rHmax, gSmin, gSmax, bVmin, bVmax, IsHSplit); 
                display(['Selected Threshold: ', threshedStr]);
                pause(0.5)
                set(h3.buttonArea.PRINTbut,'FaceColor',h3.buttonArea.butBkgOffC);
                set(h3.buttonArea.PRINTtext,'Color',h3.buttonArea.butFontOffC);
            end %button click
            for icont=1:6
                if( IsRGB && h3.boolHandTune )
                    set(h3.h(icont),'Marker','>')
                else
                    set(h3.h(icont),'Marker','none')
                end
            end
            for icont=7:12
                if( ~IsRGB && h3.boolHandTune )
                    set(h3.h(icont),'Marker','>')
                else
                    set(h3.h(icont),'Marker','none')
                end
            end
        end

       for icont = 1:12
                if gco == h3.h(icont)
                    set(h3.h(icont),'MarkerFaceColor',h3.buttonArea.butBkgOnC );
                    set(h3.fig, 'WindowButtonMotionFcn', {@select_level, h3.h(icont)})
                    set(h3.fig,'WindowButtonDownFcn','')
                    set(h3.fig,'WindowButtonUpFcn', 'uiresume')
                    uiwait
                    set(h3.fig,'WindowButtonMotionFcn','')
                    set(h3.fig,'WindowButtonDownFcn',{@select_thesh})
                    set(h3.h(icont),'MarkerFaceColor',h3.buttonArea.butBkgOffC );
                end
       end        

        %update limits
        [rHmin, rHmax, gSmin, gSmax, bVmin, bVmax] = RangeValues(IsRGB, h2, IsHSplit);
        thresh(Original_img, IsRGB, rHmin, rHmax, gSmin, gSmax, bVmin, bVmax, IsHSplit, h1.fig, th_imag_axis)
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[x,y] = selectOnScreenPt()
        cp=get(gca,'CurrentPoint');
        x=max(1,min(cp(1,1), size(Original_img,2)));
        y=max(1,min(cp(1,2), size(Original_img,1)));
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[] = select_p0(src, eventdata) % Interactively select first point
            [h1.x1,h1.y1] = selectOnScreenPt();
            draw_fig(h1.x0, h1.y0, h1.x1,h1.y1)
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[] = h1butdown(src, eventdata) % Interactively select first point
        if gco == BOX(1)
            %BOX(2) = patch(x,y
            [h1.xs,h1.ys] = selectOnScreenPt();
            %display(num2str([xs,ys]))
            set(gcf,'WindowButtonMotionFcn', {@movebox})
            set(gcf,'WindowButtonUpFcn', {@h1butup})
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[] = h1butup(src, eventdata)%  Interactively select first point
        set(gcf,'WindowButtonMotionFcn', '');
        set(gcf,'WindowButtonUpFcn', '');
        [h1.xf,h1.yf] = selectOnScreenPt();
        dx =h1.xf-h1.xs;
        dy =h1.yf-h1.ys;
        x0n = min(h1.x0+dx, h1.x1+dx);
        y0n = min(h1.y0+dy, h1.y1+dy);
        x1n = max(h1.x0+dx, h1.x1+dx);
        y1n = max(h1.y0+dy, h1.y1+dy);
        if( x1n > size(Original_img,2) )
            x1n = size(Original_img,2); x0n = size(Original_img,2) - (h1.x1-h1.x0);
        end
        if( x0n < 1)
            x0n = 1; x1n = 1+(h1.x1-h1.x0);
        end
        if( y1n > size(Original_img,1) )
            y1n = size(Original_img,1); y0n = size(Original_img,1) - (h1.y1-h1.y0);
        end
        if( y0n < 1)
            y0n = 1; y1n = 1+(h1.y1-h1.y0);
        end
        h1.x0 = x0n; h1.x1 = x1n; h1.y0 = y0n; h1.y1 = y1n;
        draw_fig(h1.x0, h1.y0, h1.x1,h1.y1)
        ROI = Original_img(floor(min(h1.y0,h1.y1)):ceil(max(h1.y0,h1.y1)), floor(min(h1.x0,h1.x1)):ceil(max(h1.x0,h1.x1)),:);
        currfig = get(0,'CurrentFigure'); %save the currently highlighted figure
        set(0,'CurrentFigure',h2.fig)
        for c=1:h2.numValidPX
            delete(h2.Patches(c)) 
        end
        h2.numValidPX = 0;
        image(ROI)
        axis image
        title({'{\it left click} to select pixels, deselect with{\it right click}';'{\it drag} to select multiple pixels'},'FontWeight','bold')

        % learn about the hue wrapparound by making another plot
        [rHmin, rHmax, gSmin, gSmax, bVmin, bVmax] = RangeValues(IsRGB, h2, IsHSplit);
        % threshold original image using min and max values
        thresh(Original_img, IsRGB, rHmin, rHmax, gSmin, gSmax, bVmin, bVmax, IsHSplit, h1.fig, th_imag_axis); 
        set(0,'CurrentFigure',currfig )
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[] = movebox(src, eventdata)% % Ensure the box never leaves the region
            [xf,yf] = selectOnScreenPt();
            dx =xf-h1.xs;
            dy =yf-h1.ys;
            x0n = min(h1.x0+dx, h1.x1+dx);
            y0n = min(h1.y0+dy, h1.y1+dy);
            x1n = max(h1.x0+dx, h1.x1+dx);
            y1n = max(h1.y0+dy, h1.y1+dy);
            if( x1n > size(Original_img,2) )
                x1n = size(Original_img,2); x0n = size(Original_img,2) - (h1.x1-h1.x0);
            end
            if( x0n < 1)
                x0n = 1; x1n = 1+(h1.x1-h1.x0);
            end
            if( y1n > size(Original_img,1) )
                y1n = size(Original_img,1); y0n = size(Original_img,1) - (h1.y1-h1.y0);
            end
            if( y0n < 1)
                y0n = 1; y1n = 1+(h1.y1-h1.y0);
            end
            draw_fig(x0n, y0n, x1n,y1n)
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[] = select_level(src, eventdata, pt)%#ok<INUSL>
        cp=get(gca,'CurrentPoint'); %sets a color hand-tuned limit
        y = cp(1,2);  
        x = cp(1,1);
        if( x<-1 || x > 4 ||y<-40 || y>290 )
            uiresume
        end
        y = max(min(255,round(y)),0);
        set(pt,'ydata',y); 
        [rHmin, rHmax, gSmin, gSmax, bVmin, bVmax] = RangeValues(IsRGB, h2, IsHSplit); 
        thresh(Original_img, IsRGB, rHmin, rHmax, gSmin, gSmax, bVmin, bVmax, IsHSplit, h1.fig, th_imag_axis)     
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[] = h2buttondown(src, eventdata)
         cp=get(gca,'CurrentPoint');
         h2.x1 = round(cp(1,1));
         h2.y1 = round(cp(1,2));
         if strcmp(get(gcf,'selectiontype'), 'normal')
             h2.but = 1;
         elseif strcmp(get(gcf,'selectiontype'), 'alt')
             h2.but = 3;
         else
             h2.but = [];
         end
        rbbox; 
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[] = threshCloseFig(src, eventdata)
%         [rHmin, rHmax, gSmin, gSmax, bVmin, bVmax] = RangeValues(IsRGB, h2, IsHSplit);
%         threshedStr = strThreshedVals( IsRGB, rHmin, rHmax, gSmin, gSmax, bVmin, bVmax, IsHSplit); 
%         display(['Selected Threshold: ', threshedStr]);
        delete(get(0,'CurrentFigure'));
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[] = h2buttonup(src, eventdata)  % select/deselect pixels
        set(gcf,'Pointer','watch'); drawnow expose
        point2 = get(gca,'CurrentPoint');    % button up detected 
        %limit the points
        h2.x1  = min(max(1, h2.x1), size(ROI,2));
        h2.y1  = min(max(1, h2.y1), size(ROI,1));
        x2 = min(max(1, round(point2(1,1))),size(ROI,2));
        y2 = min(max(1, round(point2(1,2))),size(ROI,1));
        xts = min(h2.x1,x2):max(h2.x1,x2);
        yts = min(h2.y1,y2):max(h2.y1,y2);

        for k = 1:numel(xts)  %loop to step though all (de)selected pixels.
            for j = 1:numel(yts)
                xt = xts(k);
                yt = yts(j);  
                newPixel = [xt,yt];
                i = 1;  %variable to step through ValidPX
                foundpx = 0;
                while foundpx == 0 && i <= h2.numValidPX %search to see if the pixel has already been selected
                    if h2.ValidPX(i,:) == round(newPixel); 
                        foundpx = 1; %mark that we found it!
                        if(h2.but == 3) % remove this pixel
                            h2.numValidPX = h2.numValidPX -1;
                            delete(h2.Patches(i)) %remove the patch from plot window
                            if( i <= h2.numValidPX) %remove when not last item
                                h2.ValidPX(i:h2.numValidPX,:) = h2.ValidPX(i+1:h2.numValidPX+1,:);
                                h2.Patches(i:h2.numValidPX) = h2.Patches(i+1:h2.numValidPX+1);
                            end
                        end
                    end
                    i = i+1;
                end %end while
                if (foundpx == 0 && h2.but ==1) %add the patch to the screen
                    h2.numValidPX = h2.numValidPX +1;
                    h2.ValidPX(h2.numValidPX,:) = newPixel;
                    h2.Patches(h2.numValidPX)= patch([xt+0.5,xt+0.5,xt-0.5,xt-0.5],[yt+0.5,yt-0.5,yt-0.5,yt+0.5],'r');
                end
            end %column loop
        end %row loop
        set(gcf,'Pointer','fullcross'); 
        % learn about the hue wrapparound by making another plot
        [rHmin, rHmax, gSmin, gSmax, bVmin, bVmax] = RangeValues(IsRGB, h2, IsHSplit);
        % threshold original image using min and max values
        thresh(Original_img, IsRGB, rHmin, rHmax, gSmin, gSmax, bVmin, bVmax, IsHSplit, h1.fig, th_imag_axis); 
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function[] = draw_fig(x0, y0, x1,y1) % Draws a rectangle patch      
        x=[x0,x1,x1,x0,x0];
        y=[y0,y0,y1,y1,y0];
        if isempty(BOX)  % New patch
            BOX(1) = patch(x,y,'k','edgecolor','k','LineStyle','-','facealpha',0,'LineWidth',2);
            BOX(2) = patch(x,y,'k','edgecolor','w','LineStyle',':','facealpha',0,'HitTest','off','LineWidth',2);
        else   % Modify patch
            set(BOX(1),'xdata',x,'ydata',y);
            set(BOX(2),'xdata',x,'ydata',y);
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end %end function