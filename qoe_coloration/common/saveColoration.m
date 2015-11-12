function saveColoration(arrayType, listenerPosition, prediction, sourceTypes, humanLabelFiles)
%saveColoration stores the predicted coloration ratings in the human labels format
%
%   USAGE
%       saveColoration(arrayType, listenerPosition, prediction, sourceTypes, ...
%                      humanLabelFiles)
%
%   INPUT PARAMETERS
%       arrayType           - 'center' or 'linear'
%       listenerPosition    - 'center' or 'offcenter'
%       prediction          - matrix containing coloration rating predicitions
%       sourceTypes         - cell containing names of audio source material
%       humanLabelFiles     - cell containing names of human label files

for ii = 1:length(sourceTypes)
    humanLabels = readHumanLabels(humanLabelFiles{ii});
    fid = fopen(sprintf('evaluation/coloration_%s_%s_%s.csv', ...
                        arrayType, listenerPosition, sourceTypes{ii}), 'w');
    fprintf(fid, '# system, human_label, confidence_interval, model\n');
    for jj = 1:size(humanLabels,1)
        fprintf(fid, '"%s", %5.2f, %5.2f, %5.2f, %5.2f\n', humanLabels{jj,1}, ...
                humanLabels{jj,2}, humanLabels{jj,3}, prediction(ii,jj));
    end
    fclose(fid);
end

% vim: set sw=4 ts=4 et tw=90:
