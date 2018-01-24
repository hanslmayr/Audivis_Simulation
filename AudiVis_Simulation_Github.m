% This code was used to generate the results shown in a paper by Staudigl & Hanslmayr
% (submitted to JoCN) entitled "Reactivation of neural patterns during memory reinstatement supports encoding specificity"
%
% The code contains a simple memory model to simulate the effects of sensory pattern reactivation on
% memory; This model is a modified version of a related model published in
% Staudigl, T., Vollmar, C., Noachtar, S., & Hanslmayr, S. (2015). Temporal-pattern similarity analysis reveals the beneficial and detrimental effects of context reinstatement on human memory. J Neurosci, 35(13), 5373-5384.
%

%% Generate Patterns for items;

nitems=100;

for n=1:nitems;
    xi=randperm(12);% Generate item (semantic) pattern 
    xsa=randperm(6);% Generate sensory pattern for auditory
    xsv=randperm(6);% Generate sensory patternf for visual
    ii = xi(1:3);
    sia = xsa(1:3);
    siv = xsv(1:3);
    templi = zeros(3,4);
    templsa = zeros(3,2);
    templsv = zeros(3,2);
    templi(ii)=1;
    templsa(sia)=1;
    templsv(siv)=1;
    items_sem(:,:,n) = templi; % Semantic pattern
    items_sensa(:,:,n) = templsa; % Sensory pattern (auditory)
    items_sensv(:,:,n) = templsv; % Sensory pattern (visual)
end

%% Investigate the effects of sensory memory reactivation

cond = 2;% controls whether match or mismatch condition is simulated; set to 1 for match, and 2 for mismatch
basenoise=10;% controls strength of baseline on reactivation patterns; Works best with values [1 ... 10]

% Strength of sensory reactivation - if value is high, encoded sensory patterns are restored with higher fidelity than if value is low
reactvex=[1 10];

% shuffle sensory patterns to create a mismatch between input and 
% reactivation pattern; This is done for mismatch only!
shuff=randperm(nitems); 

for l=1:length(reactvex);  % loop over reactivation strengths
    react=reactvex(l);
    for k=1:nitems;% loop over trials (number of items)
        templi=rand(3,4).*(basenoise/10);% empty template pattern containing just noise (to get away from ceiling)
        Csem=items_sem(:,:,k);% get semantic (item) input
        % get reactivated semantic item, which always overlaps with input pattern
        ritem=Csem;
        iic=find(Csem);% find activated subunits in input item pattern
        iir=find(ritem);% find activated subunits in reactivated item pattern 

        % Generate reactivated semantic (item) pattern with a little bit of noise
        Rsem=templi;
        Rsem(iic)=1;
       
        % Same procedure for auditory sensory pattern ...
        templs=rand(3,4).*(basenoise/10);
        rsens=items_sensa(:,:,k);% Reactivated pattern is always auditory pattern; because we simulate auditory encoding only;
        if cond == 1 % Match
            Csens=[rsens zeros(3,2)];% cue with auditory pattern, which here is the same as the reacivated pattern (=Match)
        else % Mismatch
            Csens=[zeros(3,2) items_sensv(:,:,k)];% cue with visual pattern, which here is a different one than the reactivated pattern (=mismatch)
        end
        sic=find(Csens);
        sir=find(rsens);
        for us=1:length(sir) 
            noises(us)=1-(rand(1,1)./react);% add noise on sensory pattern depending on strength of reactivation; High levels of reactivation --> low noise, low levels of reactivation --> high noise
        end
        Rsens=templs;
        Rsens(sir)=noises;
        % Correlate cue pattern with reactivated pattern; This is done
        % separately for item and sensory patterns ...
        R(k,1)=corr2(Csem,Rsem);
        R(k,2)=corr2(Csens,Rsens);
        Rsens(k,l)=R(k,2);
    end
    % ... and averaged; A mean correlation value accross item and sensory 
    % patterns (i.e. memory performance) is obtained for each trial
    Memper(:,l)=mean(R,2);
end

% calculate statistics and plot results
[H,P]=ttest(Memper(:,1),Memper(:,2))
figure;bar(mean(Memper));axis([0 3 0.7 1]);
hold on
plot([1 2],Memper);axis([0 3 0 1]);
hold off
 
