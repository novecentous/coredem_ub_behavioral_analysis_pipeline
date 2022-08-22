
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

%% Performance vs Episode

figure(1);clf;
set(gcf,'Position',[1 1 1200 400])
tt = tiledlayout(6,num_subj,'Padding','none','TileSpacing','compact',...
    'TileIndexing','columnmajor');

for sub=1:num_subj
    feedback=cell(6,3);
    errTr=cell(6,3);
    for nH=0:nnH-1
        for order=1:6
            ind=find(OrderTask{nH+1,sub}==order);
            if isempty(ind)
                continue
            end
            extra=mod(length(ind),nH+1);
            ind=ind(1:end-extra);
            errTr{order,1}=err_trial{nH+1,sub}(ind);
            ind1=reshape(errTr{order,1},nH+1,[]);
            ind1=sum(ind1);
            errTr{order,2}=find(ind1);
            ind=ind(nH+1:nH+1:end);
            errTr{order,3}=ind(errTr{order,2})/(nH+1);
            
            feedback{order,1}=Performance{nH+1,sub}(ind);
            feedback{order,2}=nH;
            feedback{order,3}=ind/(nH+1);
        end
    end

    for order=1:6
%         subplot(num_subj,6,(sub-1)*6+order)
        nexttile
        ax=gca;
        hold on
        plot(feedback{order,3},feedback{order,1},'o','Color',col(feedback{order,2}+1,:),...
            'MarkerSize',4,'DisplayName','Perf.')
        plot(errTr{order,3},feedback{order,1}(errTr{order,2}),'k*',...
            'MarkerSize',4,'DisplayName','Err. tr.')
        ylim([-0.1 1.1])
        xlim([0 105])
        yticks([0,1])
        xticks([1 50 100])
%         text(0,0.5,['nH=',num2str(feedback{order,2})])
        
        if sub~=1
            yticks([])
        end
        if order~=6
            xticks([])
            xlabel([])
        end
        box on; ax.FontSize=font_dim;
        if order==1
           title(subj_name{sub},'FontSize',font_dim)
        end
        if sub==num_subj
            colororder({'k','k'})
            yyaxis right
            ylabel(['Ss. ',num2str(order)]);
            yticks([])
        end
%         if sub==num_subj && order==1
%             lgn=legend('Location','northeast','FontSize',font_dim-4);
%             lgn.ItemTokenSize=[10,18];
%         end
    end
end
xlabel(tt,'\bf Episode','Interpreter','latex','FontSize',font_dim+2)
ylabel(tt,'\bf Performance','Interpreter','latex','FontSize',font_dim+2)

% pause(0.5)
% lgn.Position(1)=lgn.Position(1)+0.005;
% lgn.Position(2)=lgn.Position(2)+0.01;

%% decision (psi) : Choice vs Time (episode) with order

figure(2);clf;
set(gcf,'Position',[1 1 1200 900])
tl = tiledlayout(num_subj,6,'Padding','none','TileSpacing','compact');
for sub=1:num_subj
    feedback=cell(6,3);
    errTr=cell(6,2);
    for nH=0:nnH-1
        for order=1:6
            ind=find(OrderTask{nH+1,sub}==order);
            if isempty(ind)
                continue
            end
            extra=mod(length(ind),nH+1);
            ind=ind(1:end-extra);
            errTr{order,1}=err_trial{nH+1,sub}(ind);
            ind1=reshape(errTr{order,1},nH+1,[]);
            ind1=sum(ind1);
            errTr{order,2}=find(ind1);
            temp=nan(300,1);
            temp2=nan(300,1);
            l=0;
            for t=1:nH+1
                ind2=ind(t:nH+1:end);
                errTr{order,3}=ind2(errTr{order,2})/(nH+1);
                temp(l+1:l+length(ind2))=decision{nH+1,sub}(ind2)+2*(t-1);
                temp2(l+1:l+length(ind2))=ind2/(nH+1);
                l=l+length(ind2);
            end
            feedback{order,1}=temp(1:l);
            feedback{order,3}=temp2(1:l);
            feedback{order,2}=nH;
        end
    end

    for order=1:6
        nexttile
        ax=gca;
        hold on
        pl1=plot(feedback{order,3},feedback{order,1},'bo','MarkerSize',3,'DisplayName','Performance');
        pl2=plot(errTr{order,3},feedback{order,1}(errTr{order,2}),'r*','MarkerSize',3,'DisplayName','Error trial');
        yline(1.5)
        yline(3.5)
        ylim([-0.5 5.5])
        xlim([0 105])
%         if order==1
            xticks([1 50 100])
%         else
%             xticks([50 100])
%         end
        
        if sub~=num_subj
            xticks([])
            xlabel([])
        end
        box on; ax.FontSize=font_dim;
        if sub==1
           title(['Session ',num2str(order)],'FontSize',font_dim)
        end
        if order~=1
            yticks([])
        else
            yticks(0:5)
            yticklabels([0,1,0,1,0,1])
            ax.YAxis.FontSize = font_dim-5;
            ylabel('$T_E 1$ - $T_E 2$ - $T_E 3$')
        end
        if order==6
            colororder({'k','k'})
            yyaxis right
            ylabel(subj_name{sub});
            yticks([])
        end
        if sub==1 && order==6
            lgn=legend([pl1,pl2],'Location','northeast','FontSize',font_dim-4);
            lgn.ItemTokenSize=[10,18];
        end
    end
end

xlabel(tl,'\bf Episode','Interpreter','latex','FontSize',font_dim+2)
ylabel(tl,'\bf Choice','Interpreter','latex','FontSize',font_dim+2)

pause(0.5)
lgn.Position(1)=lgn.Position(1)+0.004;
lgn.Position(2)=lgn.Position(2)+0.006;


%% Visual discrimination

% for nH=0 select the second half of the trials (50-100)

binsEdge=[0.78,0.83,0.88,0.93,0.98,1]; % for difficulty
name_d=[0.2,0.15,0.1,0.05,0.01];

figure(3);clf;
set(gcf,'Position',[1 1 1200 600])
tl = tiledlayout(ceil(sqrt(num_subj)),ceil(sqrt(num_subj)),'Padding','none','TileSpacing','compact');
nH=0;

for sub=1:num_subj
    t=1; % trial within episode     
    rt=decision{nH+1,sub}(50+t:nH+1:end);
    dif=TrialDiff{nH+1,sub}(50+t:nH+1:end);
    % remove error trials
    et=err_trial{nH+1,sub}(50+t:nH+1:end);
    nonerr=find(~et);
    rt=rt(nonerr);
    dif=dif(nonerr);

    rt_sections=nan(length(binsEdge)-1,2);
        for i=1:length(binsEdge)-1
            temp=find(dif>binsEdge(i) & dif<=binsEdge(i+1));
            temp1=rt(temp);
            rt_sections(i,:)=[nanmean(temp1) nanstd(temp1)];
        end

    nexttile
    ax=gca;
    hold on 
    errorbar(1-name_d,rt_sections(:,1),rt_sections(:,2)/2,...
            'o','Color',col(t,:),'DisplayName',['T',num2str(t)])
%     disp(['sub=',num2str(sub),', VD=',num2str(rt_sections(end,1))])
    ylim([-0.1 1.1+2*(t-1)])
    yline(1)
    xlim([0.78 1])

%     if sub~=1 % && sub~=5
%         yticks([])
%     end
    if nH==0
        title(subj_name{sub})
    end

    box on; ax.FontSize=font_dim;
%         if sub==1&&nH>0
%             lgn=legend('Location','northwest');
%             lgn.FontSize=font_dim-4;
% %             lgn.Position(1)=lgn.Position(1)+0.2;
%         end  
end


xlabel(tl,'Difficulty','Interpreter','latex','FontSize',font_dim+2)
ylabel(tl,'VD','Interpreter','latex','FontSize',font_dim+2)

%% initial bias phi_0

table_phi0=nan(num_subj*14,5); % 1. phi_0, 2. subj #, 3. nH, 4. block, 5. trial within episode

% for each block select the first n_phi0 episodes
n_phi0=3;

figure(4);clf;
set(gcf,'Position',[1 1 1200 600])
tl = tiledlayout(ceil(sqrt(num_subj)),ceil(sqrt(num_subj)),'Padding','none','TileSpacing','compact');

l=0;
for sub=1:num_subj
    feedback=cell(6,2);
    errTr=cell(6,3);
    for nH=0:nnH-1
        for order=1:6
            ind=find(OrderTask{nH+1,sub}==order);
            if isempty(ind)
                continue
            end
            extra=mod(length(ind),nH+1);
            ind=ind(1:end-extra);
            errTr{order,1}=err_trial{nH+1,sub}(ind);
            ind1=reshape(errTr{order,1},nH+1,[]);
            ind1=sum(ind1,1);
            errTr{order,2}=find(ind1);
            errTr{order,3}=find(TrialDiff{nH+1,sub}(ind)>0.96);
            errTr{order,3}=ceil(errTr{order,3}/(nH+1));
            
            feedback{order,1}=nan(nH+1,1);
            feedback{order,2}=nan(nH+1,1);
            
            noErr=setdiff(1:length(ind),errTr{order,2});
%             noErr=setdiff(noErr,errTr{order,3}); % select this if you want to eliminate the difficult trials
            noErr=noErr(1:n_phi0);
            for t=1:nH+1
                ind2=(noErr-1)*(nH+1)+t;
                ind3=ind(ind2);
                feedback{order,1}(t)=mean(decision{nH+1,sub}(ind3));
                feedback{order,2}(t)=std(decision{nH+1,sub}(ind3));
                
                l=l+1;
                table_phi0(l,:)=[feedback{order,1}(t),sub,nH,order,t];
            end
            feedback{order,3}=nH;
        end
    end
    nexttile
    ax=gca;
    hold on
    for order=1:6
%         subplot(num_subj,6,(sub-1)*6+order)
        
%         errorbar(repmat(order,feedback{order,3}+1,2),feedback{order,1},0.5*feedback{order,2},'bo','MarkerSize',3)
        for t=1:feedback{order,3}+1
            plot(order,feedback{order,1}(t),'Marker',mark{t},'MarkerSize',8,'Color',col(t,:))
        end
        
%         yline(1.5)
%         yline(3.5)
        ylim([0 1])
        xlim([0 7])
%         xticks([50 100])
%         title(['nH=',num2str(feedback{order,2})])
        
%         if order~=1
%             yticks([])
%         else
%             yticks([0.5,2.5,4.5])
%             yticklabels({'T.1','T.2','T.3'})
%         end
        if order==6
            yyaxis right
            ylabel(subj_name{sub},'Color','r');
            yticks([])
        end
        if sub~=num_subj
            xticks([])
            xlabel([])
        end
        box on; ax.FontSize=font_dim;
    end
end

xlabel(tl,'Block','Interpreter','latex','FontSize',font_dim+2)
ylabel(tl,'Initial bias','Interpreter','latex','FontSize',font_dim+2)

%% SAT: MT vs PV
binsEdgeMT=linspace(200,800,11);

figure(5);clf;
set(gcf,'Position',[1 1 1200 600])
tl = tiledlayout(nnH,num_subj,'Padding','none','TileSpacing','compact');
for nH=0:nnH-1
    for sub=1:num_subj
        for t=1:nH+1 % trial within episode
            dif=MT{nH+1,sub}(t:nH+1:end);
            rt=peakVel{nH+1,sub}(t:nH+1:end);
            % remove error trials
            et=err_trial{nH+1,sub}(t:nH+1:end);
            nonerr=find(~et);
            dif=dif(nonerr);
            rt=rt(nonerr);

            rt_sections=nan(length(binsEdgeMT)-1,2);
            for i=1:length(binsEdgeMT)-1
                temp=find(dif>binsEdgeMT(i) & dif<=binsEdgeMT(i+1));
                temp1=rt(temp);
                rt_sections(i,:)=[nanmean(temp1) nanstd(temp1)];
            end

%             subplot(2,3,sub)    
            nexttile(sub+num_subj*nH)
            ax=gca;
            hold on
            errorbar(binsEdgeMT(2:end)-(1+t*0.5)*(binsEdgeMT(2)-binsEdgeMT(1))/2,rt_sections(:,1),rt_sections(:,2)/2,...
                'Marker',mark{t},'LineStyle','none','Color',col(t,:),'DisplayName',['T.',num2str(t)])
        end

        xlim([100 binsEdgeMT(end)])
        ylim([200 3500])
        if sub~=1 % && sub~=5
            yticks([])
        end
        
        box on; ax.FontSize=font_dim;
        if sub==1&&nH>0
            lgn=legend('Location','northwest');
            lgn.FontSize=font_dim-5;
    %             lgn.Position(1)=lgn.Position(1)+0.2;
        end
        if nH==0
            title(subj_name{sub})
        end
        if nH<nnH-1
            xticks([])
        else
            xticks(200:200:600)
        end
    end
    
    if sub==num_subj
        yyaxis right
        ylabel(['nH=',num2str(nH)],'Color','r');
        yticks([])
    end
end
xlabel(tl,'Movement Time','Interpreter','latex','FontSize',font_dim+2)
ylabel(tl,'Peak Velocity','Interpreter','latex','FontSize',font_dim+2)

%% Reaction time

figure(6);clf;
set(gcf,'Position',[1 1 1200 400])
tl = tiledlayout(nnH,num_subj,'Padding','none','TileSpacing','compact');
for nH=0:nnH-1
    for ind_sub=1:num_subj
        sub=ind_sub;
        for t=1:nH+1 % trial within episode     
            rt=RT{nH+1,sub}(t:nH+1:end);
            % remove error trials
            et=err_trial{nH+1,sub}(t:nH+1:end);
            nonerr=find(~et);
            rt=rt(nonerr);
            
            nexttile(ind_sub+num_subj*nH)
            ax=gca;
            hold on
            [f,xi] = ksdensity(rt,'Support',[-500 3000]);
            plot(xi,f,'LineWidth',2,'Color',col(t,:),'DisplayName',['$T_E$',num2str(t)])
        end
        h=xline(0,'k--');
        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
        h=xline(500,'k--');
        h.Annotation.LegendInformation.IconDisplayStyle = 'off';
        xlim([-500 2000])
        ylim([0 0.0038])
        if sub==1
            yticks([0,0.003])
            ax.YAxis.Exponent = 0;
        else
            yticks([])
        end
        
        if nH<nnH-1
            xticks([])
        else
            xticks([-500,500,1500])
        end
        box on; ax.FontSize=font_dim;
        if ind_sub==1&&nH>1
            lgn=legend('Location','northeast');
            lgn.FontSize=font_dim-4;
            lgn.ItemTokenSize=[10,18];   
        end
        if nH==0
            title(subj_name{sub},'FontSize',font_dim)
        end
    end
    if sub==num_subj
        colororder({'k','k'})
        yyaxis right
        ylabel(['nH=',num2str(nH)]);
        yticks([])
    end
end
xlabel(tl,'{\bf Reaction time (ms)}','Interpreter','latex','FontSize',font_dim+2)
ylabel(tl,'\bf Density','Interpreter','latex','FontSize',font_dim+2)

pause(0.5)
lgn.Position(1)=lgn.Position(1)+0.004;
lgn.Position(2)=lgn.Position(2)+0.008;


%% RT vs Difficulty

binsEdge=[0.78,0.83,0.88,0.93,0.98,1]; % for difficulty

figure(7);clf;
set(gcf,'Position',[1 1 1200 600])
tl = tiledlayout(nnH,num_subj,'Padding','none','TileSpacing','tight');
for nH=0:nnH-1
    for sub=1:num_subj
        for t=1:nH+1 % trial within episode
            dif=TrialDiff{nH+1,sub}(t:nH+1:end);
            rt=RT{nH+1,sub}(t:nH+1:end);
            % remove error trials
            et=err_trial{nH+1,sub}(t:nH+1:end);
            nonerr=find(~et);
            dif=dif(nonerr);
            rt=rt(nonerr);

            rt_sections=nan(length(binsEdge)-1,2);
            for i=1:length(binsEdge)-1
                temp=find(dif>binsEdge(i) & dif<=binsEdge(i+1));
                temp1=rt(temp);
                rt_sections(i,:)=[nanmean(temp1) nanstd(temp1)];
            end

%             subplot(2,3,sub)   
            nexttile(sub+num_subj*nH)
            ax=gca;
        %     plot(dif,rt,'rx')
            hold on
        %     plot(binsEdge,200,'ko')
            errorbar(binsEdge(2:end)-(1+t*0.5)*(binsEdge(2)-binsEdge(1))/2,rt_sections(:,1),rt_sections(:,2)/2,...
                'o','Color',col(t,:),'DisplayName',['$T_E$',num2str(t)],'LineWidth',1.5)
        end
        xlim([0.75 1])
        ylim([-200 1400])
        box on; ax.FontSize=font_dim;
        if sub==1&&nH>1
            lgn=legend('Location','northeast','FontSize',font_dim-5);
            lgn.ItemTokenSize=[10,18];
        end
        if nH<nnH-1
            xticks([])
        else
            xticks([0.8,0.9])
        end
        if nH==0
            title(subj_name{sub},'FontSize',font_dim)
        end
        if sub~=1
            yticks([])
        end
    end
    if sub==num_subj
        colororder({'k','k'})
        yyaxis right
        ylabel(['nH=',num2str(nH)]);
        yticks([])
    end
end
xlabel(tl,'\bf Difficulty','Interpreter','latex','FontSize',font_dim+2)
ylabel(tl,'{\bf Reaction time (ms)}','Interpreter','latex','FontSize',font_dim+2)

pause(0.5)
lgn.Position(1)=lgn.Position(1)+0.004;
lgn.Position(2)=lgn.Position(2)+0.008;

%% RT vs Performance
% 
% binsEdge={[-0.1,0.5,1.1]; % for nH=0
%         [-0.1,0.2,0.5,0.8,1.1]; % for nH=1
%         [-0.1,0.2,0.5,0.8,1.1]}; % for nH=2
%     
binsEdge={[-0.1,0.5,1.1]; % for nH=0
        [-0.1,0.5,1.1]; % for nH=1
        [-0.1,0.5,1.1]}; % for nH=2
    
figure(8);clf;
set(gcf,'Position',[1 1 1000 300])
tl = tiledlayout(1,num_subj,'Padding','compact','TileSpacing','tight');
for nH=0:nnH-1
    for sub=1:num_subj
        t=nH+1; % trial within episode
        dif=Performance{nH+1,sub}(t:nH+1:end);
        rt=zeros(size(RT{nH+1,sub}(t:nH+1:end)));
        et=zeros(size(RT{nH+1,sub}(t:nH+1:end)));
        for t1=1:nH+1
            rt=rt+RT{nH+1,sub}(t1:nH+1:end);
            et=et+err_trial{nH+1,sub}(t1:nH+1:end);
        end
        rt=rt/(nH+1);
        % remove error trials
        nonerr=find(~et);
        dif=dif(nonerr);
        rt=rt(nonerr);

        rt_sections=nan(length(binsEdge{nH+1})-1,2);
        for i=1:length(binsEdge{nH+1})-1
            temp=find(dif>binsEdge{nH+1}(i) & dif<=binsEdge{nH+1}(i+1));
            temp1=rt(temp);
            rt_sections(i,:)=[nanmean(temp1) nanstd(temp1)];
        end
        
        nexttile(sub)
        ax=gca;
        hold on
        errorbar(nH/10+(binsEdge{nH+1}(2:end)+binsEdge{nH+1}(1:end-1))/2,rt_sections(:,1),rt_sections(:,2)/2,...
            'o','Color',col(t,:),'DisplayName',['$n_H$ ',num2str(nH)],'LineWidth',1.5)
%         xline(0.5,'LineStyle','--')
        xlim([-0.1 1.3])
        ylim([-200 1400])
        box on; ax.FontSize=font_dim;
        if nH<nnH-1
            xticks([])
        else
            xticks([0.1,0.9])
            xticklabels({'Low','High'})
        end
        if nH==0
            title(subj_name{sub},'FontSize',font_dim)
        end
        if sub~=1
            yticks([])
        end
        if sub==1
            lgn=legend('Location','southwest','FontSize',font_dim-2);
            lgn.ItemTokenSize=[10,18];
        end
    end
end
xlabel(tl,'\bf Performance','Interpreter','latex','FontSize',font_dim+2)
ylabel(tl,'{\bf Reaction time (ms)}','Interpreter','latex','FontSize',font_dim+2)

%% Movement time
figure(nH+80);clf;
set(gcf,'Position',[1 1 1200 600])
tl = tiledlayout(nnH,num_subj,'Padding','none','TileSpacing','compact');
for nH=0:nnH-1
    for sub=1:num_subj
        for t=1:nH+1 % trial within episode            
            rt=MT{nH+1,sub}(t:nH+1:end);
            % remove error trials
            et=err_trial{nH+1,sub}(t:nH+1:end);
            nonerr=find(~et);
            rt=rt(nonerr);

            
%             subplot(2,3,sub)
            nexttile(sub+num_subj*nH)
            ax=gca;
            hold on 
            plot(nonerr,rt,'Marker',mark{t},'LineStyle','none','Color',col(t,:),'DisplayName',['T.',num2str(t)])
%             plot(find(et),rt(et>0),'kx')            
        end
        ylim([0 1500])
        if sub~=1 % && sub~=5
            yticks([])
        end
        if nH<nnH-1
            xticks([])
        else
            xticks([50,100])
        end
        if nH==0
            title(subj_name{sub})
        end
        
        box on; ax.FontSize=font_dim;
        if sub==1&&nH>0
            lgn=legend('Location','northwest');
            lgn.FontSize=font_dim-4;
%             lgn.Position(1)=lgn.Position(1)+0.2;
        end
    end
    if sub==num_subj
        yyaxis right
        ylabel(['nH=',num2str(nH)],'Color','r');
        yticks([])
    end
    xlabel(tl,'Episode','Interpreter','latex','FontSize',font_dim+2)
    ylabel(tl,'Movement time','Interpreter','latex','FontSize',font_dim+2)
end

%% Peak velocity
figure(9);clf;
set(gcf,'Position',[1 1 1200 600])
tl = tiledlayout(nnH,num_subj,'Padding','none','TileSpacing','tight');
for nH=0:nnH-1
    for sub=1:num_subj
        for t=1:nH+1 % trial within episode     
            rt=peakVel{nH+1,sub}(t:nH+1:end);
            % remove error trials
            et=err_trial{nH+1,sub}(t:nH+1:end);
            nonerr=find(~et);
            rt=rt(nonerr);

%             subplot(2,3,sub)
            nexttile(sub+num_subj*nH)
            ax=gca;
            hold on 
            plot(nonerr,rt,'Marker',mark{t},'LineStyle','none','Color',col(t,:),'DisplayName',['T.',num2str(t)])
%             plot(find(et),rt(et>0),'kx')
        end
        ylim([0 4000])
        if sub~=1 %&& sub~=5
            yticks([])
        end
        if nH<nnH-1
            xticks([])
        else
            xticks([50,100])
        end
        if nH==0
            title(subj_name{sub})
        end

        box on; ax.FontSize=font_dim;
        if sub==1&&nH>0
            lgn=legend('Location','northwest');
            lgn.FontSize=font_dim-4;
%             lgn.Position(1)=lgn.Position(1)+0.2;
        end 
    end
    if sub==num_subj
        yyaxis right
        ylabel(['nH=',num2str(nH)],'Color','r');
        yticks([])
    end
    xlabel(tl,'Episode','Interpreter','latex','FontSize',font_dim+2)
    ylabel(tl,'Peak velocity','Interpreter','latex','FontSize',font_dim+2)
end

%% time to Peak Velocity from movement onset 

for nH=0:nnH-1
    figure(nH+90);clf;
    sgtitle(['Horizon=',num2str(nH)])
    for sub=1:num_subj
        for t=1:nH+1 % trial within episode     
            rt=tPeakVel{nH+1,sub}(t:nH+1:end);
            et=err_trial{nH+1,sub}(t:nH+1:end);            

            subplot(2,3,sub)
            hold on 
            plot(rt,'o','Color',col(t,:))
%             plot(find(et),rt(et>0),'kx')
            
            xlabel('Trial')
            ylabel('Time to Peak Velocity')
            ylim([0 600])
            if sub==1&&nH>0
                legend({'Tr 1','Tr 2'},'Location','northwest')
            end
            title(subj_name{sub})
        end
    end
end
%% 