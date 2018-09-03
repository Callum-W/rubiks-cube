%This function creates a virtual Rubik's cube which functions like a real
%Rubik's cube.  The cube will render and scramble itself and then ask you
%if you would like to solve it yourself, if you select no, it will proceed
%to solve itself, allowing you to use the cube in a solved state.

%%Written by Callum Wood - 02/06/2015
function RubiksV1()

close all



%#                             STEP 1

% CREATES A VECTOR OF COLOUR NUMBERS
colourVec = [ [1 0.9 0]; ...       %yellow
              [.99 .99 .99]; ...   %white
              [0.8 0.05 0.2]; ...  %red
              [0.99 0.41 0]; ...   %orange              
              [0 0.23 0.88]; ...   %blue
              [0 0.6 0.25];...
              [1 0 1];...
              [0 1 1];...
              [0 0 0] ]; ...    %green
              
              
%The colours for the faces were tweaked until they displayed the same
%colour as the faces on my personal Rubik's cube.





%#                              STEP 2

% CREATES THE STRUCTURE "FACES" WHICH HOLDS THE INFO OF THE CUBE
faces = createCubeInfo();





%#                              STEP 3

% PLOT THE CUBE

%It uses the structure "faces" which holds the info for the position and
%colour of the squares and colourVec which holds the colour information for
%the program and then creates the cube from scratch and plots it.
figure('Name','Rubiks''s Solver')
drawCubeFunc(faces,colourVec);





%#                             STEP 4

% ALTERS THE GRAPH FOR BETTER VIEWING
% "axis square" stops the cube from distorting when it is rotated.
%  Line 57 orients the starting viewing position.
%  Line 58-60 removes the axes numbers.
axis square
axis([0 3 0 3 0 3])
set(gca,'XTick',[]);
set(gca,'YTick',[]);
set(gca,'ZTick',[]);





%#                             STEP 5

% SCRAMBLES AND UNSCRAMBLES THE CUBE

    %This code creates a random vector of 30 integers from 1 to 6, and the
    %scrambleAndDraw function uses this vector to call on random faces of
    %the cube to turn.  If the cube isn't going to be manually solved.
scrambleVec = randi(6,30,1);
faces = scrambleAndDraw(faces,colourVec,scrambleVec);
pause(2);

    % This gives the user the option of solving the cube manually or
    % allowing the computer to solve it.  The figure(1) line simply makes
    % the plot come to the front of the screen after tying in the command
    % window
AutoSolve = input('Would you like so solve this yourself? y/n ','s');
    if AutoSolve == 'n';    
        figure(1);
        faces = unscrambleAndDraw(faces,colourVec,scrambleVec);
    end
figure(1)
    




%#                             STEP 5.5

% FIX THE CORRECT AXES FOR THE CUBE
invertCube();
revertCube();




%#                               STEP 6

% SETUP GUI FOR MOTION CONTROLS
createGui(faces,colourVec);




end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%#                       LIST OF SUB FUNCTIONS





%#                       THE BRAIN OF IT ALL

%%CREATES A STRUCTURE TO STORE ALL INFORMATION THAT THE CUBE NEEDS
function [faces] = createCubeInfo()
%This function is creating the information for the entire cube.  Nothing is
%plotted or drawn, but this info allows that to happen in later functions.
%The numbers of each face are stored, then a 3x3 vector of the same number
%as the face is then stored.  Then the text file that stores information
%about the adjoining edges to that face is loaded and translated to 3
%seperate fields within the faces structure.


%# STEP 1 - PREALLOCATE MEMORY USE

faces(1:6) = struct('faceNumber',(0),...
    'squareColourNumbers',zeros(3),...
    'baseEdgeNums',zeros(12,1),...
    'adjoiningFaces',zeros(12,1),...
    'adjoiningNums',zeros(12,1));

%This preallocates the faces structures, allowing the numbers to be placed
%into an already created structure, which speeds up the process.

%# STEP 2 - CREATE FACE INFO

ColumnNum = 1:3;

    for faceNum = 1:6;
        
        faces(faceNum).faceNumber = faceNum;
%Sets the faceNumber field in the structure
        faces(faceNum).squareColourNumbers = faceNum * ones(3);
%Creates a 3x3 array of the same number of the faceNumber - this is for
%setting the original colours of the cube
      
            AdjoiningFaces = load('FaceInfo.txt');
%This loads in the text file which stores the locations of the adjoining
%edges.

            faces(faceNum).baseEdgeNums = AdjoiningFaces(:,ColumnNum(1));
            faces(faceNum).adjoiningFaces = AdjoiningFaces(:,ColumnNum(2));
            faces(faceNum).adjoiningNums = AdjoiningFaces(:,ColumnNum(3));
%This converts the 3 columns in the text file into individual fields in
%the structure.


        if faceNum ~=6
            ColumnNum = ColumnNum + 3;
        end
%This extracts columns 4,5,6 for faceNum = 2, and columns 7,8,9 for
% faceNum = 3 etc.

    end

end



%#                        BUILDING THE CUBE

%%DRAWS THE FULL CUBE - IT IS CALLED AFTER ANY CHANGE TO THE CUBE IS MADE
function drawCubeFunc(faces, colourVec)
    for FaceIncrement = 1:6
               drawFaceFunc(faces(FaceIncrement),colourVec);
    end
end
%%DRAWS ONE FACE OF THE CUBE
function drawFaceFunc(face,colourVec)
%This program creates a 3 sets of 3x1 columns to create a whole face.  The
%colour is given by the 3x3 matrix (squareColourNumbers) holding the
%information on which colour should be which, in the faces structure.  a
%and b simply represent two different planes, be it xy, xz, or yz. 

    for a=1:3
        for b=1:3
           
            Colour = face.squareColourNumbers(a,b);

            drawSquareFunc(a-1,b-1,face.faceNumber,Colour,colourVec);
           %(a-1)and(b-1) are used so that the co-ordinates start at 0 in
           %drawSquareFunc
           
        end
    end
end
%%DRAWS ONE SQUARE OF ONE FACE OF THE CUBE
function drawSquareFunc(a,b,faceNumber,colourOfSquare,colourVec)
    
%The different values for aVec and bVec are used to plot squares in the
%correct positions in 3d space.  One value for patch will always be
%[0 0 0 0] or [3 3 3 3] because each plane is only a 2D shape, and so those
%vectors simply point to the position in the 3rd plane.

%The text function writes text onto the plot, this is extremely helpful to
%determine which squares link up to other squares by giving each square a
%number based on the draw order.  The numbers are the face and the square
%number, e.g. 3.6 is the 6th square on the 3rd face.  3a+b+1 determines the
%square number from the co-ordinates that are used, and by using aVec + 0.5
%and bVec +0.5, it allows the number to be displayed in the middle of the
%square instead of the corner.
       
    if faceNumber == 1
        %Creates the co-ordinates of face 1
        aVec = [a a a+1 a+1];
        bVec = [b b+1 b+1 b];        
        patch(aVec,bVec,[0 0 0 0], colourVec(colourOfSquare,:));
        
        %%Adds the text of the number of the square
        %descriptionString = sprintf('%d.%d',faceNumber,3*a+b+1);
        %text( aVec(1)+0.5,bVec(1)+0.5,0,descriptionString); 

    elseif faceNumber == 2
        %Creates the co-ordinates of face 2 - opposite face 1
        aVec = [2-a 2-a 2-(a-1) 2-(a-1)];
        bVec = [b b+1 b+1 b];         
        patch(aVec,bVec,[3 3 3 3], colourVec(colourOfSquare,:));
        
        %%Adds the text of the number of the square
        %descriptionString = sprintf('%d.%d',faceNumber,3*a+b+1);
        %text( aVec(1)+0.5,bVec(1)+0.5,3,descriptionString);

    elseif faceNumber == 3
         %Creates the co-ordinates of face 3
        aVec = [a a a+1 a+1];
        bVec = [b b+1 b+1 b];         
        patch(aVec, [0 0 0 0], bVec, colourVec(colourOfSquare,:));
        
        %%Adds the text of the number of the square
        %descriptionString = sprintf('%d.%d',faceNumber,3*a+b+1);
        %text( aVec(1)+0.5,0,bVec(1)+0.5,descriptionString);

    elseif faceNumber == 4
        %Creates the co-ordinates of face 4 - opposite face 3
        aVec = [a a a+1 a+1];
        bVec = [2-b 2-(b-1) 2-(b-1) 2-b];         
        patch(aVec, [3 3 3 3], bVec, colourVec(colourOfSquare,:));
        
        %%Adds the text of the number of the square
        %descriptionString = sprintf('%d.%d',faceNumber,3*a+b+1);
        %text( aVec(1)+0.5,3,bVec(1)+0.5,descriptionString);

    elseif faceNumber == 5
         %Creates the co-ordinates of face 5
        aVec = [a a+1 a+1 a];
        bVec = [b b b+1 b+1];        
        patch([0 0 0 0], bVec, aVec, colourVec(colourOfSquare,:));
        
        %%Adds the text of the number of the square
        %descriptionString = sprintf('%d.%d',faceNumber,3*a+b+1);
        %text( 0,aVec(1)+0.5,bVec(1)+0.5,descriptionString);

    elseif faceNumber == 6
        %Creates the co-ordinates of face 6 - opposite face 5
        aVec = [2-a 2-a 2-(a-1) 2-(a-1)];
        bVec = [b b+1 b+1 b];        
        patch([3 3 3 3], bVec, aVec, colourVec(colourOfSquare,:));
        
        %%Adds the text of the number of the square
        %descriptionString = sprintf('%d.%d',faceNumber,3*a+b+1);
        %text( 3,aVec(1)+0.5,bVec(1)+0.5,descriptionString);

    end         
    
end



%#                      THE ROTATION FUNCTIONS

%%ROTATES A FACE OF THE CUBE CLOCKWISE
function [modifiedFaces] = rotateFaceClockwise(FaceToRotate, faces)
    %Step 0:
    modifiedFaces = faces;

    % Step 1: Rotate the actual face colours
  
    
%Faces number 1 and 2 rotate the opposite way to the other faces, and so a
%switch was created to change the direction of rotation for faces 1 & 2 to
%correct for this.

    switch FaceToRotate
        case 1 
            rotations = 3;
        case 2
            rotations = 3;
        otherwise
            rotations = 1;
    end
    
    
 %This rotates the colours of the face clockwise and then saves the output
 %to the modifiedFaces structure.
    modifiedFaces(FaceToRotate).squareColourNumbers = ...
        rot90(faces(FaceToRotate).squareColourNumbers,rotations);

   
%Step 2: Rotate the adjoining colours   
    for adjoiningSquare = 1:12
        oldPositionNum = adjoiningSquare;
        newPositionNum = mod(adjoiningSquare+3,12);
        
        if newPositionNum == 0
            newPositionNum =12;
        end
       
%This function starts with old num as 1 and new num as 4.  It then changes
%adjoiningFaces(1) to adjoiningFaces(4).
       
        
        oldFace = faces(FaceToRotate).adjoiningFaces(oldPositionNum);
        oldSquare = faces(FaceToRotate).adjoiningNums(oldPositionNum);
        newFace = faces(FaceToRotate).adjoiningFaces(newPositionNum);
        newSquare = faces(FaceToRotate).adjoiningNums(newPositionNum);
        
        oldRow = floor((oldSquare-1)/3)+1;
        oldCol = rem((oldSquare-1),3)+1;
        newRow = floor((newSquare-1)/3)+1;
        newCol = rem((newSquare-1),3)+1;
        
        
%The last section of this program uses oldRow, oldCol, newRow, and newCol
%to translate the position of the old square of the squareColourNumbers to
%the position of the newSquare of the squareColourNumbers.  This makes the
%actual colour change which simulates the rotations of the adjoining faces.

        modifiedFaces(oldFace).squareColourNumbers(oldRow,oldCol) = ...
            faces(newFace).squareColourNumbers(newRow,newCol);
        
     
    end

end
%%ROTATES A FACE OF THE CUBE ANTI CLOCKWISE
function [faces] = rotateFaceAntiClockwise(NUM, faces)
    faces = rotateFaceClockwise(NUM, faces);
    faces = rotateFaceClockwise(NUM, faces);
    faces = rotateFaceClockwise(NUM, faces);
end



%#                     SCRAMBLING / UNSCRAMBLING

%%SCRAMBLES THE CUBE
function [faces] = scrambleAndDraw(faces,colourVec,scrambleVec)
    for ScrambleRange = 1:length(scrambleVec)
        
        axis square
% This stops the cube from being distorted when the viewpoint is
% rotated
            axis([0 3 0 3 0 3])
%This sets the viewpoint that the cube is originally displayed
            set(gca,'XTick',[]);
            set(gca,'YTick',[]);
            set(gca,'ZTick',[]);
%These 3 lines remove the numbers an the axis, making the plot essentially
%just a floating cube
                
        faces = rotateFaceClockwise(scrambleVec(ScrambleRange),faces);
%This line rotates a random face clockwise once.  ScrambleVec is a vector
%of random integers between 1 and 6 and so the rotateFaceClockwise function
%gets given a face number from scrambleVec and then runs the rotates.  This
%ensures that a randomised scramble is achieved at the start of the
%program.
        drawCubeFunc(faces,colourVec);
        pause(0.1)
%After each turn, this function draws the new position of the cube by
%re-drawing.  It pauses for half of a second and then completes the next
%turn.
    end
  
   
    title('Scrambled');
    
end
%%UNSCRAMBLES THE CUBE
function [faces] = unscrambleAndDraw(faces,colourVec,scrambleVec)

%This function is the same as the scrambleAndDraw function except the
%Scramble range starts from the end of ScrambleVec, and works its way down
%to the begining, essentially reversing the moves that scrambleAndDraw
%made.

    for ScrambleRange = length(scrambleVec):-1:1
        
        axis square
            axis([0 3 0 3 0 3])
            set(gca,'XTick',[]);
            set(gca,'YTick',[]);
            set(gca,'ZTick',[]);           
            
%bong on
            faces = rotateFaceAntiClockwise(scrambleVec(ScrambleRange),faces);        
        drawCubeFunc(faces,colourVec);
        pause(0.2)
                
    end
    
    drawCubeFunc(faces,colourVec);
    title('Unscrambled');
end



%#                        FLIPPING THE CUBE

%%FLIPS THE CUBE UPSIDE DOWN BY FLIPPING THE AXIS OF THE GRAPH
function invertCube(~,~)
%The tilde in the input replaced (object_handle,event), Matlab told me that
%they weren't needed and to just use the tilde key.

%This function reverses all of the axis which essentially turns the cube
%upside down.  This is an important feature in solving a rubiks cube, and
%Matlab doesn't allow complete 360 degree rotation in the plot.

%This needs to be called before the user starts controlling the
%cube otherwise the axes will load incorrectly and cause the rotations to
%happen the opposite way.

set(gca,'zdir','reverse')
set(gca,'ydir','reverse')
set(gca,'xdir','reverse')

end
%%RETURNS THE CUBE TO THE ORIGINAL ORIENTATION
function revertCube(~,~)
%The tilde in the input replaced (object_handle,event), Matlab told me that
%they weren't needed and to just use the tilde key.

%This simply turns the axes back to their normal orientation, re flipping
%the cube after it has been inverted.

%This needs to be called before the user starts controlling the
%cube otherwise the axes will load incorrectly and cause the rotations to
%happen the opposite way.

set(gca,'zdir','normal')
set(gca,'ydir','normal')
set(gca,'ydir','normal')

end



%#                      GUI RELATED FUNCTIONS

% CREATES THE GUI
function createGui(faces,colourVec)

%After the code is scrambled and ready to go, there needs to be a way that
%the user can interact with the cube.  Therefore a simple gui needed to be
%created for this to work.

   figureHandle = figure(1);
    setappdata(figureHandle,'faces',faces);
    
    
    %%Creates a pop up UI on the graph to rotate a side clockwise
    rotateDropDownACW = uicontrol('Style', 'popup',...
               'String', {'Yellow','White','Red','Orange','Blue','Green'},...
               'Position', [20 340 100 50],...
               'Callback', {@rotACW,colourVec});
    %%Adds a title to the UI popup       
    txt = uicontrol('Style','text',...
                'Position',[20 395 100 18],...
                'String','Rotate ACW');                  
            
                         
    %%Creates a pop up UI on the graph to rotate a face anti clockwise        
    rotateDropDownCW = uicontrol('Style', 'popup',...
           'String', {'Yellow','White','Red','Orange','Blue','Green'},...
           'Position', [430 340 100 50],...
           'Callback', {@rotCW,colourVec});
    %%Adds a title to the UI popup 
    txt = uicontrol('Style','text',...
            'Position',[430 395 100 18],...
            'String','Rotate CW');
    
        
    % Create a push button to flip the cube to the top (white)
    upFlipBtn = uicontrol('Style', 'pushbutton',...
        'String', 'Flip cube up',...
        'Position', [10 55 80 20],...
        'Callback', {@revertCube});  
    
    % Create a push button to flip the cube to the bottom (yellow)
    dwnFlipBtn = uicontrol('Style', 'pushbutton',...
        'String', 'Flip cube down',...
        'Position', [10 30 80 20],...
        'Callback', {@invertCube}); 

    
end

%%CONNECTS THE ROTATION FUNCTIONS TO THE GUI
function rotCW(source,~,colourVec)
% ~ can be used instead of callbackdata 

%This function gives the pop up GUI the information to allow it to rotate
%the designated face clockwise.  It calls on the actual function
%rotateFaccClockwise to do the move, this function just allows that
%function to be controlled by the popup.



    faceToRotate = source.Value;
%This sets faceToRotate equal to the source value. This value is the choice
%of face colour that is made in the gui.

    faces = getappdata(source.Parent,'faces');
%This gets the position of the faces of the cube that was set in the main
%function.

    faces = rotateFaceClockwise(faceToRotate,faces);
    drawCubeFunc(faces,colourVec);
    setappdata(source.Parent,'faces',faces);
%The above 3 lines call on the function that rotates the cube, it then
%draws the cube again in its new position and sets that same position to
%be the new original point using "setappdata", this allows multiple moves
%to be made in sequence by overwriting the last position with the position
%after the move.

end
function rotACW(source,~,colourVec)
% ~ can be used instead of callbackdata 

%This funciton behaves the exact same way as rotCW however it feeds in to
%a different pop up and calls on the rotateFaceAntiClockwise function
%instead of the clockwise function.

    faceToRotate = source.Value;
    faces = getappdata(source.Parent,'faces');
    faces = rotateFaceAntiClockwise(faceToRotate,faces);
    drawCubeFunc(faces,colourVec);
    setappdata(source.Parent,'faces',faces);
end





%%THE END - I HOPE MY CODE HAS BEEN AN INTERESTING READ

%%SINCERELY - CALLUM WOOD




