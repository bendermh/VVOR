% Jorge Rey Martinez 2021 version 2.0
s = 0;
if isOctave
  pkg load signal
  disp('WARNING: OCTAVE results has not been validated, and could be unaccuracy, specially for saccade analysis & PR score') 
end

question = questdlg('Do you want to read the data from VVOR or from VVORS (suppressed) test?','Select test to read','VVOR','VORS (suppressed)','VVOR');
if strcmp(question,'VORS (suppressed)')
    s = 1;
end
[t,e,h] = read(s);
if isempty(t)
    disp('No data was loaded');
    return
end
analize(t,e,h,s);

%% Saccade analysis will not be more included but files will be maintained for experimental purposes, uncoment next to activate it
% question = questdlg('Do you want to analize saccades?','Extended analysis','YES','NO','NO');
% if strcmp(question,'YES')
%     saccades(t,e,h,s)
% end

