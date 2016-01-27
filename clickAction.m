function clickAction

type = get(gcf, 'SelectionType');
handles = get(gcf, 'UserData');

switch type
    case 'alt'
%         disp('Ouch! I was Control-clicked');
        cp = get(gca, 'CurrentPoint');
        x = cp(1);
        nAvailableFrames = handles.vr.NumberOfFrames;
        iFrame = min(max(1, round(x)), nAvailableFrames);
        set(handles.frameSlider, 'Value', iFrame);
        etGUI('frameSlider_Callback', handles.frameSlider, [], guidata(handles.figure1));
        % handles.figure1 is a handle of the main etGUI figure
    otherwise
%         disp('I was clicked')
end

