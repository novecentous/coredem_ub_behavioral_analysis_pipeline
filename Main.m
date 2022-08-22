
clearvars
close all

%% Upload to MySQL databease
disp('Select the folder where the raw data are saved')
folderRawData=uigetdir;

prompt='Type on string format your user name on MySQL: ';
user_mySQL=input(prompt);

disp('Repeat this step for all participants you want to load.')

temp_go=0;
while temp_go~=1
    prompt = 'Type the subject number you want to upload: ';
    idSubject = input(prompt);
    idSubject=num2str(idSubject);
    while length(idSubject)<3
        idSubject=append('0',idSubject);
    end
    
    script_uploadToMysql

    prompt = 'Are you done with the upload? Yes (1), No (0): ';
    temp_go = input(prompt);
    while ~ismember(temp_go,[0,1])
        disp('You must insert either 0 or 1')
        temp_go = input(prompt);
    end

end 

%% Download data from MySQL database and export into matlab file

% download and save to single files per participant
script_downloadFromMysql
% export to a single collective matlab file
script_exportDataToMatFile

%% Data plots and further analysis 

prompt='Do you want to include all participants? Yes (1), No (0):';
temp=input(prompt);
while ~ismember(temp,[0,1])
        disp('You must insert either 0 or 1')
        temp= input(prompt);
end
if temp==1
    participantsToInclude=1:num_subj;
else
    disp('Insert numbers referring to the list saved before.')
    prompt='Which participants do you want to include? ';
    participantsToInclude=input(prompt);
end

script_plotsBehav
script_plotsOculometry

%%
