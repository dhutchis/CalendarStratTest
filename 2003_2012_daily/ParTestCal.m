%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vary startDate and firstEQ in increments of weeks to see the best
% combinations and the variability

base_startDate = datenum([2003 5 1 0 0 0]); % equal to startFI
base_firstEQ = datenum([2003 10 8 0 0 0]);
range_startDate = base_startDate-14:7:base_startDate+21;
range_firstEQ = base_firstEQ-14:7:base_firstEQ+21;
retMat = zeros(size(range_startDate, 2), ...
                size(range_firstEQ, 2));
idx_startDate = 1;
            
for startDate = range_startDate
    idx_firstEQ = 1;
    for firstEQ = range_firstEQ
        CalBackScript_ParTest;
        retMat(idx_startDate,idx_firstEQ) = final_annualized_return;
        idx_firstEQ = idx_firstEQ + 1;
    end
    idx_startDate = idx_startDate + 1;
end

maxRet = max(max(retMat));
[x,y]=ind2sub(size(retMat),find(retMat == maxRet));
fprintf('Max Return of %f \n\tat EQ->FI date %s\n\tat FI->EQ date %s\n',...
    maxRet, datestr(range_startDate(x),'mm/dd'), datestr(range_firstEQ(y),'mm/dd'));

figure;
bar3(retMat);
title('Calendar Strategy Annualized Returns varying Transition Dates');
xlabel('EQ->FI date');
ylabel('FI->EQ date');
zlabel('Annualized Return');
set(gca, 'XTickLabel', datestr(range_startDate,'mm/dd'));
set(gca, 'YTickLabel', datestr(range_firstEQ,'mm/dd'));
