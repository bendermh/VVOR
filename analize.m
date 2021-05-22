% Jorge Rey Martinez 2021 version 2.0
% Inputs
% t = time array
% e = eye velocity array
% h = head velocity array
% s = Boolean, true if register is supresed VVOR false if VVOR
function analize(t,e,h,s)

%Draw figure considering screen size
scrsz = get(groot,'ScreenSize');

if s == 1
    figure1 = figure('Name','VORS ANALYSIS','NumberTitle','off','Position',[5 50 scrsz(3)/1.01 scrsz(4)/1.2]);
else
    figure1 = figure('Name','VVOR ANALYSIS','NumberTitle','off','Position',[5 50 scrsz(3)/1.01 scrsz(4)/1.2]);
end
figure(figure1);

%%%%%% Numerical data CALCULATIONS section %%%%%%%%%%%%

% Get Desacade eye data
if s == 1
    desacE = medfilt1(e,35);
else
    desacE = medfilt1(e,30);
end

%get positive/neagtive data RAW
limitRaw = size(t);
posHRaw = [];
posERaw = [];
negHRaw = [];
negERaw = [];
for n = 1:limitRaw
    if h(n) >= 0
        posHRaw = vertcat(posHRaw,h(n));
        posERaw = vertcat(posERaw,e(n));
    end
    if h(n) < 0
        negHRaw = vertcat(negHRaw,h(n));
        negERaw = vertcat(negERaw,e(n));
    end
end

%get positive/neagtive data desaccade 
limit = size(t);
posH = [];
posE = [];
negH = [];
negE = [];
for n = 1:limit
    if h(n) > 0
        posH = vertcat(posH,h(n));
        if desacE(n) > 0
            posE = vertcat(posE,desacE(n));
        else
            posE = vertcat(posE,0);
        end
    end
    if h(n) < 0
        negH = vertcat(negH,h(n));
        if desacE(n) < 0
            negE = vertcat(negE,desacE(n));
        else
            negE = vertcat(negE,0);
        end
    end
end

prePosPeakE = mean(findpeaks(posE));
preNegPeakE = mean(findpeaks(abs(negE)));
if prePosPeakE > preNegPeakE
    peakE = prePosPeakE;
    peakH = mean(findpeaks(posH));
else
    peakE = -preNegPeakE;
    peakH = -mean(findpeaks(abs(negH)));
end

%AUC Gain
aucPosEye = trapz(posE);
aucPosHead = trapz(posH);
aucNegEye = trapz(negE);
aucNegHead = trapz(negH);
gainPos = (aucPosEye/aucPosHead);
gainNeg = (aucNegEye/aucNegHead);
%velGainPos = mean(findpeaks(posE))/mean(findpeaks(posH));
%velGainNeg = mean(findpeaks(abs(negE)))/mean(findpeaks(abs(negH)));

%Eye Head Regression Gain
negB = negH\negE;
posB = posH\posE;
calcNegE = negB*negH;
calcPosE = posB*posH;

%Fourier gain
[fHead,P1Head] = fourier(h);
[fEye,P1Eye] = fourier(e);
[fHeadLeft,P1HeadLeft] = fourier(posHRaw);
[fHeadRight,P1HeadRight] = fourier(negHRaw);
[fEyeLeft,P1EyeLeft] = fourier(posERaw);
[fEyeRight,P1EyeRight] = fourier(negERaw);
[maxTestValue,maxTestPos] = max(P1Head);
maxFreqHead = fHead(maxTestPos);
%Find closest frequencies in Left and Right data
[~,idxHLeft]= min(abs(fHeadLeft-maxFreqHead));
freqHeadLeft = fHeadLeft(idxHLeft);
powHeadLeft = P1HeadLeft (idxHLeft);
[~,idxELeft]= min(abs(fEyeLeft-maxFreqHead));
freqEyeLeft = fEyeLeft(idxELeft);
powEyeLeft = P1EyeLeft (idxELeft);
[~,idxHRight]= min(abs(fHeadRight-maxFreqHead));
freqHeadRight = fHeadRight(idxHRight);
powHeadRight = P1HeadRight (idxHRight);
[~,idxERight]= min(abs(fEyeRight-maxFreqHead));
freqEyeRight = fEyeRight(idxERight);
powEyeRight = P1EyeRight (idxERight);
%GainValues
leftFourGain = powEyeLeft/powHeadLeft;
rightFourGain = powEyeRight/powHeadRight;

%%%%% PLOTS SECTION %%%%%

%RAW plot
subplot(3,2,1)
plot(t,h,'b',t,e,'r','LineWidth',1.25)
title('Test Output - RAW data')
xlabel('Time in secs')
ylabel('Velocity in deg/sec')
ylim([-400 +400])
legend ('Head velocity','Eye velocity')
%Desaccaded plot
subplot(3,2,2)
plot(t,h,'b',t,desacE,'r','LineWidth',1.25)
AUCTitle = strcat('Test Output - Desaccaded data  - ',' LEFT GAIN: ',num2str(gainPos),' -RIGHT GAIN: ',num2str(gainNeg));
title(AUCTitle)
xlabel('Time in secs')
ylabel('Velocity in deg/sec')
ylim([-400 +400])
legend ('Head velocity','Eye velocity')

%XY ploy & regresion line
subplot(3,2,6)
hold on
if isOctave
    scatter(negH,negE,'c','.');
    scatter(posH,posE,'b','.');
else
    scatter(negH,negE,'.b');
    scatter(posH,posE,'.','MarkerEdgeColor',[0 .7 .7]);
end
XYTitle = strcat('Head vs Eye plot - Desaccaded data',' LEFT GAIN: ',num2str(posB),' -RIGHT GAIN: ',num2str(negB));
title(XYTitle)
xlabel('Head Velocity in deg/sec')
ylabel('Eye Velocity in deg/sec')
plot(negH,calcNegE,posH,calcPosE,'LineWidth',5)
if s == 1
    plot(negH,negH,'r',posH,posH,'r','LineWidth',1.5)
    legend ('Negative data','Positive data','Negative regresion','Positive regresion','No Suppression line','Location','northwest')
else
    plot(negH,negH,'g',posH,posH,'g','LineWidth',1.5)
    legend ('Negative data','Positive data','Negative regresion','Positive regresion','Normality line','Location','northwest')
end
hold off
%axis square

%Fourier plot
subplot(3,2,3)
hold on
stem(fHead,P1Head,'b');
title('Single-Side Amplitude Spectrum of Head and Eye - RAW data')
xlabel('f (Hz)')
ylabel('|P1(f)|')
xlim([0 5])
stem(fEye,P1Eye,'r');
legend('Head','Eye')
hold off

%Fourier gain plot
subplot(3,2,4)
x = categorical({'Left','Right'});
yGFData = [powHeadLeft powEyeLeft; powHeadRight powEyeRight];
hold on
barFourier = bar(x,yGFData);
labelGainFourier = ['Gain values in Fourier Analysis - ', ' Left gain : ',num2str(leftFourGain),' Right gain: ',num2str(rightFourGain)];
title(labelGainFourier)
xLabelTextFour = ['Left oscillation freq (Hz): ', num2str(freqHeadLeft),' - Right oscillation freq (Hz): ',num2str(freqHeadRight)];
xlabel(xLabelTextFour)
ylabel('|P1(f)|')
legend('Head','Eye')
barFourier(1).FaceColor = 'b';
barFourier(2).FaceColor = 'r';
hold off

%Analysis of head oscillations variability:
distanciaPicos = 60;
lHeadPeaks = findpeaks(posH,'MinPeakDistance',distanciaPicos);
rHeadPeaks = findpeaks(abs(negH),'MinPeakDistance',distanciaPicos);
velocityTreshold = 25;
lHeadInvalids = lHeadPeaks<velocityTreshold;
rHeadInvalids = rHeadPeaks<velocityTreshold;
lHeadPeaks(lHeadInvalids) = [];
rHeadPeaks(rHeadInvalids) = [];
[lPeakN, ~] = size(lHeadPeaks);
[rPeakN, ~] = size(rHeadPeaks);
[lPR,rPR,saccadePositions] = prScoreVVR(t,e,h,s);

%PR PLOT only available in VVOR tests
if s ~= 1
    subplot(3,2,5)
    plot(t,h,'b',t,e,'r','LineWidth',1.5)
    prTitle = strcat('Saccade Recognition & PR Plot: ', '  Left PR:',num2str(lPR),',  Right PR: ',num2str(rPR));
    title(prTitle)
    xlabel('Time in samples')
    ylabel('Velocity in deg/sec')
    ylim([-400 +400])
    %add saccade detection to plot
    [sP,~,~] = find(t==saccadePositions);
    hold on
    plot(t(sP),e(sP),'ko')
    hold off
    legend ('Head velocity','Eye velocity','Detected Saccade')
end


%%%%%%%%%Output analysis results to text%%%%%%%%%%%%

resultG = strcat('Movement data: ',' Head Max(º/s):  ', num2str(peakH),' Eye Max: ',num2str(peakE));
if s~= 1
    resultPR = strcat('PR RESULTS: ',' Left PR Score: ',num2str(lPR),' Right PR score: ',num2str(rPR),' || Left/Right peaks > 25º/s: ',num2str(lPeakN),'/',num2str(rPeakN),' || Left/Right velocity SD of peaks: ',num2str(std(lHeadPeaks)),'/',num2str(std(rHeadPeaks)));
else
    resultPR = 'PR score is not available for VORS - supression - testing';
end
mTextBoxGain = uicontrol(figure1,'style','text');
mTextBoxPR = uicontrol(figure1,'style','text');
set(mTextBoxGain,'String',resultG);
set(mTextBoxGain,'FontSize',10);
set(mTextBoxGain,'HorizontalAlignment','left');
set(mTextBoxGain,'Position',[20 20 1300 25]);
set(mTextBoxPR,'String',resultPR);
set(mTextBoxPR,'FontSize',10);
set(mTextBoxPR,'HorizontalAlignment','left');
set(mTextBoxPR,'Position',[20 1 1600 25]);
set(figure1,'MenuBar','figure');
disp(resultG);
disp(resultPR);
end

