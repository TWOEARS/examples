% plotModelPerformance.m

% Function to produce the plots used for Deliverable D.6.2.3, Section 4.2

% compute summary performance
for analysisCase = 1:4

    for modelType = 1 : 11
        eval(['load(''perfStructArray_' num2str(modelType) '_' num2str(analysisCase) '.mat'')'])
        numGroups = length(perfStruct.ConfusionMatrix_mean{3,1});
        m{analysisCase,modelType}(1) = mean(diag(perfStruct.ConfusionMatrix_mean{1,1}{1}));
        c{analysisCase,modelType}(1) = mean(diag(perfStruct.ConfusionMatrix_ci95{1,1}{1}));
        for groupIdx = 1 : numGroups
            m{analysisCase,modelType}(groupIdx+1) = mean(diag(perfStruct.ConfusionMatrix_mean{3,1}{groupIdx}));
            c{analysisCase,modelType}(groupIdx+1) = mean(diag(perfStruct.ConfusionMatrix_ci95{3,1}{groupIdx}));
        end
    end
    
end
save perfStructSummary.mat m c

% if above was already computed and saved to disk, you may load the data with:
% load perfStructSummary.mat

featTypeName = {'M1: All', 'M1b: Best', 'M1c: 95%', 'M2: LDR', 'M3: SPEC', 'M4: VDS', 'M5: LOC', 'M6: no LDR', 'M7: no SPEC', 'M8: no VDS', 'M9: no LOC'};


% compare 4 analysis cases
figure(1)
usedModels = [1, 4:11];
for analysisCase = 1:4
    
    subplot(2,2,5-analysisCase)
    mVec = [];
    cVec = [];
    for modelIdx = 1 : length(usedModels)
        mVec(modelIdx) = m{analysisCase,usedModels(modelIdx)}(1);
        cVec(modelIdx) = c{analysisCase,usedModels(modelIdx)}(1);
    end
    errorbar([1:length(usedModels)],mVec,cVec,'bo')
    line([0 length(usedModels)+1],[75 75],'color','k','lineStyle',':')
    set(gca,'xTick',1:length(usedModels),'xTickLabel',featTypeName(usedModels),'xTickLabelRotation',30)
    axis([0.7 length(usedModels)+0.3 50 100])
    %xlabel('Models')
    ylabel('Model performance [%]')
    switch analysisCase
        case 1
            title({'Data Set 4:'; 'within- & across-group comparisons,'; 'clear & unclear preferences, 206 data points'})
        case 2
            title({'Data Set 3:'; 'within- & across-group comparisons,'; 'clear preferences only, 66 data points'})
        case 3
            title({'Data Set 2:'; 'within-group comparisons,'; 'clear & unclear preferences, 110 data points'})
        case 4
            title({'Data Set 1:'; 'within-group comparisons,'; 'clear preferences only, 50 data points'})
    end
end



% plot per group analysis

for analysisCase = [1 3] %: 4
    switch analysisCase
        case {1,2}
            hypothesesMat = [ ...
                 1  1  1  1  1  1; ... % M1 - all - allF
                 1  1  1  1  1  1; ... % M1b - all - optF
                 1  1  1  1  1  1; ... % M1c - all - 95F
                 1  0  0  0  0  0; ... % M2 - comp - LDR
                 0  1  0  0  0  0; ... % M3 - eq - SPEC
                 0  0  1  0  0  0; ... % M4 - rev - VDS
                 0  0  0  1  0  0; ... % M5 - pos - LOC
                -1  1  1  1  0  0; ... % M6 - all but comp - all but LDR
                 1 -1  1  1  0  0; ... % M7 - all but eq - all but SPEC
                 1  1 -1  1  0  0; ... % M8 - all but rev - all but VDS
                 1  1  1 -1  0  0];    % M9 - all but pos - all but LOC
             %xTickLabel = {'Comp', 'EQ', 'Rev', 'Pos', 'Voc', 'Mix'};
             xTickLabel = {'Compression', 'EQ', 'Reverb', 'Positioning', 'Vocals', 'Mixed'};
        case {3,4}
            hypothesesMat = [ ...
                 1  1  1  1; ... % M1 - all - allF
                 1  1  1  1; ... % M1b - all - optF
                 1  1  1  1; ... % M1c - all - 95F
                 1  0  0  0; ... % M2 - comp - LDR
                 0  1  0  0; ... % M3 - eq - SPEC
                 0  0  1  0; ... % M4 - rev - VDS
                 0  0  0  1; ... % M5 - pos - LOC
                -1  1  1  1; ... % M6 - all but comp - all but LDR
                 1 -1  1  1; ... % M7 - all but eq - all but SPEC
                 1  1 -1  1; ... % M8 - all but rev - all but VDS
                 1  1  1 -1];    % M9 - all but pos - all but LOC
             xTickLabel = {'Comp', 'EQ', 'Rev', 'Pos'};
    end
    for modelType = [1 4:11]
        switch modelType
            case 1 % plot "all" model in all four subplots
                subplotIdxVec = 1:4;
                xOffset = 0;
                markerStr = '*';
                markerSize = 8;
            % M2, M3 not used, thus no case {2,3}
            % next models plot into one of the four subplots, with some x-offset per model
            case 4 % LDR
                subplotIdxVec = 1;
                xOffset = 0.3;
                markerStr = 'o';
                markerSize = 6;
            case 8 % all except LDR
                subplotIdxVec = 1;
                xOffset = 0.15;
                markerStr = 'x';
                markerSize = 9;
            case 5 % SPEC
                subplotIdxVec = 2;
                xOffset = 0.3;
                markerStr = 'o';
                markerSize = 6;
            case 9 % all except SPEC
                subplotIdxVec = 2;
                xOffset = 0.15;
                markerStr = 'x';
                markerSize = 9;
            case 6 % VDS
                subplotIdxVec = 3;
                xOffset = 0.3;
                markerStr = 'o';
                markerSize = 6;
            case 10 % all except VDS
                subplotIdxVec = 3;
                xOffset = 0.15;
                markerStr = 'x';
                markerSize = 9;
            case 7 % LOC
                subplotIdxVec = 4;
                xOffset = 0.3;
                markerStr = 'o';
                markerSize = 6;
            case 11 % all except LOC
                subplotIdxVec = 4;
                xOffset = 0.15;
                markerStr = 'x';
                markerSize = 9;
        end
        
        for subplotIdx = subplotIdxVec
            %subplot(2,2,subplotIdx)
            figure(analysisCase*10+subplotIdx)
            numGroups = size(hypothesesMat,2);
            hold on
            mPlotVec = -1*ones(numGroups,1);
            cPlotVec = zeros(numGroups,1);
            curGroups = find(hypothesesMat(modelType,:) == 1);
            if ~isempty(curGroups)
                % do this construction to deal with the "bug" in errorbar.m
                % that the width of the error boundaries depend on size of
                % input vectors
                mPlotVec(curGroups) = m{analysisCase,modelType}(curGroups+1);
                cPlotVec(curGroups) = c{analysisCase,modelType}(curGroups+1);
            end
            errorbar([1:numGroups]+xOffset, mPlotVec, cPlotVec, ['g' markerStr],'lineWidth',1.5,'markerSize',markerSize,'markerFaceColor','auto')
            mPlotVec = -1*ones(numGroups,1);
            cPlotVec = zeros(numGroups,1);
            curGroups = find(hypothesesMat(modelType,:) == 0);
            if ~isempty(curGroups)
                mPlotVec(curGroups) = m{analysisCase,modelType}(curGroups+1);
                cPlotVec(curGroups) = c{analysisCase,modelType}(curGroups+1);
            end
            errorbar([1:numGroups]+xOffset, mPlotVec, cPlotVec, ['b' markerStr],'lineWidth',1.5,'markerSize',markerSize,'markerFaceColor','auto')
            mPlotVec = -1*ones(numGroups,1);
            cPlotVec = zeros(numGroups,1);
            curGroups = find(hypothesesMat(modelType,:) == -1);
            if ~isempty(curGroups)
                mPlotVec(curGroups) = m{analysisCase,modelType}(curGroups+1);
                cPlotVec(curGroups) = c{analysisCase,modelType}(curGroups+1);
            end
            errorbar([1:numGroups]+xOffset, mPlotVec, cPlotVec, ['r' markerStr],'lineWidth',1.5,'markerSize',markerSize,'markerFaceColor','auto')
        end
    end
    for subplotIdx = 1 : 4
        modelStr1 = featTypeName{1};
        switch subplotIdx
            case 1
                modelStr2 = featTypeName{4};
                modelStr3 = featTypeName{8};
                titleStr = ['Investigated Feature Type: LDR,   Results for Data Set ' num2str(5-analysisCase)];
            case 2
                modelStr2 = featTypeName{5};
                modelStr3 = featTypeName{9};
                titleStr = ['Investigated Feature Type: SPEC,   Results for Data Set ' num2str(5-analysisCase)];
            case 3
                modelStr2 = featTypeName{6};
                modelStr3 = featTypeName{10};
                titleStr = ['Investigated Feature Type: VDS,   Results for Data Set ' num2str(5-analysisCase)];
            case 4
                modelStr2 = featTypeName{7};
                modelStr3 = featTypeName{11};
                titleStr = ['Investigated Feature Type: LOC,   Results for Data Set ' num2str(5-analysisCase)];
        end
        figure(analysisCase*10+subplotIdx)
        hold on
        line([0 8],[50 50],'color','k','lineStyle','--')
        line([0 8],[70 70],'color','k','lineStyle',':')
        line([0 8],[60 60],'color','k','lineStyle',':')
        line([0 8],[25 25],'color','k','lineStyle','-')
        
        fontSize = 11;
        text(1,20,'Colors = Hypotheses','color','k','fontSize',fontSize)
        text(1,15,'- Good performance expected','color','g','fontSize',fontSize)
        text(1,10,'- No expectation','color','b','fontSize',fontSize)
        text(1, 5,'- Bad performance expected','color','r','fontSize',fontSize)
        
        switch analysisCase
            case {1,2}
                xText = 4.5;
            case {3,4}
                xText = 3.3;
        end
        text(xText  ,20,'Symbols = Models','color','k','fontSize',fontSize)
        plot(xText+0.1,15,'b*','lineWidth',1.5,'markerSize',8)
        text(xText+0.2,15,modelStr1,'color','b','fontSize',fontSize)
        plot(xText+0.1,10,'bx','lineWidth',1.5,'markerSize',9)
        text(xText+0.2,10,modelStr3,'color','b','fontSize',fontSize)
        plot(xText+0.1, 5,'bo','lineWidth',1.5,'markerSize',6,'markerFaceColor','b')
        text(xText+0.2, 5,modelStr2,'color','b','fontSize',fontSize)
        
        hold off
        set(gca,'xTick',1:length(xTickLabel),'xTickLabel',xTickLabel)
        axis([0.7 length(xTickLabel)+1 0 100])
        title(titleStr)
        xlabel('Comparison groups')
        ylabel('Model performance [%]')
    end
    
end

