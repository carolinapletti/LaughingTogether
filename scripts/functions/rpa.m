function [data_sub1, data_sub2] = rpa(file_name, id, List_all, sum_Sources) 
    % load preprocessed data
    filename_sub1    = file_name;
    r=randi(sum_Sources);
    temp = strsplit(List_all{1,r}, '_');
    filename_sub2    = strcat(temp{1},'_', temp{2},'_', 'sub2.mat');
    
    fprintf('Load preprocessed data...\n');
    file_path_sub1 = strcat(List_all{2,id},'\', filename_sub1)
    file_path_sub2 = strcat(List_all{2,r},'\', filename_sub2)

    data_sub1=load(file_path_sub1); 
    data_sub2=load(file_path_sub2);