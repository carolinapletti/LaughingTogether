function [coherences] = calcCoherence(hboSub1, hboSub2, t_1, badChannels_1, badChannels_2)   
    % Calc the period 
    error = 0;
    max = round(length(t_1) / 7.8/4); %trial duration/4
    poi=[8 max]; %limits period of interest from greater than 4 times the filter to smaller than trial duration/4
    poi_index = zeros(2,1); %in which columns does the perios of interest starts/ends?
    
    sigPart1 = [t_1, hboSub1(:,1)];
    sigPart2 = [t_1, hboSub2(:,1)]; %just use the time stamps of the first participant for both, since the two time vectors need to be the same

    try    
        [~,period,~,~,~] = CP_mod_wtc(sigPart1, sigPart2); %already calculates wtc and extracts period (that is, all "frequences" that are calculated)
        poi_index(1) = find(period > poi(1), 1, 'first'); %finds the first column in period which is greater than the maximum period of interest
        poi_index(2) = find(period < poi(2), 1, 'last'); %finds the last column in period which is lower than the minimum period of interest
    catch exception
        error = 1;
        fprintf('<strong>Impossible to calculate period for some reason. Trial too short?</strong>\n');

        msgText = getReport(exception);
        fprintf(msgText);
    end 


    
    if error ~=1
        
        % -------------------------------------------------------------------------
        % Allocate memory
        % -------------------------------------------------------------------------
        %calculate how many combinations of channels there are (e.g. rTPJ1 x
        %rTPJ2, lTPJ1 x rTPJ2, etc)
        numOfChan = size(hboSub1, 2)*size(hboSub2, 2);
        %create 1xnumOfChan cell of cells. this will contain all the final
        %values for this participant pair
        coherences{numOfChan}  = []; 
        %fill each subcell with NaNs. The size is: one row per period of
        %interest, one column per time point
        coherences(:,:) = {NaN(poi_index(2)-poi_index(1)+1, length(hboSub1)+2)};
        
        %this variable contains the wavelet transform coherence values
        %calculated for each combination of channel and the content changes
        %for every iteration of the loop 
        Rsq{numOfChan} = [];
        Rsq(:) = {NaN(length(period), length(t_1))};

        % -------------------------------------------------------------------------
        % Calculate Coherence increase between conditions for every channel of the 
        % dyad
        % -------------------------------------------------------------------------
        fprintf('<strong>Estimation of the wavelet transform coherence for all channels...</strong>\n');
        %create counter for channels of Subject One
        Ch_Sub1 = 0;
        %create counter for channels of Subject Two
        Ch_Sub2 = 0;
        for i=1:1:numOfChan
            %increase counter for channels of Subject One every 4 counts of
            %i (so that a different channel of Subject 1 is picked after
            %the same channel has been used 4 times, so for each channel of
            %subject 2
            if mod(i,4) == 1
                Ch_Sub1 = Ch_Sub1 + 1;
            end
            %increase counter for channels of Subject Two of one every
            %cicle, but reset at 1 if it gets bigger than 4
            Ch_Sub2 = Ch_Sub2 +1;
            if Ch_Sub2 > 4
                Ch_Sub2 = 1;
            end
            %the first column contains the periods
            coherences{i}(:,1)  = period(poi_index(1):poi_index(2))';
            %the second contains the channel number of subject 1
            coherences{i}(:,2)  = repelem(Ch_Sub1, length(coherences{i}(:,2)));
            %the third contains the channel number of subject 2
            coherences{i}(:,3)  = repelem(Ch_Sub2, length(coherences{i}(:,2)));
            if ~any(badChannels_1 == Ch_Sub1) && ~any(badChannels_2 == Ch_Sub2) % check if the channels were not rejected in one of the two subjects during preprocessing
                sigPart1 = [t_1, hboSub1(:,Ch_Sub1)];
                sigPart2 = [t_1, hboSub2(:,Ch_Sub2)]; %artificially set the time of the second participants to t_1
                try
                    [Rsq{i}, ~, ~, coi, ~] = CP_mod_wtc(sigPart1, sigPart2);                % r square - measure for coherence
                catch exception
                    msgText = getReport(exception);
                    fprintf(msgText);
                end
                
                for j=1:1:length(coi)
                    Rsq{i}(period >= coi(j), j) = NaN;
                end
   
                coherences{i}(:,4:length(coherences{i})) = Rsq{i}(poi_index(1):poi_index(2), :);
                
            end
        end
    end
end