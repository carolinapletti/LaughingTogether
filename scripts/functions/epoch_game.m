function data_out = epoch_game(data_in) 

    fprintf('time stamp game begins');
    evtGame  = find(data_in.s(:, 7) > 0)
    fprintf('time stamp game ends');
    evtGameEnd  = find(data_in.s(:, 8) > 0)

    %cut out game data

    data_out.d = data_in.d(evtGame:evtGameEnd,:);
    data_out.s = data_in.s(evtGame:evtGameEnd,:);
    data_out.t = data_in.t(evtGame:evtGameEnd,:);
    data_out.aux = data_in.aux(evtGame:evtGameEnd,:);
    data_out.SD = data_in.SD;
end