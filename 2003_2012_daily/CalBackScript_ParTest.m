file = fopen('SHY.csv');
fgetl(file); %skip header line
dSHY=textscan(file,'%s %f','delimiter',',');
fclose(file);
dSHY{1} = datenum(dSHY{1}, 'mm/dd/yyyy');
dSHY{1} = flipud(dSHY{1}); % reverse array
dSHY{2} = flipud(dSHY{2}); % reverse array
% dSHY(1) is datenum, dSHY(2) is Adjusted close

file = fopen('MDY.csv');
fgetl(file); %skip header line
dMDY=textscan(file,'%s %f','delimiter',',');
fclose(file);
dMDY{1} = datenum(dMDY{1}, 'mm/dd/yyyy');
dMDY{1} = flipud(dMDY{1}); % reverse array
dMDY{2} = flipud(dMDY{2}); % reverse array
% dMDY(1) is datenum, dMDY(2) is Adjusted close

file = fopen('MDY_dividend.csv');
fgetl(file);
dMDYdiv = textscan(file,'%s %f %s','delimiter',',');
fclose(file);
dMDYdiv{1} = datenum(dMDYdiv{3}, 'mm/dd/yyyy');
dMDYdiv(3) = []; % don't care about offer date, just award date
dMDYdiv{1} = flipud(dMDYdiv{1}); % reverse array
dMDYdiv{2} = flipud(dMDYdiv{2}); % reverse array
% dMDYdiv{1} is dividend award date, dMDYdiv{2} is dividend yield amt

file = fopen('SHY_dividend.csv');
fgetl(file);
dSHYdiv = textscan(file,'%s %f %s','delimiter',',');
fclose(file);
dSHYdiv{1} = datenum(dSHYdiv{3}, 'mm/dd/yyyy');
dSHYdiv(3) = []; % don't care about offer date, just award date
dSHYdiv{1} = flipud(dSHYdiv{1}); % reverse array
dSHYdiv{2} = flipud(dSHYdiv{2}); % reverse array
% dSHYdiv{1} is dividend award date, dSHYdiv{2} is dividend yield amt
%---------------------------------------------
% PARAMETERS
%startDate = datenum([2003 5 1 0 0 0]); % equal to startFI
%firstEQ = datenum([2003 10 15 0 0 0]);
nextEQ = firstEQ;
endDate = datenum([2012 12 31 0 0 0]);
initialMoney = 10000;
SINGLE_ANALYSIS = 0;

curDate = startDate;
wealthTS = zeros(ceil(endDate-startDate),3);
idxTS = 1; % next empty position in wealthTS
wealthTS(idxTS,:) = [curDate initialMoney 0]; idxTS=idxTS+1;

% purchase initial fixed income
tmpidx = find(dSHY{1} >= curDate, 1); % first trading day on or after initialDate
curDate = dSHY{1}(tmpidx); %advance time
myval = initialMoney / dSHY{2}(tmpidx); %myval now contains shares of SHY
% set initial key dates
nextFI = datenum(datevec(startDate) + [1 0 0 0 0 0]);
flagEQ = 0; % Am I currently holding the equity stock?
curHolding = dSHY;
curHoldingDiv = dSHYdiv;

while curDate < endDate
    bDivToday = find(curDate == curHoldingDiv{1}, 1); % is there a dividend today? bDivToday is the index
    
   if curDate == nextEQ
       % sell all held SHY shares, buy all MDY shares
       tmpidx = find(dSHY{1} >= curDate, 1); % first trading day on or after today
       % what if there is a dividend between? Very unlikely
       curDate = dSHY{1}(tmpidx); %advance time 
       myval = myval * dSHY{2}(tmpidx); %myval now contains $
       % lag period - just holding cash
       tmpidx = find(dMDY{1} >= curDate, 1); % first trading day on or after today (effectively same day)
       curDate1 = dMDY{1}(tmpidx); %advance time 
       assert(curDate == curDate1,'MDY and SHY sold on different trading days?');
       myval = myval / dMDY{2}(tmpidx); %myval now contains shares of MDY
       
       curHolding = dMDY;
       curHoldingDiv = dMDYdiv;
       nextEQ = datenum(datevec(nextEQ) + [1 0 0 0 0 0]);
       flagEQ = 1;
   elseif curDate == nextFI
       % sell all held MDY shares, buy all SHY shares
       tmpidx = find(dMDY{1} >= curDate, 1); % first trading day on or after today
       % what if there is a dividend between? Very unlikely
       curDate = dMDY{1}(tmpidx); %advance time 
       myval = myval * dMDY{2}(tmpidx); %myval now contains $
       % lag period - just holding cash
       tmpidx = find(dSHY{1} >= curDate, 1); % first trading day on or after today (effectively same day)
       curDate1 = dSHY{1}(tmpidx); %advance time 
       assert(curDate == curDate1,'SHY and MDY sold on different trading days?');
       myval = myval / dSHY{2}(tmpidx); %myval now contains shares of SHY
       
       curHolding = dSHY;
       curHoldingDiv = dSHYdiv;
       nextFI = datenum(datevec(nextFI) + [1 0 0 0 0 0]);
       flagEQ = 0;
   elseif bDivToday
       tmpdiv = myval * curHoldingDiv{2}(bDivToday); % in cash
       tmpidx = find(curDate >= curHolding{1}, 1); % index of first trading day on or after today in my current holding
       myval = myval + tmpdiv / curHolding{2}(tmpidx); % purchase additional shares
   end
   
   % output to time series
   tmpidx = find(curHolding{1} == curDate, 1); % get index of today in dSHY
   if (tmpidx)
       % it's a trading day! We can output something.
       tmpcash = myval * curHolding{2}(tmpidx);
       wealthTS(idxTS,:) = [curDate tmpcash flagEQ]; idxTS=idxTS+1;
   end
   % advance time
   curDate = curDate + 1;
end
wealthTS = wealthTS(1:idxTS-1,:);

if SINGLE_ANALYSIS
    figure;
    hold on;
    plot(wealthTS(1:idxTS-1,1),wealthTS(1:idxTS-1,2)); % plot the data
    % idxEQ = find(wealthTS(1:idxTS-1,3) == 1);
    % idxFI = find(wealthTS(1:idxTS-1,3) == 0);
    %area(wealthTS(idxEQ,1), wealthTS(idxEQ,2),'FaceColor',[.2 .2 .2],'LineStyle','none');
    %area(wealthTS(idxFI,1), wealthTS(idxFI,2),'FaceColor',[.3 .4 .5]);
    %plot(wealthTS(idxEQ,1), wealthTS(idxEQ,2));
    %plot(wealthTS(idxFI,1), wealthTS(idxFI,2),'Color','green');
    toFI = find(wealthTS(1:idxTS-1,3) > [wealthTS(2:idxTS-1,3); 1]); % highlight EQ holding periods
    toEQ = find(wealthTS(1:idxTS-1,3) < [wealthTS(2:idxTS-1,3); 1]);
    for idxEQ = toEQ.'
        idxFI = toFI(find(toFI > idxEQ, 1));
        if isempty(idxFI)
            idxFI = idxTS-1; % no subsequent FI period, just highlight to end
        end
        area(wealthTS(idxEQ:idxFI,1),wealthTS(idxEQ:idxFI,2),'FaceColor',[.3 .4 .5],'LineStyle','none');
        alpha(.2);
    end
    datetick;
    %xlabel('Time');
    ylabel(['Growth of $' initialMoney ' investment']);
    title('Calendar Rotation Historical Performance (dividends reinvested)');
    %legend('Calendar Rotation','SPDR S&P MidCap 400 (MDY)','iShares Barclays 1-3 Year Treasury Bond (SHY)');
    hold off;
end

% Calculate overall return
ret = ((wealthTS(end,2) - wealthTS(1,2))/wealthTS(1,2));
fprintf('Overall Return (final_val-initial_val)/initial_val: %f\n', ret);
duration = (wealthTS(end,1)-wealthTS(1,1));
fprintf('  Duration: %d days\n',duration);
fprintf('    at EQ->FI date %s\n',datestr(startDate,'mm/dd/yy'));
fprintf('    at FI->EQ date %s\n',datestr(firstEQ,'mm/dd/yy'));
ret = ret * 365/duration;   %(1+ret)^(365/duration)-1;
fprintf('  Annualized = Overall * 365/duration: %f\n', ret);
final_annualized_return = ret;

if SINGLE_ANALYSIS
% Calculate return during period invested in EQ
ret = zeros(5,size(toEQ,1));
for i = 1:size(toEQ,1)
    idxEQ = toEQ(i);
    idxFI = toFI(find(toFI > idxEQ, 1));
    if isempty(idxFI)
        idxFI = idxTS-1; % no subsequent FI period, just highlight to end
    end
    ret(:,i) = [
        wealthTS(idxEQ,2);
        wealthTS(idxFI,2);
        wealthTS(idxFI,2) - wealthTS(idxEQ,2);
        wealthTS(idxFI,1)-wealthTS(idxEQ,1);
        (wealthTS(idxFI,2)-wealthTS(idxEQ,2))/wealthTS(idxEQ,2) * 365/(wealthTS(idxFI,1)-wealthTS(idxEQ,1));
    ];
end
format short g
fprintf('EQ period: start; end; gain; duration (days); return (annualized)'); 
display(ret);

% Calculate return during period invested in FI
toFI = [1; toFI];
ret = zeros(5,size(toFI,1));
for i = 1:size(toFI,1)
    idxFI = toFI(i);
    idxEQ = toEQ(find(toEQ > idxFI, 1));
    if isempty(idxEQ)
        idxFI = idxTS-1; % no subsequent FI period, just highlight to end
    end
    ret(:,i) = [
        wealthTS(idxFI,2);
        wealthTS(idxEQ,2);
        wealthTS(idxEQ,2) - wealthTS(idxFI,2);
        wealthTS(idxEQ,1)-wealthTS(idxFI,1);
        (wealthTS(idxEQ,2)-wealthTS(idxFI,2))/wealthTS(idxFI,2) * 365/(wealthTS(idxEQ,1)-wealthTS(idxFI,1));
    ];
end
format short g
fprintf('FI period: start; end; gain; duration (days); return (annualized)'); 
display(ret);

end





if 0
figure;
plot(dMDY{1},dMDY{2});
datetick;
ylabel(['MDY price']);
title('SPDR S&P MidCap 400 (MDY)');

figure;
plot(dSHY{1},dSHY{2});
datetick;
ylabel(['SHY price']);
title('iShares Barclays 1-3 Year Treasury Bond (SHY)');
end