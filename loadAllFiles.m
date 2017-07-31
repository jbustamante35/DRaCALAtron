function loadAllFiles(currentDirectory);
% Function to load all .m files in current directory

matFiles = dir('*.m');

for i = 1:length(matFiles)
    if strfind(string(matFiles(i).name), 'loadAllFiles.m')
        continue;
    end
    commandString = 'edit ' + string(matFiles(i).name);
    eval(commandString);
end
