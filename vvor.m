% VVOR new version designed to be used with new vHIT devices using the RAW file as data source

function vvor()
    % Ask the user to select a .txt file
    [file, path] = uigetfile('*.txt', 'Select a test data file');
    if isequal(file, 0)
        disp('❌ Cancelled by user.');
        return;
    end
    fullpath = fullfile(path, file);

    % Read the entire file as text
    fid = fopen(fullpath, 'rt');
    if fid == -1
        errordlg('Could not open the selected file.', 'File Error');
        return;
    end
    rawText = fread(fid, '*char')';
    fclose(fid);

    % Search for <TestUID> markers that indicate the start of a test block
    startIndices = regexp(rawText, '<TestUID>', 'start');
    endIndices = [startIndices(2:end)-1, length(rawText)];
    numTests = length(startIndices);

    if numTests == 0
        errordlg('No tests were found in the file.', 'No Tests Found');
        return;
    end

    % Prepare structure to store extracted test info
    tests = struct();
    options = cell(numTests, 1);

    for i = 1:numTests
        block = rawText(startIndices(i):endIndices(i));

        % Extract metadata using regular expressions
        uid = regexp(block, '<TestUID>(.*?)</TestUID>', 'tokens');
        tipo = regexp(block, '<TestType>(.*?)</TestType>', 'tokens');
        fecha = regexp(block, '<StartDateTime>(.*?)</StartDateTime>', 'tokens');

        uid = uid{1}{1};
        tipo = tipo{1}{1};
        fecha = fecha{1}{1};

        % Extract numeric data lines after <DecimalSeparator>
        lines = strsplit(block, '\n');
        idx = find(~cellfun('isempty', strfind(lines, '<DecimalSeparator>')), 1, 'first');
        dataLines = lines(idx+2:end);
        dataLines = dataLines(~cellfun(@isempty, dataLines));

        % Parse data lines into numeric matrix
        n = length(dataLines);
        data = zeros(n, 9);
        for j = 1:n
            line = strrep(dataLines{j}, ',', '.');
            nums = str2double(strsplit(line, ';'));
            if length(nums) == 9
                data(j, :) = nums;
            end
        end

        % Store test entry
        tests(i).UID = uid;
        tests(i).Type = tipo;
        tests(i).StartDate = fecha;
        tests(i).Data = data;
        options{i} = sprintf("%s | %s", fecha, tipo);
    end

    % Show dialog to let user choose one test
    [selIndex, ok] = listdlg('PromptString', 'Select a test:', ...
        'SelectionMode', 'single', ...
        'ListString', options, ...
        'Name', 'Available Tests', ...
        'ListSize', [600, 300]);  % Increase dialog width

    if ~ok
        disp("❌ Test selection cancelled.");
        return;
    end

    % Get selected test and call the corresponding analysis function
    selected = tests(selIndex);

    if strcmp(selected.Type, 'RVVO — Horizontal')
        rawTime = selected.Data(:, 1);
        t = (rawTime - rawTime(1)) / 10000000;  % Normalize to 0 and convert ms to seconds
        h = selected.Data(:, 2);
        e = selected.Data(:, 3);
        s = 0;
        display(t)
        analizeVOR(t, e, h, s);
    else
        warndlg(sprintf("Test type not supported yet: %s", selected.Type), 'Not Implemented');
    end
end