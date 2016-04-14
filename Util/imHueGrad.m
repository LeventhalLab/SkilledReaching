function hgrad = imHueGrad(h)

hgrad = zeros(size(h));
for iRow = 1 : size(h,1)
    for iCol = 1 : size(h,2)
        
        cur_pt = h(iRow,iCol);
        
        numValidNeighbors = 0;
        cumDiff = 0;
        for i_neighborRow = -1 : 1
            
            row_idx = iRow + i_neighborRow;
            if row_idx < 1 || row_idx > size(h,1)
                continue;
            end
            for i_neighborCol = -1:1
                col_idx = iCol + i_neighborCol;
                if col_idx < 1 || col_idx > size(h,2)
                    continue;
                end
                
                if row_idx == 0 || col_idx == 0; continue; end
                
                numValidNeighbors = numValidNeighbors + 1;
                try
                    cumDiff = cumDiff + hueDiff(cur_pt, h(row_idx,col_idx));
                catch
                    keyboard
                end
            end
        end
        hgrad(iRow,iCol) = cumDiff / numValidNeighbors;
        
    end
end
                
                
                