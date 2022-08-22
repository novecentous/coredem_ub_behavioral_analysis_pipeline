
max_horizon=2;
dirGeneral = [folderRawData,'/subj',idSubject];
file=dir([dirGeneral,'/*task1*.bhv2*']);
date=file.name(9:14);
file=dir([dirGeneral,'/*.bhv2*']);
num_Blocks = length(file);
fileEye=dir([dirGeneral,'/*.csv']);
dDate1 = sprintf('%s-%s-%s',date(end-1:end),date(3:4),date(1:2)); 

%% open connection
javaaddpath('./mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar')
db = nmOpen('coredembcn',{user_mySQL,'','com.mysql.cj.jdbc.Driver','jdbc:mysql://localhost:3306/'},'STRUCT=1');
listEvents = [9 10 18 20 30 40 50 80 81 85];

%% load task files
for i=1:num_Blocks

    % check for already existing subject
    sQuery = sprintf('select idSubject from _subjects where idSubject=%d',str2double(idSubject));
    x = nmDoQuery(db,sQuery);
    % if not there, insert new subject id
    if (isempty(x))
        mysubject = struct('idSubject',str2double(idSubject));
        nmAdd(db,'_subjects',mysubject);
    end

    % load trial data
    aa = mlread(sprintf('%s/%s',dirGeneral,file(i).name));
    
    %
    oderTask=uint8(str2double(file(i).name(27)));      % when this task has been performed in the session
    typeTask=str2double(file(i).name(20:21));   % type of task
    if mod(typeTask,10)==1                      % nHorizon and block
        nH=0;
        block=1;
    elseif ismember(mod(typeTask,10),2:3)
        nH=1;
        block=mod(typeTask,10)-1;
    elseif ismember(mod(typeTask,10),4:6)
        nH=2;
        block=mod(typeTask,10)-3;
    end
    block=uint8(block);
    
    % check for already existing data
    sQuery = sprintf('select idTrial from _trials where idSubject=%d and nHorizon=%d and block_withinHor=%d',str2double(idSubject),nH,block);
    x = nmDoQuery(db,sQuery);
    if (~isempty(x))
        disp(['data already in DB. Ending upload...']);
        break;
    end

    % number of trials to upload
    if nH==2
        if block==3
            trialsToUpload=90;
        else
            trialsToUpload=105;
        end
    else
        trialsToUpload=100;
    end
    trailsAvailable=size(aa,2);
    
    % load eye data
    if ~isempty(fileEye)
        eyeData=readtable([dirGeneral,'/',fileEye(i).name]);
        eyeData=eyeData(:,2:end);
        names_var=eyeData.Properties.VariableNames;
        eyeData=table2array(eyeData);
    end
    
    listFields = fieldnames(aa);
    for nT = 1:trialsToUpload % select this if you want to upload everything: size(aa,2)
        av_choice=nan(1,2^(max_horizon+1));
        Trial=nT;
        mydata = struct('nTrial',Trial);
        
        if nT>trailsAvailable
            dDate=nan;
            TrialError=11;
            visDisc=nan;
            choice_position=nan;
            reward_episode=nan;
            feedback_visible=nan;
            oderTask=nan;
            block=nan;
            stimuli=[nan,nan];
        else
        
            for n=1:size(fieldnames(aa),1)
                eval(sprintf('%s=aa(nT).%s;',listFields{n},listFields{n})); 
            end
            dDate = sprintf('20%s %d:%d:%d',dDate1,TrialDateTime(4),TrialDateTime(5),floor(TrialDateTime(6)));

            % error trial = 9 -> aborted
            if TrialError==9
                visDisc=nan;
                choice_position=nan;
                reward_episode=nan;
                feedback_visible=nan;
                stimuli=[nan,nan];
            else
                av_choice(1:length(UserVars.available_choices)-1)=UserVars.available_choices(2:length(UserVars.available_choices));

                choice_position = UserVars.choice_position(end,1);
                visDisc=abs(UserVars.available_choices(2)-UserVars.available_choices(3));
                    reward_episode=UserVars.feedback;
                    stimuli=UserVars.presented_stimuli;
                    feedback_visible=UserVars.feedback_visible;
            end

    %         cycle_rate1 = CycleRate(1);
    %         cycle_rate2 = CycleRate(2);
    
        % process events: nTimeEvent
            for k=1:numel(listEvents)
                i1 = find(BehavioralCodes.CodeNumbers==listEvents(k));
                if ~isempty(i1)
                    name=['nTimeEvent',num2str(listEvents(k))];
                    eval(sprintf('mydata.%s=%d;',name,round(BehavioralCodes.CodeTimes(i1))));
                end
            end
        end

        mydata.dDate=dDate;
        mydata.nTrial=Trial;
        mydata.idSubject=str2double(idSubject);
        mydata.nHorizon=nH;
        mydata.TrialError=TrialError;
        mydata.VisualDiscimination=visDisc;
        mydata.choice_position=choice_position;
        mydata.reward_episode=reward_episode;
        mydata.feedback_visible=feedback_visible;
        mydata.task_order=oderTask;
        mydata.block_withinHor=block;
        mydata.stimulus_l=stimuli(1);
        mydata.stimulus_r=stimuli(2);
        
        for av=1:2^(max_horizon+1)
            name=['av_choice',num2str(av)];
            eval(sprintf('mydata.%s=%d;',name,av_choice(av)))
        end
        nmAdd(db, '_trials',mydata);
        
        sQuery = 'select idTrial from _trials order by idTrial;';
        x = nmDoQuery(db,sQuery,'numeric');
        myIdTrial = x(end);
        % kinematics
        if nT<=trailsAvailable
            % mouse trajs & button
            X = AnalogData.Mouse(:,1);
            Y = AnalogData.Mouse(:,2);
            bButton = AnalogData.KeyInput(:,3);
            mykin = struct('idTrial',repmat(myIdTrial,numel(X),1),'tTime',[1:numel(X)]','nPosX',X,'nPosY',Y,'nButton',double(bButton));
        else
            mykin = struct('idTrial',myIdTrial,'tTime',0,'nPosX',0,'nPosY',0,'nButton',0);
        end
        nmAdd(db,'kinematics',mykin);
        
        % upload oculometry
        if ~isempty(fileEye)
            if ~isempty(eyeData)
                temp_ind=find(eyeData(:,1)==nT);
                tempEye=eyeData(temp_ind,:); % select specific trial
                t_eye=tempEye(:,2)+mydata.nTimeEvent10; % oculometer starts recording at nTimeEvent10

                myocular = struct('idTrial',repmat(myIdTrial,length(temp_ind),1),'eyeTime',t_eye,...
                    'eyeLx',tempEye(:,3),'eyeLy',tempEye(:,4),'pupilL',tempEye(:,9),...
                    'eyeRx',tempEye(:,10),'eyeRy',tempEye(:,11),'pupilR',tempEye(:,16));
            else
                myocular = struct('idTrial',myIdTrial,'eyeTime',mydata.nTimeEvent10,...
                    'eyeLx',0,'eyeLy',0,'pupilL',0,'eyeRx',0,'eyeRy',0,'pupilR',0);
            end
            nmAdd(db,'oculometry',myocular);
        end
    end
end
    
%%