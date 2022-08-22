javaaddpath('./mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar')
db = nmOpen('coredembcn',{user_mySQL,'','com.mysql.cj.jdbc.Driver','jdbc:mysql://localhost:3306/'},'STRUCT=1');
num_subj=nmGet(db,'idSubject');
num_subj=num_subj.idSubject;
subjN=unique(num_subj);
num_subj=length(subjN);

%%
nnH=3; % how many horizon-type we have

% variables we want to save
mvOn=cell(nnH,num_subj); % movement onset
mvOff=cell(nnH,num_subj); % movement offset
RT=cell(nnH,num_subj); % reaction time
MT=cell(nnH,num_subj); % movement time
tPeakVel=cell(nnH,num_subj); % time at peak velocity from onset
peakVel=cell(nnH,num_subj); % peak velocity magnitude
TrialDiff=cell(nnH,num_subj); % trial difficulty
err_trial=cell(nnH,num_subj); % trail errors
choice=cell(nnH,num_subj); % left (-1) right (+1)
decision=cell(nnH,num_subj); % the equivalent of psi
Performance=cell(nnH,num_subj); % Performance at the end of the episode [0-1]
Stimuli=cell(nnH,num_subj); % stimuli scaled to 1
OrderTask=cell(nnH,num_subj); % order in which the task has been recorded
block_withinH=cell(nnH,num_subj); % order within horizon
eventsTime=cell(nnH,num_subj);
allEvents=cell(nnH,num_subj);
xy_xxyy_VR=cell(nnH,5);
xy_raw=cell(nnH,2);

eLx=cell(nnH,num_subj); % x-coord Left eye
eLy=cell(nnH,num_subj); % y-coord Left eye
eRx=cell(nnH,num_subj); % x-coord Right eye
eRy=cell(nnH,num_subj); % y-coord Right eye
eLp=cell(nnH,num_subj); % pupil size Left eye
eRp=cell(nnH,num_subj); % pupil size Right eye
eTime=cell(nnH,num_subj); % time line for eye recording
eyesX=cell(nnH,num_subj); % x-coord average eyes
eyesY=cell(nnH,num_subj); % y-coord average eyes
eyesP=cell(nnH,num_subj); % pupil average eyes

time_max=5000;
ev_code=[10,30,50,80,85];
ev_code2 = [9 10 18 20 30 40 50 80 81 85 86 87 90 95];
filt_lo=7;
sampRate=1000;
thOn=0.01; % threshold for onset
thOff=0.0001; % threshold for offset
    
%%
for sub=1:num_subj
    disp(['subj=',num2str(sub),' over ',num2str(num_subj)])
    for nH=0:nnH-1
        
        dbs = nmSubset(db,sprintf('nHorizon=%d and _trials.idSubject=%d ',nH,subjN(sub)));
      
        ev_types=split(sprintf('nTimeEvent%d ',ev_code2));
        ev_types=ev_types(1:end-1);
        data_events=nmGet(dbs,ev_types);
        data_E=struct2cell(data_events);
        allEvents{nH+1,sub}=cell2mat(data_E(2:end)');
        
        ev_types=split(sprintf('nTimeEvent%d ',ev_code));
        ev_types=ev_types(1:end-1);
        data_events=nmGet(dbs,ev_types);
        data_E=struct2cell(data_events);
        eventsTime{nH+1,sub}=cell2mat(data_E(2:end)');
        
        err_t=nmGet(dbs,'trialError');
        err_trial{nH+1,sub}=err_t.trialError;
        
        oculometry=nmGet(dbs,{'eyeTime','eyeLx','eyeLy','eyeRx','eyeRy','pupilL','pupilR'});
        eyeRecorded=~isempty(oculometry.eyeTime);
        
        data_rew=nmGet(dbs,{'reward_l=stimulus_l','reward_r=stimulus_r','choice_position',...
            'reward_episode','task_order','VisualDiscimination','block_withinHor'});
        
        dataKin = nmGetAligned(dbs,1:time_max,{'t=tTime-nTimeEvent10','x=nPosX','y=nPosY','idSubject'});
%         dataKin = nmGetAligned(dbs,eventsTime{nH+1,sub}(:,1):eventsTime{nH+1,sub}(:,1)+time_max-1,{'t=tTime','x=nPosX','y=nPosY','idSubject'});
        subj=dataKin.idSubject(1,:);
        num_trials=length(data_rew.idTrial);
        
        Performance{nH+1,sub}=data_rew.reward_episode;
        choice{nH+1,sub}=sign(data_rew.choice_position);
        Stimuli{nH+1,sub}=[data_rew.reward_l,data_rew.reward_r];%./scale_stimuli;
        TrialDiff{nH+1,sub}=1-data_rew.VisualDiscimination;
        OrderTask{nH+1,sub}=data_rew.task_order;
        block_withinH{nH+1,sub}=data_rew.block_withinHor;
        
        % set Performance to zero if error trial
        errTr=err_trial{nH+1,sub};
        ind1=reshape(errTr,nH+1,[]);
        ind1=sum(ind1);
        errTr=find(ind1); % index of the episode with an error
        errTr=errTr*(nH+1); % index of the last trial w.E
        Performance{nH+1,sub}(errTr)=0;

        % decision big/small
        temp=choice{nH+1,sub};
        ind_nan=find(temp==0);
        temp=temp>0; % if positive, then stim right is chosen
        temp2=diff(Stimuli{nH+1,sub},1,2);
        temp2=temp2>0; % if positive, then stim right is bigger
        decision{nH+1,sub}=temp==temp2; % if 1, bigger is chosen
        decision{nH+1,sub}=double(decision{nH+1,sub});
        decision{nH+1,sub}(ind_nan)=nan;
        
        % kinematics
        x_lo=nan(time_max,num_trials);
        y_lo=nan(time_max,num_trials);
        trialsAvailable=min(num_trials,length(dataKin.idTrial));
        for k=1:trialsAvailable
            x_lo(:,k) = lo_pass(dataKin.x(:,k),filt_lo,sampRate,4);
            y_lo(:,k) = lo_pass(dataKin.y(:,k),filt_lo,sampRate,4);
        end

        xx_lo=nan(time_max-1,num_trials);
        yy_lo=nan(time_max-1,num_trials);
        VR=nan(time_max-1,num_trials);
        for k=1:trialsAvailable
            xx_lo(:,k) = diff(lo_pass(x_lo(:,k),filt_lo))*1E3;
            yy_lo(:,k) = diff(lo_pass(y_lo(:,k),filt_lo))*1E3;
            VR(:,k) = xx_lo(:,k).^2 + yy_lo(:,k).^2;
        end
        xy_xxyy_VR{nH+1,1}=x_lo;
        xy_xxyy_VR{nH+1,2}=y_lo;
        xy_xxyy_VR{nH+1,3}=xx_lo;
        xy_xxyy_VR{nH+1,4}=yy_lo;
        xy_xxyy_VR{nH+1,5}=VR;
        xy_raw{nH+1,1}=dataKin.x;
        xy_raw{nH+1,2}=dataKin.y;
    
        mvOn{nH+1,sub}=nan(num_trials,1);
        mvOff{nH+1,sub}=nan(num_trials,1);
        tPeakVel{nH+1,sub}=nan(num_trials,1);
        peakVel{nH+1,sub}=nan(num_trials,1);
        LR_stim=nan(num_trials,2);
        LR_stim(:,1)=eventsTime{nH+1,sub}(:,2)-eventsTime{nH+1,sub}(:,1)+1;
        LR_stim(:,2)=eventsTime{nH+1,sub}(:,3)-eventsTime{nH+1,sub}(:,1)+1;
        time60=max(LR_stim,[],2);
        time80=eventsTime{nH+1,sub}(:,4)-eventsTime{nH+1,sub}(:,1)+1;
        for s=1:trialsAvailable
            if err_trial{nH+1,sub}(s)~=0 || isnan(time60(s))
                continue
            end
            temp=VR(time60(s):end,s)./max(VR(time60(s):end,s));
            rt=find(temp>thOn,1,'first');
            if isempty(rt)
                continue
            end
            mvOn{nH+1,sub}(s)=time60(s)+rt;
            temp2=VR(time60(s)+rt:end,s)./max(VR(time60(s)+rt:end,s));
            mvOff{nH+1,sub}(s)=time60(s)+rt+find(temp2<thOff,1,'first');
            [peakVel{nH+1,sub}(s),tPeakVel{nH+1,sub}(s)]=max(VR(mvOn{nH+1,sub}(s):mvOff{nH+1,sub}(s),s));
        end
        RT{nH+1,sub}=mvOn{nH+1,sub}-time80;
        MT{nH+1,sub}=mvOff{nH+1,sub}-mvOn{nH+1,sub}; 
        
        % oculometer
        if eyeRecorded
            % set nan when oculometer lose track of the eye
            eyeLx=oculometry.eyeLx;
            eyeLx(eyeLx<0.1)=nan;
            eyeLy=oculometry.eyeLy;
            eyeLy(eyeLy<0.1)=nan;
            eyeRx=oculometry.eyeRx;
            eyeRx(eyeRx<0.1)=nan;
            eyeRy=oculometry.eyeRy;
            eyeRy(eyeRy<0.1)=nan;
            pupL=oculometry.pupilL;
            pupL(pupL<1)=nan;
            pupR=oculometry.pupilR;
            pupR(pupR<1)=nan;

            % remove outliers
            temp=reshape(eyeLx,[],1);
            temp=isoutlier(temp,'mean');
            eyeLx(temp)=nan;
            clear temp
            temp=reshape(eyeLy,[],1);
            temp=isoutlier(temp,'mean');
            eyeLy(temp)=nan;
            clear temp
            temp=reshape(eyeRx,[],1);
            temp=isoutlier(temp,'mean');
            eyeRx(temp)=nan;
            clear temp
            temp=reshape(eyeRy,[],1);
            temp=isoutlier(temp,'mean');
            eyeRy(temp)=nan;
            clear temp
            temp=reshape(pupL,[],1);
            temp=isoutlier(temp,'mean');
            pupL(temp)=nan;
            clear temp
            temp=reshape(pupR,[],1);
            temp=isoutlier(temp,'mean');
            pupR(temp)=nan;
            clear temp

            % allign x-coord -> central target to x=0
            % align y-coord -> mean to y=0
            for bl=1:nH+1 % align by block
                ind_b=block_withinH{nH+1,sub};
                ind_b=find(ind_b==bl);
                eyeEmpty=~isnan(eyeLx(:,ind_b));
                if sum(eyeEmpty,'all')>0
                    [f,xi] = ksdensity(reshape(eyeLx(:,ind_b),[],1));
                    [~,locs] = findpeaks(f,xi,'SortStr','descend');
                    locs=locs(1:3);
                    M=maxk(locs,2);
                    eyeLx(:,ind_b)=eyeLx(:,ind_b)-M(2);

                    [f,xi] = ksdensity(reshape(eyeRx(:,ind_b),[],1));
                    [~,locs] = findpeaks(f,xi,'SortStr','descend');
                    locs=locs(1:3);
                    M=maxk(locs,2);
                    eyeRx(:,ind_b)=eyeRx(:,ind_b)-M(2);

                    [f,xi] = ksdensity(reshape(eyeLy(:,ind_b),[],1));
                    M=sum(f.*xi)/(sum(f));
                    eyeLy(:,ind_b)=eyeLy(:,ind_b)-M;

                    [f,xi] = ksdensity(reshape(eyeRy(:,ind_b),[],1));
                    M=sum(f.*xi)/(sum(f));
                    eyeRy(:,ind_b)=eyeRy(:,ind_b)-M;
                end
            end
            eLx{nH+1,sub}=eyeLx;
            eLy{nH+1,sub}=eyeLy;
            eRx{nH+1,sub}=eyeRx;
            eRy{nH+1,sub}=eyeRy;
            eLp{nH+1,sub}=pupL;
            eRp{nH+1,sub}=pupR;

            eTime{nH+1,sub}=oculometry.eyeTime; % time line for eye recording
            
            % average eyes
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
        
        % reorder trials
        temp1=nmGet(dbs,'nTrial');
        order_trials=temp1.nTrial;
        order_allTr=1:num_trials;
        l=0;
        for ii=1:nH+1
            temp=find(data_rew.block_withinHor==ii);
            order_allTr(l+1:l+length(temp))=order_trials(temp)+l;
            l=l+length(temp);
        end
        mvOn{nH+1,sub}=mvOn{nH+1,sub}(order_allTr);
        mvOff{nH+1,sub}=mvOff{nH+1,sub}(order_allTr);
        RT{nH+1,sub}=RT{nH+1,sub}(order_allTr);
        MT{nH+1,sub}=MT{nH+1,sub}(order_allTr);
        tPeakVel{nH+1,sub}=tPeakVel{nH+1,sub}(order_allTr);
        peakVel{nH+1,sub}=peakVel{nH+1,sub}(order_allTr);
        TrialDiff{nH+1,sub}=TrialDiff{nH+1,sub}(order_allTr);
        err_trial{nH+1,sub}=err_trial{nH+1,sub}(order_allTr);
        choice{nH+1,sub}=choice{nH+1,sub}(order_allTr);
        Performance{nH+1,sub}=Performance{nH+1,sub}(order_allTr);
        Stimuli{nH+1,sub}=Stimuli{nH+1,sub}(order_allTr,:);
        OrderTask{nH+1,sub}=OrderTask{nH+1,sub}(order_allTr);
        block_withinH{nH+1,sub}=block_withinH{nH+1,sub}(order_allTr);
        eventsTime{nH+1,sub}=eventsTime{nH+1,sub}(order_allTr,:);
        allEvents{nH+1,sub}=allEvents{nH+1,sub}(order_allTr,:);
        decision{nH+1,sub}=decision{nH+1,sub}(order_allTr,:);
        if eyeRecorded
            eLx{nH+1,sub}=eLx{nH+1,sub}(:,order_allTr);
            eLy{nH+1,sub}=eLy{nH+1,sub}(:,order_allTr);
            eRx{nH+1,sub}=eRx{nH+1,sub}(:,order_allTr);
            eRy{nH+1,sub}=eRy{nH+1,sub}(:,order_allTr);
            eLp{nH+1,sub}=eLp{nH+1,sub}(:,order_allTr);
            eRp{nH+1,sub}=eRp{nH+1,sub}(:,order_allTr);
            eTime{nH+1,sub}=eTime{nH+1,sub}(:,order_allTr);
        end
    end

    %% #########################
    %  save to one single file per subject
    %% #########################

    mvOn_s=mvOn(:,sub); % movement onset
    mvOff_s=mvOff(:,sub); % movement offset
    RT_s=RT(:,sub); % reaction time
    MT_s=MT(:,sub); % movement time
    tPeakVel_s=tPeakVel(:,sub); % time at peak velocity from onset
    peakVel_s=peakVel(:,sub); % peak velocity magnitude
    TrialDiff_s=TrialDiff(:,sub); % trial difficulty
    err_trial_s=err_trial(:,sub); % trail errors
    choice_s=choice(:,sub); % left (-1) right (+1)
    Performance_s=Performance(:,sub); % Performance at the end of the episode [0-1]
    Stimuli_s=Stimuli(:,sub); % stimuli scaled to 1
    OrderTask_s=OrderTask(:,sub); % order in which the task has been recorded
    block_withinH_s=block_withinH(:,sub);
    eventsTime_s=eventsTime(:,sub);
    allEvents_s=allEvents(:,sub);
    decision_s=decision(:,sub);
    eLx_s=eLx(:,sub);
    eLy_s=eLy(:,sub);
    eRx_s=eRx(:,sub);
    eRy_s=eRy(:,sub);
    eLp_s=eLp(:,sub);
    eRp_s=eRp(:,sub);
    eTime_s=eTime(:,sub);
    eyesX_s=eyesX(:,sub);
    eyesY_s=eyesY(:,sub);
    eyesP_s=eyesP(:,sub);

    name_sub=num2str(subjN(sub));
    while length(name_sub)<3
        name_sub=append('0',name_sub);
    end
    
    save([folderRawData,'/subj_',name_sub,'.mat'],...
        'mvOn_s','mvOff_s','RT_s','MT_s',...
        'tPeakVel_s','peakVel_s','TrialDiff_s','err_trial_s','choice_s','Performance_s',...
        'Stimuli_s','OrderTask_s','eventsTime_s','block_withinH_s','allEvents_s',...
        'eLx_s','eLy_s','eRx_s','eRy_s','eLp_s','eRp_s','eTime_s','decision_s',...
        'eyesX_s','eyesY_s','eyesP_s')
end

%%