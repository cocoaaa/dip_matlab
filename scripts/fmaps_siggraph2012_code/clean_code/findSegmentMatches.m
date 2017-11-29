function [segMatches,resid,Conf,candidates] = findSegmentMatches(mesh1, basis1, mesh2, basis2, numSegMatches, segMatchesIn);
if nargin < 6
    segMatchesIn = zeros(0,2);
end

% Return numSegMatches of matching segments
% Check numCheckMatch for each segment candidate

% Build confusion matrix for the segments
numTimes = 100;
Conf = segWksConfusion(mesh1, mesh2, numTimes);
thresh = mean(mean(Conf))/10;
segMatches = zeros(numSegMatches,2);

% Ignore input matches 
nm = size(segMatchesIn,1);
for i=1:nm
    Conf(segMatchesIn(i,1),:) = max(max(Conf));
    Conf(:,segMatchesIn(i,2)) = max(max(Conf));
end

segMatches(1:nm,:) = segMatchesIn;

% Precompute pseudo inv for speeding things up
basis1i = pinv(basis1);
basis2i = pinv(basis2);

% Add the rest of the matches
m = nm+1;
while m <= numSegMatches
    [ii,jj] = find(Conf < thresh);
    if isempty(ii)
        thresh = thresh*2;
        continue;
    end
    resids = zeros(length(ii),1);
    % Check residuals 
    for k=1:length(ii)
        i = ii(k); j = jj(k);
        segMatches(m,:) = [i,j];
        fprintf('%d: (%d,%d) checking residuals ... ',m,i,j);
        t = tic;
        resids(k) = testSegMatch(mesh1, basis1, basis1i, mesh2, basis2, basis2i, segMatches(1:m,:));
        fprintf('%g, %g sec\n',resids(k), toc(t));
    end
    % save list of sorted candidates
    [~,sr] = sort(resids);
    if m == 1
        candidates = [ii(sr),jj(sr)];
    end
    % pick smallest residual
    i = ii(sr(1)); j = jj(sr(1));
    segMatches(m,:) = [i,j];
    Conf(i,:) = max(max(Conf)); Conf(:,j) = max(max(Conf));
    m = m+1;
end

resid = resids(sr(1));


function [Conf,swks1,swks2] = segWksConfusion(mesh1, mesh2, numTimes)
swks1 = segWks(mesh1,numTimes);
swks2 = segWks(mesh2,numTimes);
Conf = squareform(pdist([swks1;swks2]));
Conf = Conf(1:size(swks1,1),size(swks1,1)+1:end);

function swks = segWks(mesh, numTimes)
numSegs = max(mesh.segmentation);
wks = waveKernelSignature(mesh, numTimes);
swks = (wks' * segmentIndicators(mesh,[1:numSegs]))';

