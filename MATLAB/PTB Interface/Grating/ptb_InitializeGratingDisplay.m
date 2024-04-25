function PTB = ptb_InitializeGratingDisplay(screenDistance_in, screenID, diodeRectSize, diodeRectLocation, background)

% Modified from DriftDemo4. Original comments below.
%
% function DriftDemo4([angle=0][, cyclespersecond=1][, freq=1/360][, gratingsize=360][, internalRotation=0])
%
% Display an animated grating, using the new Screen('DrawTexture') command.
% This demo demonstrates fast drawing of such a grating via use of procedural
% texture mapping. It only works on hardware with support for the GLSL
% shading language, vertex- and fragmentshaders. The demo ends if you press
% any key on the keyboard.
%
% The grating is not encoded into a texture, but instead a little algorithm - a
% procedural texture shader - is executed on the graphics processor (GPU)
% to compute the grating on-the-fly during drawing.
%
% This is very fast and efficient! All parameters of the grating can be
% changed dynamically. For a similar approach wrt. Gabors, check out
% ProceduralGaborDemo. For an extremely fast aproach for drawing many Gabor
% patches at once, check out ProceduralGarboriumDemo. That demo could be
% easily customized to draw many sine gratings by mixing code from that
% demo with setup code from this demo.
%
% Optional Parameters:
% 'angle' = Rotation angle of grating in degrees.
% 'internalRotation' = Shall the rectangular image patch be rotated
% (default), or the grating within the rectangular patch?
% gratingsize = Size of 2D grating patch in pixels.
% freq = Frequency of sine grating in cycles per pixel.
% cyclespersecond = Drift speed in cycles per second.
%

% History:
% 3/1/9  mk   Written.

try
   % Make sure this is running on OpenGL Psychtoolbox:
   AssertOpenGL;

   Screen('Preference', 'SkipSyncTests', 1);

   % Initial stimulus parameters for the grating patch:
   PTB.rotateMode = kPsychUseTextureMatrixForRotation;
   
   % Choose screen with maximum id - the secondary display on a dual-display
   % setup for display: not on Bach for some fucking reason
%    screenid = max(Screen('Screens'));
   screenid = screenID;
   
   bg = round(background * 255);
   
   % Open a fullscreen onscreen window on that display, choose a background
   % color of 128 = gray, i.e. 50% max intensity:
   Screen('Preference', 'VisualDebugLevel', 1);
   PTB.win = Screen('OpenWindow', screenid, bg);
   [screenXpixels, screenYpixels] = Screen('WindowSize', PTB.win);
   
   % res is the total size of the patch in x- and y- direction, i.e., the
   % width and height of the mathematical support:
   res = [screenXpixels screenYpixels];
   
   % Make sure the GLSL shading language is supported:
   AssertGLSL;
   
   % Retrieve video redraw interval for later control of our animation timing:
   PTB.ifi = Screen('GetFlipInterval', PTB.win);
   PTB.background = bg;

   R = Screen('Resolution', screenid);
   screenWidth_mm = Screen('DisplaySize', screenid);
   fprintf('Screen width = %d mm\n', round(screenWidth_mm));

   cm_per_pixel = 0.1 * screenWidth_mm / R.width;
   cm_per_degree = screenDistance_in * 2.54 * sin(2*pi/360);

   PTB.degrees_per_pixel = cm_per_pixel / cm_per_degree;

   % Build a procedural sine grating texture for a grating with a support of
   % res(1) x res(2) pixels and a RGB color offset of 0.5 -- a 50% gray.
   PTB.gratingtex = ptb_CreateProceduralSquareGrating(PTB.win, res(1), res(2));

   PTB.useDiodeRect = false;
   
   if diodeRectSize > 0
      PTB.useDiodeRect = true;
      baseRect = diodeRectSize * [0 0 1 1];
      switch diodeRectLocation
         case 'bottomleft'
            x = diodeRectSize/2;
            y = screenYpixels-diodeRectSize/2;
         case 'topleft'
            x = diodeRectSize/2;
            y = diodeRectSize/2;
         case 'topright'
            x = screenXpixels - diodeRectSize/2;
            y = diodeRectSize/2;
         case 'bottomright'
            x = screenXpixels - diodeRectSize/2;
            y = screenYpixels-diodeRectSize/2;
      end
      PTB.diodeRect = CenterRectOnPointd(baseRect, x, y);
   end
   
   Screen('Flip', PTB.win);
   
catch exception
   Screen('CloseAll');
   rethrow(exception);
end

