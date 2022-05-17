% Clear the workspace
close all
clear
sca;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Skip sync tests for this demo in case people are using a defective
% system. This is for demo purposes only.
Screen('Preference', 'SkipSyncTests', 2);

% Find the screen to use for display
screenid = max(Screen('Screens'));

% Initialise OpenGL
InitializeMatlabOpenGL;

% Open the main window with multi-sampling for anti-aliasing
[window, windowRect] = PsychImaging('OpenWindow', screenid, 0, [], 32, 2, [], 6,  []);

% Start the OpenGL context (you have to do this before you issue OpenGL
% commands such as we are using here)
Screen('BeginOpenGL', window);

% For this demo we will assume our screen is 30cm in height. The units are
% essentially arbitary with OpenGL as it is all about ratios. But it is
% nice to define things in normal scale numbers
ar = windowRect(3) / windowRect(4);
screenHeight = 30;
screenWidth = screenHeight * ar;

% Enable lighting
glEnable(GL.LIGHTING);

% Define a local light source
glEnable(GL.LIGHT0);

% Enable proper occlusion handling via depth tests
glEnable(GL.DEPTH_TEST);

% Lets set up a projection matrix, the projection matrix defines how images
% in our 3D simulated scene are projected to the images on our 2D monitor
glMatrixMode(GL.PROJECTION);
glLoadIdentity;

% Calculate the field of view in the y direction assuming a distance to the
% objects of 100cm
dist = 100;
angle = 2 * atand(screenHeight / dist);

% Set up our perspective projection. This is defined by our field of view
% (here given by the variable "angle") and the aspect ratio of our frustum
% (our screen) and two clipping planes. These define the minimum and
% maximum distances allowable here 0.1cm and 200cm. If we draw outside of
% these regions then the stimuli won't be rendered
gluPerspective(angle, ar, 0.1, 200);

% Setup modelview matrix: This defines the position, orientation and
% looking direction of the virtual camera that will be look at our scene.
glMatrixMode(GL.MODELVIEW);
glLoadIdentity;

% Our point lightsource is at position (x,y,z) == (1,2,3)
glLightfv(GL.LIGHT0, GL.POSITION, [1 2 3 0]);

% Location of the camera is at the origin
cam = [0 0 0];

% Set our camera to be looking directly down the Z axis (depth) of our
% coordinate system
fix = [0 0 -100];

% Define "up"
up = [0 1 0];

% Here we set up the attributes of our camera using the variables we have
% defined in the last three lines of code
gluLookAt(cam(1), cam(2), cam(3), fix(1), fix(2), fix(3), up(1), up(2), up(3));

% Set background color to 'black' (the 'clear' color)
glClearColor(0, 0, 0, 0);

% Clear out the backbuffer
glClear;

% Change the light reflection properties of the material to blue. We could
% force a color to the cubes or do this.
glMaterialfv(GL.FRONT_AND_BACK,GL.AMBIENT, [0.0 0.0 1.0 1]);
glMaterialfv(GL.FRONT_AND_BACK,GL.DIFFUSE, [0.0 0.0 1.0 1]);

% Setup the positions of the spheres using the mexhgrid command
[cubeX, cubeY] = meshgrid(linspace(-25, 25, 10), linspace(-20, 20, 8));
[s1, s2] = size(cubeX);
cubeX = reshape(cubeX, 1, s1 * s2);
cubeY = reshape(cubeY, 1, s1 * s2);

% Draw all the cubes
for i = 1:1:length(cubeX)

    % Push the matrix stack
    glPushMatrix;

    % Translate the cube in xyz
    glTranslatef(cubeX(i), cubeY(i), -dist);

    % Rotate the cube randomly in xyz
    glRotatef(rand * 360, 1, 0, 0);
    glRotatef(rand * 360, 0, 1, 0);
    glRotatef(rand * 360, 0, 0, 1);

    % Draw the solid cube
    glutSolidCube(3);

    % Pop the matrix stack for the next cube
    glPopMatrix;

end

% End the OpenGL context now that we have finished
Screen('EndOpenGL', window);

% Show rendered image at next vertical retrace
Screen('Flip', window);

% Wait for keyboard press
KbWait;

% Shut the screen down
sca;
close all;
clear all;