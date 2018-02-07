clear
files=dir('truth_*.txt');

for file=files'
    
    data_t.buffer=load(file.name);
    filename=file.name(1:end-4);
    for j=1:size(data_t.buffer,1)-1
        v=[data_t.buffer(j,2:4);data_t.buffer(j+1,2:4)];
        distance_t.buffer(j)=pdist(v);
    end
    str2=['distance_t.',filename,'=distance_t.buffer;'];
    str = ['data_t.',filename,'= data_t.buffer;'];
    eval(str);
    eval(str2);
    data_t=rmfield(data_t,'buffer'); distance_t=rmfield(distance_t,'buffer');
end

clear file files i j str str2 filename

str = fileread('image_count.txt');   %read entire file into string
parts = strtrim(regexp( str, '(\r|\n)+', 'split'));  %split by each line
for i=1:size (parts,2)-1; str00=['image_count.i',parts{i},';'] ;eval(str00); end
clear i str str00 parts

filename0="";
files=dir('*_*_*.txt');
for file=files'
    data.buffer=load(file.name);
    filename=file.name(1:end-4);
    for j=1:size(data.buffer,1)-1
        v=[data.buffer(j,2:4);data.buffer(j+1,2:4)];
        distance.buffer(j)=pdist(v);
    end
    distance_sum.buffer=sum(distance.buffer);
    str3=['distance_sum.',filename,'=distance_sum.buffer;']; %trajectory total
    str2=['distance.',filename,'=distance.buffer;']; %trajectory partial
    str = ['data.',filename,'= data.buffer;']; %original data
    eval(str);
    eval(str2);
    eval(str3);
    str_start_idx=['knnsearch(data_t.truth_',filename(5:10),'(:,1),data.',filename,'(1,1))'];
    start_idx=eval(str_start_idx);
    str_end_idx=['knnsearch(data_t.truth_',filename(5:10),'(:,1),data.',filename,'(end,1))'];
    end_idx=eval(str_end_idx);
    str40=['distance_ct.',filename,'=distance_t.truth_',filename(5:10),'(start_idx:(end_idx-1)) ;']; %sum of trajectory truth corresponding to each run
    eval(str40);
    str4=['distance_t_sum.',filename,'=sum(distance_t.truth_',filename(5:10),'(start_idx:(end_idx-1)) );']; %sum of trajectory truth corresponding to each run
    eval(str4);
    str5=['data_t_partial.',filename,'=data_t.truth_',filename(5:10),'(start_idx:end_idx,:) ;']; %truth original data trimmed according to each run
    eval(str5);
    str6=['scale.',filename,'=distance_t_sum.',filename,'/distance_sum.',filename,';'];  % scale
    eval(str6);
    str7=['scaled_trajectories.',filename,'=scale.',filename,'*distance.',filename,';']; %scaled partial trajectories
    eval(str7);
    str_invCorrespondance_idx=['idx.',filename,'=knnsearch(data.',filename,'(:,1), data_t_partial.',filename,'(:,1) );'];
    eval(str_invCorrespondance_idx);
    str8=['for k=1:(size(idx.',filename,',1)-2); error.',filename,'(k)=abs(distance_ct.',filename,'(k)-scaled_trajectories.',filename,'(idx.',filename,'(k)))^2;; end;'];
    %str8=['error.',filename,'=abs(scaled_trajectories.',filename,'-distance_ct.',filename,');']; %error partial trajectories
    eval(str8);
    str9=['error_sum.',filename,'=sqrt(sum(error.',filename,'));']; %sum of errors for each run
    eval(str9);
    if string (filename(1:3))=='orb'
        str11=['completion_rate.',filename,'=( max(data.',filename,'(:,1))-min(data.',filename,'(:,1))  )/image_count.i',filename(5:17),';'];
        eval(str11);
    else
        str10=['completion_rate.',filename,'=( size(data.',filename,'(:,1),1 ) )/image_count.i',filename(5:17),';'];
        eval(str10);
    end
    str12=['total_rated_error.',filename,'=error_sum.',filename,'/completion_rate.',filename,';'];
    eval(str12);
    
    % str13=['total_rated_error_perSurvey.',filename(5:10),'=error_sum.',filename,'/completion_rate.',filename,';'];
    %eval(str13);
    filename0=filename;
    % do somthing with distance_ct, idx, scaled trajectories
    data=rmfield(data,'buffer'); distance=rmfield(distance,'buffer'); distance_sum=rmfield(distance_sum,'buffer');
end

clear file files

filename0="";
files=dir('*_*_*.txt');
for file=files'
    filename=file.name(1:end-4);    
    if (exist ('total_rated_error_perSurvey')==0)
        total_rated_error_perSurvey.tmp=0;
        total_rated_error_perMethod.tmp=0;
    end
    
    if (isfield(total_rated_error_perSurvey,filename(1:10)))
        str13=['total_rated_error_perSurvey.',filename(1:10),'=total_rated_error.',filename,'+total_rated_error_perSurvey.',filename(1:10),';'];
        str15=['total_rated_error_perMethod.',filename(1:3),'=total_rated_error.',filename,'+total_rated_error_perMethod.',filename(1:3),';'];
        eval(str13);
        eval(str15);
    else
        str14=['total_rated_error_perSurvey.',filename(1:10),'=total_rated_error.',filename,';'];
        eval(str14);
        if (isfield(total_rated_error_perMethod,filename(1:3))==0)
            
            str16=['total_rated_error_perMethod.',filename(1:3),'=total_rated_error.',filename,';'];
            
        else
            str16=['total_rated_error_perMethod.',filename(1:3),'=total_rated_error.',filename,'+total_rated_error_perMethod.',filename(1:3),';'];
        end
        
        eval(str16);
    end
end
total_rated_error_perSurvey=rmfield(total_rated_error_perSurvey,'tmp');total_rated_error_perMethod=rmfield(total_rated_error_perMethod,'tmp');

