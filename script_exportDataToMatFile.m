
%% #########################
%  save to a collective single file
%% #########################

mvOn=cell(nnH,num_subj); % movement onset
mvOff=cell(nnH,num_subj); % movement offset
RT=cell(nnH,num_subj); % reaction time
MT=cell(nnH,num_subj); % movement time
tPeakVel=cell(nnH,num_subj); % time at peak velocity from onset
peakVel=cell(nnH,num_subj); % peak velocity magnitude
TrialDiff=cell(nnH,num_subj); % trial difficulty
err_trial=cell(nnH,num_subj); % trail errors
choice=cell(nnH,num_subj); % left (-1) right (+1)
decision=cell(nnH,num_subj);
Performance=cell(nnH,num_subj); % Performance at the end of the episode [0-1]
Stimuli=cell(nnH,num_subj); % stimuli scaled to 1
OrderTask=cell(nnH,num_subj); % order in which the task has been recorded
eventsTime=cell(nnH,num_subj);
block_withinH=cell(nnH,num_subj); % order within horizon
allEvents=cell(nnH,num_subj);
eLx=cell(nnH,num_subj);
eLy=cell(nnH,num_subj);
eRx=cell(nnH,num_subj);
eRy=cell(nnH,num_subj);
eLp=cell(nnH,num_subj);
eRp=cell(nnH,num_subj);
eTime=cell(nnH,num_subj);
eyesX=cell(nnH,num_subj); % x-coord average eyes
eyesY=cell(nnH,num_subj); % y-coord average eyes
eyesP=cell(nnH,num_subj); % pupil average eyes

for sub=1:num_subj
    
    name_sub=num2str(subjN(sub));
    while length(name_sub)<3
        name_sub=append('0',name_sub);
    end
    
    load([folderRawData,'/subj_',name_sub,'.mat']);

    mvOn(:,sub)=mvOn_s;
    mvOff(:,sub)=mvOff_s;
    RT(:,sub)=RT_s;
    MT(:,sub)=MT_s;
    tPeakVel(:,sub)=tPeakVel_s;
    peakVel(:,sub)=peakVel_s;
    TrialDiff(:,sub)=TrialDiff_s;
    err_trial(:,sub)=err_trial_s;
    choice(:,sub)=choice_s;
    Performance(:,sub)=Performance_s;
    Stimuli(:,sub)=Stimuli_s;
    OrderTask(:,sub)=OrderTask_s;
    eventsTime(:,sub)=eventsTime_s;
    block_withinH(:,sub)=block_withinH_s;
    allEvents(:,sub)=allEvents_s;
    eLx(:,sub)=eLx_s;
    eLy(:,sub)=eLy_s;
    eRx(:,sub)=eRx_s;
    eRy(:,sub)=eRy_s;
    eLp(:,sub)=eLp_s;
    eRp(:,sub)=eRp_s;
    eTime(:,sub)=eTime_s;
    eyesX(:,sub)=eyesX_s;
    eyesY(:,sub)=eyesY_s;
    eyesP(:,sub)=eyesP_s;
    decision(:,sub)=decision_s;
    
    if ~isempty(eTime_s{1})
    for nH=0:nnH-1
        temp=nan(size(eLx{nH+1,sub},1),size(eLx{nH+1,sub},2),2);
        temp(:,:,1)=eLx{nH+1,sub};
        temp(:,:,2)=eRx{nH+1,sub};
        nanLocL=find(isnan(eLx{nH+1,sub}));
        nanLocR=find(isnan(eRx{nH+1,sub}));
        nanLoc= intersect(nanLocL,nanLocR);
        eyesX{nH+1,sub}=sum(temp,3,'omitnan')./2;
        eyesX{nH+1,sub}(nanLoc)=nan;
        temp=nan(size(eLx{nH+1,sub},1),size(eLx{nH+1,sub},2),2);
        temp(:,:,1)=eLy{nH+1,sub};
        temp(:,:,2)=eRy{nH+1,sub};
        nanLocL=find(isnan(eLy{nH+1,sub}));
        nanLocR=find(isnan(eRy{nH+1,sub}));
        nanLoc= intersect(nanLocL,nanLocR);
        eyesY{nH+1,sub}=sum(temp,3,'omitnan')./2;
        eyesY{nH+1,sub}(nanLoc)=nan;
        temp=nan(size(eLx{nH+1,sub},1),size(eLx{nH+1,sub},2),2);
        temp(:,:,1)=eLp{nH+1,sub};
        temp(:,:,2)=eRp{nH+1,sub};
        nanLocL=find(isnan(eLp{nH+1,sub}));
        nanLocR=find(isnan(eRp{nH+1,sub}));
        nanLoc= intersect(nanLocL,nanLocR);
        eyesP{nH+1,sub}=sum(temp,3,'omitnan')./2;
        eyesP{nH+1,sub}(nanLoc)=nan;
    end
    end
    
end
  
save([folderRawData,'/allSubjs.mat'],...
        'mvOn','mvOff','RT','MT',...
        'tPeakVel','peakVel','TrialDiff','err_trial','choice','Performance',...
        'Stimuli','OrderTask','eventsTime','num_subj','nnH','decision','block_withinH',...
        'allEvents','eLx','eLy','eRx','eRy','eLp','eRp','eTime','eyesX','eyesY','eyesP')
