function [data_out] = epoch_laughter(data_in) 

    fprintf('time stamp laughter video beginnings');
    evtLaughter  = find(data_in.s(:, 3) > 0)
    fprintf('time stamp laughter video ends');
    evtLaughterEnd  = find(data_in.s(:, 4) > 0)

    if size(evtLaughter,1)~=2 | size(evtLaughterEnd,1)~=2
        fprintf('Trial number is different than expected!\n');
        weirdtrials=1;
    else
        fprintf('Trial number is correct!\n');
        weirdtrials=0;
    end

    %cut out laughter data 

    if weirdtrials == 0
        tn = 0; %trial number counter
        for m = 1:length(evtLaughter)
            if evtLaughterEnd(m)-evtLaughter(m) < 2329 %5 min with 7.8 sampling rate = 2340 points. 2330 to be on the safe side
                fprintf('Too short trial!\n');
                weirdtrials=1;
            elseif evtLaughterEnd(m)-evtLaughter(m) > 2390 %left "spielraum" in case delays in triggers
                fprintf('Too long trial!\n');
                weirdtrials=1;
            else
                tn = tn + 1;
                data_out.d{tn} = data_in.d(evtLaughter(m):evtLaughterEnd(m),:);
                data_out.s{tn} = data_in.s(evtLaughter(m):evtLaughterEnd(m),:);
                data_out.t{tn} = data_in.t(evtLaughter(m):evtLaughterEnd(m),:);
                data_out.aux{tn} = data_in.aux(evtLaughter(m):evtLaughterEnd(m),:);
            end
        end
        data_out.SD = data_in.SD;
    end
end