function experimentInfo = getExperimentFeatures()

experimentInfo(1).type = 'chr2_during';
experimentInfo(2).type = 'chr2_between';
experimentInfo(3).type = 'arch_during';
experimentInfo(4).type = 'arch_between';
experimentInfo(5).type = 'eyfp';

for iExpt = 1 : length(experimentInfo)
    switch experimentInfo(iExpt).type
        case 'chr2_during'
            experimentInfo(iExpt).Virus = 'ChR2';
            experimentInfo(iExpt).laserWavelength = 'Blue';
            experimentInfo(iExpt).laserTiming = 'During Reach';
        case 'chr2_between'
            experimentInfo(iExpt).Virus = 'ChR2';
            experimentInfo(iExpt).laserWavelength = 'Blue';
            experimentInfo(iExpt).laserTiming = 'Between Reach';
        case 'arch_during'
            experimentInfo(iExpt).Virus = 'Arch';
            experimentInfo(iExpt).laserWavelength = 'Green';
            experimentInfo(iExpt).laserTiming = 'During Reach';
        case 'arch_between'
            experimentInfo(iExpt).Virus = 'Arch';
            experimentInfo(iExpt).laserWavelength = 'Green';
            experimentInfo(iExpt).laserTiming = 'Between Reach';
        case 'eyfp'
            experimentInfo(iExpt).Virus = 'EYFP';
            experimentInfo(iExpt).laserWavelength = 'any';
            experimentInfo(iExpt).laserTiming = 'any';
            
    end
end

