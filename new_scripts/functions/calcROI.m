function [ROIsHbo, badROI] = calcROI(hbo, badChannels)   
    badROI = [];
    count = 0;
    %remove values of bad channels
    hbo(:,badChannels) = NaN;
    %check that each ROI has at least two good channels. If not, the ROI
    %becomes NaN
    if sum(ismember(9:12,badChannels)) < 3
        %only average the columns that are not NaN
        IFGr = nanmean(hbo(:,9:12),2);
    else
        IFGr = NaN(length(hbo),1);
        count = count +1;
        badROI(count) = 1;
    end

    if sum(ismember(5:8,badChannels)) < 3
        %change so that bad channels are not included!!
        IFGl = nanmean(hbo(:,5:8),2);
    else
        IFGl = NaN(length(hbo),1);
        count = count + 1;
        badROI(count) = 2;
    end

    if sum(ismember(13:16,badChannels)) < 3
        %change so that bad channels are not included!!
        TPJr = nanmean(hbo(:,13:16),2);
    else
        TPJr = NaN(length(hbo),1);
        count = count + 1;
        badROI(count) = 3;
    end

    if sum(ismember(1:4,badChannels)) < 3
        %change so that bad channels are not included!!
        TPJl = nanmean(hbo(:,1:4),2);
    else
        TPJl = NaN(length(hbo),1);
        count = count + 1;
        badROI(count) = 4;
    end
    
    ROIsHbo = [IFGr, IFGl, TPJr, TPJl];