% Clear the workspace and the screen
sca;
close all;
clear;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Here we load in an image from file. This one is a image of rabbits that
% is included with PTB
theImageLocation = [PsychtoolboxRoot 'PsychDemos' filesep...
    'AlphaImageDemo' filesep 'konijntjes1024x768.jpg'];
theImage = imread(theImageLocation);

% Make the image into a texture
imageTexture = Screen('MakeTexture', window, theImage);

% Get the size of the image
[s1, s2, s3] = size(theImage);

% Get the aspect ratio of the image. We need this to maintain the aspect
% ratio of the image when we draw it different sizes. Otherwise, if we
% don't match the aspect ratio the image will appear warped / stretched
aspectRatio = s2 / s1;

% We will set the height of each drawn image to a fraction of the screens
% height
heightScalers = linspace(1, 0.2, 10);
imageHeights = screenYpixels .* heightScalers;
imageWidths = imageHeights .* aspectRatio;

% Number of images we will draw
numImages = numel(heightScalers);

% Make the destination rectangles for our image. We will draw the image
% multiple times over getting smaller on each iteration. So we need the big
% dstRects first followed by the progressively smaller ones
dstRects = zeros(4, numImages);
for i = 1:numImages
    theRect = [0 0 imageWidths(i) imageHeights(i)];
    dstRects(:, i) = CenterRectOnPointd(theRect, screenXpixels / 2,...
        screenYpixels / 2);
end

% Draw the image to the screen, unless otherwise specified PTB will draw
% the texture full size in the center of the screen.
Screen('DrawTextures', window, imageTexture, [], dstRects);

% Flip to the screen
Screen('Flip', window);

% Wait for key press
KbStrokeWait;

% Clear the screen
sca;