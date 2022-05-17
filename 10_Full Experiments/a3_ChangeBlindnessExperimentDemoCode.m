close all;
clear;
commandwindow;

% Setup PTB with some default values
PsychDefaultSetup(2);

% Seed the random number generator.
rng('shuffle')

% Skip sync tests for demo purposes only
Screen('Preference', 'SkipSyncTests', 2);


%----------------------------------------------------------------------
%                       Screen setup
%----------------------------------------------------------------------

% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 60);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');


%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------

% Interstimulus interval time in seconds and frames
isiTimeSecs = 1;
isiTimeFrames = round(isiTimeSecs/ifi);

% Numer of frames to wait before re-drawing
waitframes = 1;

% How long should the image stay up during flicker in time and frames
imageSecs = 1;
imageFrames = round(imageSecs/ifi);

% Duration (in seconds) of the blanks between the images during flicker
blankSecs = 0.25;
blankFrames = round(blankSecs/ifi);

% Make a vector which shows what we do on each frame
presVector = [ones(1, imageFrames), zeros(1, blankFrames), ...
    ones(1, imageFrames) .* 2, zeros(1, blankFrames)];
numPresLoopFrames = length(presVector);


%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Keybpard setup
spaceKey = KbName('space');
escapeKey = KbName('ESCAPE');
RestrictKeysForKbCheck([spaceKey, escapeKey]);


%----------------------------------------------------------------------
%                      Experimental Image List
%----------------------------------------------------------------------

% Get the image files for the experiment
imageFolder = [cd, '/images/'];
imgList = dir(fullfile(imageFolder, '*.jpg'));
imgList = {imgList(:).name};
numImages = length(imgList);

% Check to see if the number of files is even. This needs to be the case.
isOdd = mod(numImages, 2);
if isOdd == 1
    error('*** Number of files has to be even to procede ***');
end
numTrials = numImages / 2;


%----------------------------------------------------------------------
%                        Condition Matrix
%----------------------------------------------------------------------

% For this demo we have a (1) "disappear" condition and (2) "color change"
% We will call this our "trialType"
trialType = [1, 2];

% Each condition has two examples
numExamples = 2;

% Make a condition matrix
trialLine = repmat(trialType, 1, numExamples);
exampleLine = sort(repmat(1:numExamples, 1, 2));
condMat = [trialLine; exampleLine];

% Shuffle the conditoins
shuffler = Shuffle(1:numTrials);
condMatShuff = condMat(:, shuffler);

% Make a  matrix which which will hold all of our results
resultsMatrix = nan(numTrials, 3);
resultsMatrix(:, 1:2) = condMatShuff';

% Make a directory for the results
resultsDir = [cd, '/Results/'];
if exist(resultsDir, 'dir') < 1
    mkdir(resultsDir);
end


%----------------------------------------------------------------------
%                        Fixation Cross
%----------------------------------------------------------------------

% Screen Y fraction for fixation cross
crossFrac = 0.0167;

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = windowRect(4) * crossFrac;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix, fixCrossDimPix, 0, 0];
yCoords = [0, 0, -fixCrossDimPix, fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;


%----------------------------------------------------------------------
%                      Experimental Loop
%----------------------------------------------------------------------

% Start screen
DrawFormattedText(window, 'Press Space To Begin', 'center', 'center', black);
Screen('Flip', window);
KbWait;

for trial = 1:numTrials

    % Get this trials information
    thisTrialType = condMatShuff(1, trial);
    thisExample = condMatShuff(2, trial);

    % Define the trial type label
    if thisTrialType == 1
        trialTypeLabel = 'colorchange';
    elseif thisTrialType == 2
        trialTypeLabel = 'disappearance';
    end

    % Define the file names for the two pictures we will be alternating
    % between
    imageNameA = ['image', num2str(thisExample), '_', trialTypeLabel, 'A.jpg'];
    imageNameB = ['image', num2str(thisExample), '_', trialTypeLabel, 'B.jpg'];

    % Now load the images
    theImageA = imread([imageFolder, imageNameA]);
    theImageB = imread([imageFolder, imageNameB]);

    % Make the images into textures
    texA = Screen('MakeTexture', window, theImageA);
    texB = Screen('MakeTexture', window, theImageB);

    % Draw a fixation cross for the start of the trial
    Screen('FillRect', window, grey);

    % Draw the fixation cross in white, set it to the center of our screen and
    % set good quality antialiasing
    Screen('DrawLines', window, allCoords, ...
        lineWidthPix, white, [xCenter, yCenter], 2);

    Screen('Flip', window);
    WaitSecs(2);

    % This is our drawing loop
    respMade = 0;
    numFrames = 0;
    frame = 0;
    Priority(topPriorityLevel);
    while respMade == 0

        % Increment the number of frames
        numFrames = numFrames + 1;
        frame = frame + 1;
        if frame > numPresLoopFrames
            frame = 1;
        end

        % Decide what we are showing on this frame
        showWhat = presVector(frame);

        % Draw the textures or a blank frame
        if showWhat == 1
            Screen('DrawTexture', window, texA, [], [], 0);
        elseif showWhat == 2
            Screen('DrawTexture', window, texB, [], [], 0);
        elseif showWhat == 0
            Screen('FillRect', window, grey);
        end

        % Flip to the screen
        if numFrames == 1
            vbl = Screen('Flip', window);
        else
            vbl = Screen('Flip', window, vbl+(waitframes - 0.5)*ifi);
        end

        % Poll the keyboard for the space key
        [keyIsDown, secs, keyCode] = KbCheck(-1);
        if keyCode(KbName('space')) == 1
            respMade = 1;
        elseif keyCode(KbName('ESCAPE')) == 1
            sca;
            disp('*** Experiment terminated ***');
            return
        end

    end

    % Calculate the time it took the person to see the change
    timeTakenSecs = numFrames * ifi;

    % Switch to low priority for after trial tasks
    Priority(0);

    % Bin the textures we used
    Screen('Close', texA);
    Screen('Close', texB);

    % Record this in our results matrix
    resultsMatrix(trial, 3) = timeTakenSecs;

end

% Close the onscreen window
sca
return