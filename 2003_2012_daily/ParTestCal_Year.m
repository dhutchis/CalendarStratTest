%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vary startDate and firstEQ in increments of years to see the best
% combinations and the variability

base_startDate = datenum([2003 5 1 0 0 0]); % equal to startFI
base_firstEQ = datenum([2003 10 15 0 0 0]);
range_startDate = base_startDate:365:base_startDate+365*4;
%range_firstEQ = base_firstEQ:365:base_firstEQ+365*4;
retMat = zeros(size(range_startDate, 2));
idx_startDate = 1;
    
firstEQ = base_firstEQ;
for startDate = range_startDate
    %idx_firstEQ = 1;
    %for firstEQ = range_firstEQ
        CalBackScript_ParTest;
        retMat(idx_startDate) = final_annualized_return;
        %idx_firstEQ = idx_firstEQ + 1;
    %end
    idx_startDate = idx_startDate + 1;
    firstEQ = firstEQ + 365;
end

maxRet = max(max(retMat));
x=find(retMat == maxRet,1);
fprintf('Max Return of %f \n\tat EQ->FI date %s\n\tat FI->EQ date %s\n',...
    maxRet, datestr(range_startDate(x),'mm/dd/yy'), datestr(base_startDate+365*(x-1),'mm/dd/yy'));

figure;
bar(retMat);
title('Calendar Strategy Annualized Returns varying Transition Dates');
xlabel('Year');
ylabel('Annualized Return');
adj = datenum([2003 5 1 0 0 0]) - datenum([2003 1 1 0 0 0]);
set(gca, 'XTickLabel', datestr(range_startDate - adj,'yyyy'));
