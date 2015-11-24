fullPawMasks{1} = centerMask;
if dMirrorIdx == 1
    fullPawMasks{2} = leftMirrorPawMask;
else
    fullPawMasks{2} = rightMirrorPawMask;
end
for iView = 1 : 2
    tempMask = false(h,w);
    for iDigit = 1 : 5
        if iView == 1
            tempDigMask = viewMask{2}(:,:,iDigit);
        else
            tempDigMask = viewMask{dMirrorIdx}(:,:,iDigit);
        end

        tempMask(bboxes(iView,2):bboxes(iView,2) + bboxes(iView,4), ...
                 bboxes(iView,1):bboxes(iView,1) + bboxes(iView,3)) = tempDigMask;
        fullPawMasks{iView} = fullPawMasks{iView} & ~tempMask;
    end
end