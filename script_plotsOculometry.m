
load([folderRawData,'/allSubjs.mat'])
     
% include only some participants
num_subj=length(participantsToInclude);
block_withinH=block_withinH(:,participantsToInclude);
choice=choice(:,participantsToInclude);
decision=decision(:,participantsToInclude);
err_trial=err_trial(:,participantsToInclude);
eventsTime=eventsTime(:,participantsToInclude);
MT=MT(:,participantsToInclude);
mvOff=mvOff(:,participantsToInclude);
mvOn=mvOn(:,participantsToInclude);
OrderTask=OrderTask(:,participantsToInclude);
peakVel=peakVel(:,participantsToInclude);
Performance=Performance(:,participantsToInclude);
RT=RT(:,participantsToInclude);
Stimuli=Stimuli(:,participantsToInclude);
tPeakVel=tPeakVel(:,participantsToInclude);
TrialDiff=TrialDiff(:,participantsToInclude);
eLp=eLp(:,participantsToInclude);
eLx=eLx(:,participantsToInclude);
eLy=eLy(:,participantsToInclude);
eRp=eRp(:,participantsToInclude);
eRx=eRx(:,participantsToInclude);
eRy=eRy(:,participantsToInclude);
eTime=eTime(:,participantsToInclude);
eyesX=eyesX(:,participantsToInclude);
eyesY=eyesY(:,participantsToInclude);
eyesP=eyesP(:,participantsToInclude);
allEvents=allEvents(:,participantsToInclude);


% set Performance to zero if error trial
for sub=1:num_subj
    for nH=0:nnH-1 
%         extra=mod(length(Performance{nH+1,sub}),nH+1);
%         Performance{nH+1,sub}=Performance{nH+1,sub}(1:end-extra);
%         errTr=err_trial{nH+1,sub}(1:end-extra);
        errTr=err_trial{nH+1,sub};
        ind1=reshape(errTr,nH+1,[]);
        ind1=sum(ind1);
        errTr=find(ind1); % index of the episode with an error
        errTr=errTr*(nH+1); % index of the last trial w.E
        Performance{nH+1,sub}(errTr)=0;
    end
end


subj_name=split(sprintf('P.%d ',1:num_subj));
subj_name=subj_name(1:num_subj);

% color for trial within episode
col=[
    0.12      0.52      0.22;   % green
    0         0.35      0.70;   % blue
    0.81      0.16      0.16;   % red
    ]; 
% color for DIFFICULTY
col_d=[
    0         0.41      0.36;   % acquamarina (RP)
    0.30      0.74      0.93;   % light blue (not RP all)
    0.76      0.57      0.87;   % light purple (Pass)
    0.45      0.18         0;   % brown (F)
    0.70      0.48      0.32;   % light brown (not F)
    0.49      0.18      0.55;   % purple (Act)
                            ];
font_dim=16;
mark={'o','^','+'};

set(0,'defaultLegendInterpreter','latex')
set(0,'defaultAxesTickLabelInterpreter','latex')
set(0,'defaultTextInterpreter','latex')

%% when do they learn?
th=0.92;
th2=0.9;
time_learn=cell(nnH,num_subj);
time_learn2=cell(nnH,num_subj);
for sub=1:num_subj
    for nH=0:nnH-1
        % remove error trials from participant
        perf=Performance{nH+1,sub};
        errTr=err_trial{nH+1,sub};
        ind1=reshape(errTr,nH+1,[]);
        ind1=sum(ind1,1);
        errTr=find(ind1);
        errTr=errTr*(nH+1);
        perf(errTr)=nan; % set performance for error trial to zero
        noErrTr=find(ind1<0.1);
        noErrTrIdx=noErrTr*(nH+1);  % index of episodes
        % select easy trials
        ind_easy=find(TrialDiff{nH+1,sub}<0.97);
        ind_easyNoErr=intersect(noErrTrIdx,ind_easy);
        perf_easy=perf(ind_easyNoErr);
        ind_easyNoErr=ind_easyNoErr/(nH+1);
        % plot(ind_easyNoErr,perf_easy,'gx')
        perf_t=nan(length(perf_easy),1);
        temp1=nan(length(perf_easy),1);
        for t=1:length(perf_easy)-10
            perf_t(t)=mean(perf_easy(t:end),'omitnan');
            temp1(t)=mean(perf_easy(t:t+10));
        end
        temp=find(perf_t>th,1,'first');
        time_learn{nH+1,sub}=ind_easyNoErr(temp);
        temp=find(temp1>th2,1,'first');
        time_learn2{nH+1,sub}=ind_easyNoErr(temp);
    end
end

%% Time interval of interest
% = 1 : 1st stimulus presentation
% = 2 : last stimulus disappears
% = 3 : both stimuli appear
TimeInt_go=1;
% = 1 : mv Onset
% = 2 : mv Offset
% = 3 : target selection
TimeInt_stop=1;

TimeInt_go_label={'1st-Stim','Last-Stim','Both-Stim'};
TimeInt_stop_label={'MvOn','MvOff','Target-sel'};
TimeInt_go_label=TimeInt_go_label{TimeInt_go};
TimeInt_stop_label=TimeInt_stop_label{TimeInt_stop};


%% saccades - at least 30ms, cross 0 

borderSaccade=150;
binsEdgeDiff=[0.77,0.82,0.87,0.92,0.97,1.2];
binsEdgeName={'0.8','0.85','0.9','0.95','0.99'};

num_sacc=cell(size(eLx));
num_saccDiff=cell(size(eLx));
num_saccDiffnTe=cell(size(eLx));
for sub=1:num_subj
    for nH=0:nnH-1
%         goT=eventsTime{nH+1,sub}(:,4); % go
        goT=eventsTime{nH+1,sub}(:,3);
        % goT=min(allEvents{nH+1,sub}(:,4),allEvents{nH+1,sub}(:,6)); % 1st stim
        stopT=mvOn{nH+1,sub}+eventsTime{nH+1,sub}(:,1)+100; % movement onset + 100ms

        num_sacc{nH+1,sub}=nan(length(err_trial{nH+1,sub}),2);

for n_t=1:length(err_trial{nH+1,sub})
    ind_int=find((eTime{nH+1,sub}(:,n_t)>goT(n_t))&(eTime{nH+1,sub}(:,n_t)<stopT(n_t))); % beforeGo - mov.Onset
    if sum(isnan(eyesX{nH+1,sub}(ind_int,n_t)))>0.2*length(ind_int)
        continue
    end
    % left
    t_l=find(eyesX{nH+1,sub}(ind_int,n_t)<-borderSaccade); % index time
    tt_l=eTime{nH+1,sub}(ind_int(t_l),n_t); % time
    ind_lj=find(diff(tt_l)>30); % find clusters
    if isempty(tt_l)
        ind_lj2=[];
    else
        ind_ljNew=[];
        if ~isempty(ind_lj)
            l=1;
            for ii=1:length(ind_lj) % what is in the gaps
                ind_li=(ind_int(t_l(ind_lj(ii)))+1):(ind_int(t_l(ind_lj(ii)+1))-1);
                overCross=sum(eyesX{nH+1,sub}(ind_li,n_t)>0); % do I cross over?
                if overCross~=0
                    ind_ljNew(l)=ind_lj(ii);
                    l=l+1;
                end
            end
        end
        ind_lj2=nan(length(ind_ljNew)+1,2);
        if isempty(ind_ljNew)
            ind_lj2=[tt_l(1),tt_l(end)];
        else
            for ii=1:length(ind_ljNew)+1 % adjust possible border effect
                if ii==1
                    ind_lj2(ii,:)=[tt_l(1),tt_l(ind_ljNew(1))];
                elseif ii==length(ind_ljNew)+1
                    ind_lj2(ii,:)=[tt_l(ind_ljNew(ii-1)+1),tt_l(end)];
                else
                    ind_lj2(ii,:)=[tt_l(ind_ljNew(ii-1)+1),tt_l(ind_ljNew(ii))];
                end
            end    
        end
    end

    % right
    t_r=find(eyesX{nH+1,sub}(ind_int,n_t)>borderSaccade); % index time
    tt_r=eTime{nH+1,sub}(ind_int(t_r),n_t); % time
    ind_rj=find(diff(tt_r)>30); % find clusters
    if isempty(tt_r)
        ind_rj2=[];
    else
        ind_rjNew=[];
        if ~isempty(ind_rj)
            l=1;
            for ii=1:length(ind_rj) % what is in the gaps
                ind_ri=(ind_int(t_r(ind_rj(ii)))+1):(ind_int(t_r(ind_rj(ii)+1))-1);
                overCross=sum(eyesX{nH+1,sub}(ind_ri,n_t)<0); % do I cross over?
                if overCross~=0
                    ind_rjNew(l)=ind_rj(ii);
                    l=l+1;
                end
            end
        end
        ind_rj2=nan(length(ind_rjNew)+1,2);
        if isempty(ind_rjNew)
            ind_rj2=[tt_r(1),tt_r(end)];
        else
            for ii=1:length(ind_rjNew)+1 % adjust possible border effect
                if ii==1
                    ind_rj2(ii,:)=[tt_r(1),tt_r(ind_rjNew(1))];
                elseif ii==length(ind_rjNew)+1
                    ind_rj2(ii,:)=[tt_r(ind_rjNew(ii-1)+1),tt_r(end)];
                else
                    ind_rj2(ii,:)=[tt_r(ind_rjNew(ii-1)+1),tt_r(ind_rjNew(ii))];
                end
            end    
        end
    end
    % calculate number of saccade
    num_sacc{nH+1,sub}(n_t,:)=[sum(diff(ind_lj2,1,2)>30),sum(diff(ind_rj2,1,2)>30)];
end
        num_saccDiff{nH+1,sub}=nan(length(binsEdgeDiff)-1,1);
        num_saccDiffnTe{nH+1,sub}=nan(length(binsEdgeDiff)-1,nnH);
        for stimDiff=1:length(binsEdgeDiff)-1
            ind_diff=find(TrialDiff{nH+1,sub}>binsEdgeDiff(stimDiff) & TrialDiff{nH+1,sub}<=binsEdgeDiff(stimDiff+1));
            num_saccDiff{nH+1,sub}(stimDiff)=2*mean(num_sacc{nH+1,sub}(ind_diff,:),'all','omitnan');
            ind_nTe=mod(ind_diff-1,3)+1;
            for ii=1:nH+1
                num_saccDiffnTe{nH+1,sub}(stimDiff,ii)=2*mean(num_sacc{nH+1,sub}(ind_diff(ind_nTe==ii),:),'all','omitnan');
            end
        end
    end
end

%% saccade vs difficulty
figure(10);clf;
set(gcf,'Position',[1 60 1200 600])
tl = tiledlayout(nnH,num_subj,'Padding','none','TileSpacing','compact');
for nH=0:nnH-1
    for sub=1:num_subj
        nexttile(sub+(num_subj)*nH)
        ax=gca;
        hold on
        plot(num_saccDiff{nH+1,sub},'b','Marker','o')
        xlim([0,6])   
        ylim([1,6])
        if nH==0
            title(subj_name{sub},'FontSize',font_dim)
        end
        if sub~=1
            yticks([])
        end
        if nH<nnH-1
            xticks([])
        else
            xticks([1,5])
            xticklabels(binsEdgeName([1,5]))
        end
        if sub==num_subj
            colororder({'k','k'})
            yyaxis right
            ylabel(['nH=',num2str(nH)]);
            yticks([])
        end
        if sub==1&&nH>1
            lgn=legend('Location','northeast');
            lgn.FontSize=font_dim-4;
            lgn.ItemTokenSize=[10,18];   
        end
        box on; ax.FontSize=font_dim;
    end
end
ylabel(tl,'Mean No. saccades','Interpreter','latex','FontSize',font_dim+2)
xlabel(tl,'Difficulty','Interpreter','latex','FontSize',font_dim+2)
title(tl,'Mean No. saccade per difficulty','Interpreter','latex','FontSize',font_dim+2)

%% saccade vs difficulty - trial within episode
figure(11);clf;
set(gcf,'Position',[1 60 1200 600])
tl = tiledlayout(nnH,num_subj,'Padding','none','TileSpacing','compact');
for nH=0:nnH-1
    for sub=1:num_subj
        nexttile(sub+(num_subj)*nH)
        ax=gca;
        hold on
        for nTe=1:nH+1
            plot(num_saccDiffnTe{nH+1,sub}(:,nTe),'Color',col(nTe,:),'Marker','o','DisplayName',['nTe=',num2str(nTe)])
        end
        xlim([0,6])   
        ylim([1,6])
        if nH==0
            title(subj_name{sub},'FontSize',font_dim)
        end
        if sub~=1
            yticks([])
        end
        if nH<nnH-1
            xticks([])
        else
            xticks([1,5])
            xticklabels(binsEdgeName([1,5]))
        end
        if sub==num_subj
            colororder({'k','k'})
            yyaxis right
            ylabel(['nH=',num2str(nH)]);
            yticks([])
        end
        if sub==1&&nH>1
            lgn=legend('Location','northwest');
            lgn.FontSize=font_dim-4;
            lgn.ItemTokenSize=[10,18];   
        end
        box on; ax.FontSize=font_dim;
    end
end
ylabel(tl,'Mean No. saccades','Interpreter','latex','FontSize',font_dim+2)
xlabel(tl,'Difficulty','Interpreter','latex','FontSize',font_dim+2)
title(tl,'Mean No. saccade per difficulty and Trial within Episode','Interpreter','latex','FontSize',font_dim+2)

%% saccade vs difficulty - all participants together

figure(20);clf;
set(gcf,'Position',[1 60 400 300])
ax=gca;
hold on

for nH=0:nnH-1
    temp=cell2mat(num_saccDiff(nH+1,:));
    mm=mean(temp');
    ss=0.5*std(temp');
    
%     plot(mm,'b','Color',col(nH+1,:),'Marker','o','DisplayName',['nH=',num2str(nH)])
    errorbar(1:5,mm,ss,'Color',col(nH+1,:),'Marker','o','DisplayName',['nH=',num2str(nH)])
end
xticks(1:5)
xticklabels(binsEdgeName)
yticks(1:5)
xlim([0,6])   
ylim([1,4.5])
legend('Location','northwest')
box on; ax.FontSize=font_dim;
ylabel('Mean No. saccades','Interpreter','latex','FontSize',font_dim+2)
xlabel('Difficulty','Interpreter','latex','FontSize',font_dim+2)
title('Mean No. saccade per difficulty','Interpreter','latex','FontSize',font_dim+2)


%% saccade vs difficulty - all participants together - trial within episode
subjToInclude=[10,11,13,14,16:19];

figure(21);clf;
set(gcf,'Position',[1 60 700 300])
tl = tiledlayout(1,nnH,'Padding','none','TileSpacing','compact');

for nH=0:nnH-1
    nexttile
    ax=gca;
    hold on

    temp1=cell2mat(num_saccDiffnTe(nH+1,:));
    for nTe=1:nH+1
        temp=temp1(:,nTe:nnH:end);
        mm=mean(temp');
        ss=0.5*std(temp');
    %     plot(mm,'b','Color',col(nH+1,:),'Marker','o','DisplayName',['nH=',num2str(nH)])
        errorbar(1:5,mm,ss,'Color',col(nTe,:),'Marker','o','DisplayName',['nTe=',num2str(nTe)])
        title(['nH=',num2str(nH)])
    end
    xticks(1:5)
    xticklabels(binsEdgeName)
    if nH==0
        yticks(1:5)
    else
        yticks([])
    end
    xlim([0,6])   
    ylim([1,4.5])
    box on; ax.FontSize=font_dim;
end
legend('Location','northwest')
ylabel(tl,'Mean No. saccades','Interpreter','latex','FontSize',font_dim+2)
xlabel(tl,'Difficulty','Interpreter','latex','FontSize',font_dim+2)
title(tl,'Mean No. saccade per difficulty and trial within episode','Interpreter','latex','FontSize',font_dim+2)

%% densities Left eye
xEd=linspace(-500,500,100);
yEd=linspace(-300,300,100);

figure(30);clf;
set(gcf,'Position',[1 100 700 400])
tiledlayout(2,3,'Padding','none','TileSpacing','compact');
nexttile(1)
ax=gca;
histogram(reshape(eLx{nH+1,sub},[],1),xEd,'Normalization','pdf')
xlim([-500 500])
% ylim([0,0.008])
xlabel('x-coord')
ylabel('density')
box on; ax.FontSize=font_dim;

nexttile(4)
ax=gca;
[f,xi] = ksdensity(reshape(eLx{nH+1,sub},[],1));
plot(xi,f,'LineWidth',2)
xlim([-500 500])
% ylim([0,0.008])
xlabel('x-coord')
ylabel('smooth density')
box on; ax.FontSize=font_dim;

nexttile(2,[2,2])
ax=gca;
histogram2(reshape(eLx{nH+1,sub},[],1),reshape(eLy{nH+1,sub},[],1),xEd,yEd,'DisplayStyle','tile','ShowEmptyBins','on',...
    'Normalization','countdensity')
colorbar
caxis([0.01,0.3])
xlim([-500 500])
ylim([-300,300])
xlabel('x-coord')
ylabel('y-coord')
title('Left eye')
box on; ax.FontSize=font_dim;

%% densities Right eye
xEd=linspace(-500,500,100);
yEd=linspace(-300,300,100);

figure(31);clf;
set(gcf,'Position',[1 100 700 400])
tiledlayout(2,3,'Padding','none','TileSpacing','compact');
nexttile(1)
ax=gca;
histogram(reshape(eRx{nH+1,sub},[],1),xEd,'Normalization','pdf')
xlim([-500 500])
% ylim([0,0.008])
xlabel('x-coord')
ylabel('density')
box on; ax.FontSize=font_dim;

nexttile(4)
ax=gca;
[f,xi] = ksdensity(reshape(eRx{nH+1,sub},[],1));
plot(xi,f,'LineWidth',2)
xlim([-500 500])
% ylim([0,0.008])
xlabel('x-coord')
ylabel('smooth density')
box on; ax.FontSize=font_dim;

nexttile(2,[2,2])
ax=gca;
histogram2(reshape(eRx{nH+1,sub},[],1),reshape(eRy{nH+1,sub},[],1),xEd,yEd,'DisplayStyle','tile','ShowEmptyBins','on',...
    'Normalization','countdensity')
colorbar
caxis([0.01,0.3])
xlim([-500 500])
ylim([-300,300])
xlabel('x-coord')
ylabel('y-coord')
title('Right eye')
box on; ax.FontSize=font_dim;

%% densities both eyes
xEd=linspace(-500,500,100);
yEd=linspace(-300,300,100);

figure(32);clf;
set(gcf,'Position',[1 100 700 400])
tiledlayout(2,3,'Padding','none','TileSpacing','compact');
nexttile(1)
ax=gca;
histogram(reshape(eyesX{nH+1,sub},[],1),xEd,'Normalization','pdf')
xlim([-500 500])
% ylim([0,0.008])
xlabel('x-coord')
ylabel('density')
box on; ax.FontSize=font_dim;

nexttile(4)
ax=gca;
[f,xi] = ksdensity(reshape(eyesX{nH+1,sub},[],1));
plot(xi,f,'LineWidth',2)
xlim([-500 500])
% ylim([0,0.008])
xlabel('x-coord')
ylabel('smooth density')
box on; ax.FontSize=font_dim;

nexttile(2,[2,2])
ax=gca;
histogram2(reshape(eyesX{nH+1,sub},[],1),reshape(eyesY{nH+1,sub},[],1),xEd,yEd,'DisplayStyle','tile','ShowEmptyBins','on',...
    'Normalization','countdensity')
colorbar
caxis([0.01,0.3])
xlim([-500 500])
ylim([-300,300])
xlabel('x-coord')
ylabel('y-coord')
title('Both eyes')
box on; ax.FontSize=font_dim;

%% time looking 1-2 - all participants - QUARTILE

figure(40);clf;
set(gcf,'Position',[1 60 1200 600])
tl = tiledlayout(nnH,num_subj,'Padding','none','TileSpacing','compact');
for nH=0:nnH-1
    for sub=1:num_subj
        nexttile(sub+(num_subj)*nH)
        ax=gca;
        hold on

        [~,orderPres]=min([allEvents{nH+1,sub}(:,4),allEvents{nH+1,sub}(:,6)],[],2);
        if TimeInt_go==1
            goT=min(allEvents{nH+1,sub}(:,4),allEvents{nH+1,sub}(:,6));
        elseif TimeInt_go==2
            goT=eventsTime{nH+1,sub}(:,3);
        elseif TimeInt_go==3
            goT=eventsTime{nH+1,sub}(:,4);
        end
        if TimeInt_stop==1
           stopT=mvOn{nH+1,sub}+eventsTime{nH+1,sub}(:,1);
        elseif TimeInt_stop==2
            stopT=mvOff{nH+1,sub}+eventsTime{nH+1,sub}(:,1);
        elseif TimeInt_stop==3
            stopT=eventsTime{nH+1,sub}(:,5);
        end

        TR=nan(length(err_trial{nH+1,sub}),2); % time spent looking right
        for n_t=1:length(err_trial{nH+1,sub})
            ind_int=find((eTime{nH+1,sub}(:,n_t)>goT(n_t))&(eTime{nH+1,sub}(:,n_t)<stopT(n_t)));
            if sum(isnan(eyesX{nH+1,sub}(ind_int,n_t)))>0.2*length(ind_int) || isempty(ind_int) || choice{nH+1,sub}(n_t)==0
                continue
            end
            look=[sum(eyesX{nH+1,sub}(ind_int,n_t)<-borderSaccade),sum(eyesX{nH+1,sub}(ind_int,n_t)>borderSaccade)];
            temp=(choice{nH+1,sub}(n_t)+1)/2;
            if orderPres(n_t)==1 % to check 1st/2nd stim - choice
                temp=1-temp;
            end
            
            TR(n_t,:)=[look(orderPres(n_t))/look(3-orderPres(n_t)),temp];
        end
        % remove outliers
        temp1=~isoutlier(TR(:,1));
        TR=[TR(temp1,1),TR(temp1,2)];
        
        TR_sort=sort(TR(:,1));
        TR_sort=TR_sort(~isnan(TR_sort));

        xEd=[TR_sort(1),TR_sort(floor(length(TR_sort)/4));
            TR_sort(ceil(length(TR_sort)/4)),TR_sort(floor(length(TR_sort)/2));
            TR_sort(ceil(length(TR_sort)/2)),TR_sort(floor(3*length(TR_sort)/4));
            TR_sort(ceil(3*length(TR_sort)/4)),TR_sort(end)];
        
        mm=nan(size(xEd,1),1);
        ss=nan(size(xEd,1),1);
        for i=1:size(xEd,1)
            temp=find(TR(:,1)>=xEd(i,1) & TR(:,1)<=xEd(i,2));
            mm(i)=mean(TR(temp,2));
            ss(i)=std(TR(temp,2));
        end
        xEd_p=log(mean(xEd,2));

        % errorbar(xEd,mm,0.5*ss,'r','Marker','o')
        plot(xEd_p,mm,'Marker','o','Color','b','LineWidth',1.2)
        ylim([0,1])
        xlim([-1.5,1.5])

        if nH==0
            title(subj_name{sub},'FontSize',font_dim)
        end
        if sub~=1
            yticks([])
        end
        if nH<nnH-1
            xticks([])
        end
        if sub==num_subj
            colororder({'k','k'})
            yyaxis right
            ylabel(['nH=',num2str(nH)]);
            yticks([])
        end
        if sub==1&&nH>1
            lgn=legend('Location','northeast');
            lgn.FontSize=font_dim-4;
            lgn.ItemTokenSize=[10,18];   
        end
        box on; ax.FontSize=font_dim;
    end
end
ylabel(tl,'Choose 1st-Stim','Interpreter','latex','FontSize',font_dim+2)
xlabel(tl,'$log(T_1/T_2)$','Interpreter','latex','FontSize',font_dim+2)
title(tl,['From ',TimeInt_go_label,' to ',TimeInt_stop_label,' - Quartile'],'Interpreter','latex','FontSize',font_dim+2)

%% time looking 1-2 - 3 horizons - QUARTILE
figure(41);clf;
set(gcf,'Position',[1 60 400 600])
% tl = tiledlayout(1,nnH,'Padding','none','TileSpacing','compact');
% nexttile
ax=gca;
hold on

for nH=0:nnH-1
    
    mm=nan(num_subj,4);
    ss=nan(num_subj,4);
    xEd_p=nan(num_subj,4);
    
    for sub=1:num_subj
        [~,orderPres]=min([allEvents{nH+1,sub}(:,4),allEvents{nH+1,sub}(:,6)],[],2);
        if TimeInt_go==1
            goT=min(allEvents{nH+1,sub}(:,4),allEvents{nH+1,sub}(:,6));
        elseif TimeInt_go==2
            goT=eventsTime{nH+1,sub}(:,3);
        elseif TimeInt_go==3
            goT=eventsTime{nH+1,sub}(:,4);
        end
        if TimeInt_stop==1
           stopT=mvOn{nH+1,sub}+eventsTime{nH+1,sub}(:,1);
        elseif TimeInt_stop==2
            stopT=mvOff{nH+1,sub}+eventsTime{nH+1,sub}(:,1);
        elseif TimeInt_stop==3
            stopT=eventsTime{nH+1,sub}(:,5);
        end

        TR=nan(length(err_trial{nH+1,sub}),2); % time spent looking right
        for n_t=1:length(err_trial{nH+1,sub})
            ind_int=find((eTime{nH+1,sub}(:,n_t)>goT(n_t))&(eTime{nH+1,sub}(:,n_t)<stopT(n_t)));
            if sum(isnan(eyesX{nH+1,sub}(ind_int,n_t)))>0.2*length(ind_int)
                continue
            end
            look=[sum(eyesX{nH+1,sub}(ind_int,n_t)<-borderSaccade),sum(eyesX{nH+1,sub}(ind_int,n_t)>borderSaccade)];
            temp=(choice{nH+1,sub}(n_t)+1)/2;
            if orderPres(n_t)==1 % to check 1st/2nd stim - choice
                temp=1-temp;
            end
            TR(n_t,:)=[look(orderPres(n_t))/look(3-orderPres(n_t)),temp];
        end
        % remove outliers
        temp1=~isoutlier(TR(:,1));
        TR=[TR(temp1,1),TR(temp1,2)];
        
        TR_sort=sort(TR(:,1));
        TR_sort=TR_sort(~isnan(TR_sort));

        xEd=[TR_sort(1),TR_sort(floor(length(TR_sort)/4));
            TR_sort(ceil(length(TR_sort)/4)),TR_sort(floor(length(TR_sort)/2));
            TR_sort(ceil(length(TR_sort)/2)),TR_sort(floor(3*length(TR_sort)/4));
            TR_sort(ceil(3*length(TR_sort)/4)),TR_sort(end)];
        
        for i=1:size(xEd,1)
            temp=find(TR(:,1)>=xEd(i,1) & TR(:,1)<=xEd(i,2));
            mm(sub,i)=mean(TR(temp,2));
            ss(sub,i)=std(TR(temp,2));
        end
        xEd_p(sub,:)=log(mean(xEd,2));
    end
        yneg = 1.95*std(mm)/size(mm,1);
        ypos = yneg;
        xneg = 1.95*std(xEd_p)/size(xEd_p,1);
        xpos = xneg;
        errorbar(mean(xEd_p),mean(mm),yneg,ypos,xneg,xpos,'r','Marker','o','Color',col(nH+1,:),'DisplayName',['nH=',num2str(nH)])
%         plot(mean(xEd_p),mean(mm),'Marker','o','Color',col(nH+1,:),'LineWidth',1.2,'DisplayName',['nH=',num2str(nH)])
        ylim([0,1])
        xlim([-1.1,1.1])
        box on; ax.FontSize=font_dim;
end
legend
ylabel('Choose 1st-Stim')
xlabel('$log(T_1/T_2)$')
title(['From ',TimeInt_go_label,' to ',TimeInt_stop_label,' - Quartile'])


%% time looking 1-2 - horizons and difficulties - QUARTILE
figure(42);clf;
set(gcf,'Position',[1 60 1200 800])
tl = tiledlayout(3,nnH,'Padding','none','TileSpacing','compact');

for nH=0:nnH-1
    
    for nTe=1:nH+1
    nexttile(nH+1+3*(nTe-1))
    ax=gca;
    hold on
    mm=nan(num_subj,4);
    ss=nan(num_subj,4);
    xEd_p=nan(num_subj,4);
    
    for stimDiff=1:length(binsEdgeDiff)-1

    for sub=1:num_subj
        
        [~,orderPres]=min([allEvents{nH+1,sub}(:,4),allEvents{nH+1,sub}(:,6)],[],2);
        if TimeInt_go==1
            goT=min(allEvents{nH+1,sub}(:,4),allEvents{nH+1,sub}(:,6));
        elseif TimeInt_go==2
            goT=eventsTime{nH+1,sub}(:,3);
        elseif TimeInt_go==3
            goT=eventsTime{nH+1,sub}(:,4);
        end
        if TimeInt_stop==1
           stopT=mvOn{nH+1,sub}+eventsTime{nH+1,sub}(:,1);
        elseif TimeInt_stop==2
            stopT=mvOff{nH+1,sub}+eventsTime{nH+1,sub}(:,1);
        elseif TimeInt_stop==3
            stopT=eventsTime{nH+1,sub}(:,5);
        end

        tr_nTe=nTe:nH+1:length(err_trial{nH+1,sub});
        TR=nan(length(tr_nTe),2); % time spent looking right
        for n_t=tr_nTe
            if TrialDiff{nH+1,sub}(n_t)>binsEdgeDiff(stimDiff) && TrialDiff{nH+1,sub}(n_t)<=binsEdgeDiff(stimDiff+1)
                continue
            end
            ind_int=find((eTime{nH+1,sub}(:,n_t)>goT(n_t))&(eTime{nH+1,sub}(:,n_t)<stopT(n_t)));
            if sum(isnan(eyesX{nH+1,sub}(ind_int,n_t)))>0.2*length(ind_int)
                continue
            end
            look=[sum(eyesX{nH+1,sub}(ind_int,n_t)<-borderSaccade),sum(eyesX{nH+1,sub}(ind_int,n_t)>borderSaccade)];
            temp=(choice{nH+1,sub}(n_t)+1)/2;
            if orderPres(n_t)==1 % to check 1st/2nd stim - choice
                temp=1-temp;
            end
            n_t1=ceil(n_t/(nH+1));
            TR(n_t1,:)=[look(orderPres(n_t))/look(3-orderPres(n_t)),temp];
        end
        % remove outliers
        temp1=~isoutlier(TR(:,1));
        TR=[TR(temp1,1),TR(temp1,2)];
        
        TR_sort=sort(TR(:,1));
        TR_sort=TR_sort(~isnan(TR_sort));

        xEd=[TR_sort(1),TR_sort(floor(length(TR_sort)/4));
            TR_sort(ceil(length(TR_sort)/4)),TR_sort(floor(length(TR_sort)/2));
            TR_sort(ceil(length(TR_sort)/2)),TR_sort(floor(3*length(TR_sort)/4));
            TR_sort(ceil(3*length(TR_sort)/4)),TR_sort(end)];
        

        for i=1:size(xEd,1)
            temp=find(TR(:,1)>=xEd(i,1) & TR(:,1)<=xEd(i,2));
            mm(sub,i)=mean(TR(temp,2));
            ss(sub,i)=std(TR(temp,2));
        end
        xEd_p(sub,:)=log(mean(xEd,2));
        
    end
        yneg = 1.95*std(mm)/size(mm,1);
        ypos = yneg;
        xneg = 1.95*std(xEd_p)/size(xEd_p,1);
        xpos = xneg;
        errorbar(mean(xEd_p),mean(mm),yneg,ypos,xneg,xpos,'r','Marker','o','Color',col_d(stimDiff,:),'DisplayName',['diff=',binsEdgeName{stimDiff}])
%         plot(mean(xEd_p),mean(mm),'Marker','o','Color',col_d(stimDiff,:),'LineWidth',1.2,'DisplayName',['diff=',binsEdgeName{stimDiff}])
%         ax.XScale='log';      
    end
    ylim([0,1])
%     yline(0.5,'k--')
    xlim([-1.2,1.2])
    if nH+1~=nTe
        yticks([])
    else
        ylabel(['nTe=',num2str(nTe)])
    end
    if nTe==1
        title(['nH=',num2str(nH)]);
    end
    if nTe~=nH+1
        xticks([])
    end
    box on; ax.FontSize=font_dim;
    end
end
legend('Location','northwest')
ylabel(tl,'Choose 1st-Stim','Interpreter','latex','FontSize',font_dim+2)
xlabel(tl,'$log(T_1/T_2)$','Interpreter','latex','FontSize',font_dim+2)
title(tl,['From ',TimeInt_go_label,' to ',TimeInt_stop_label,' - Quartile - nTe'],'Interpreter','latex','FontSize',font_dim+2)


%% 