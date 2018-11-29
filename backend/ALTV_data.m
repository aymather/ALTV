function data = ALTV_data
 
% COLLECT DATA
disp('Welcome to our experiment!');
data.nr = input('Subject Number: ');
data.training = input('Training?: (0/1) ');
data.buttons = input('Buttons? (1/2)  ');
if data.training == 0
    data.age = input('Age? ');
    data.gender = input('Gender? (m/f) ','s');
    data.hand = input('Handedness? (r/l) ','s');
end

% data.nr = 999;
% data.training = 0;
% data.buttons = 1;