function markerColor = getMarkerColor(bodypart, bodypartColor, pawPref)

[partType, laterality, partNumber] = parseBodyPart(bodypart);

switch partType
    case 'mcp'
        markerColor = bodypartColor.dig(partNumber,:) * 1/3;
    case 'pip'
        markerColor = bodypartColor.dig(partNumber,:) * 2/3;
    case 'digit'
        markerColor = bodypartColor.dig(partNumber,:);
    case 'pawdorsum'
        if strcmpi(laterality, pawPref)
            markerColor = bodypartColor.paw_dorsum;
        else
            markerColor = bodypartColor.otherPaw;
        end
    case 'nose'
        markerColor = bodypartColor.nose;
    case 'pellet'
        markerColor = bodypartColor.pellet;
end
    
    
end