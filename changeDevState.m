function [devState] = changeDevState(devState, newState)
%gets current and new state of a device, chnages the current state to
%the new one if it legal, and throws exception if not
%   this is a control mechanism to avoid illegal state transitions!

% binary matrix which, there is 1 in cell [i, j] iff the transition i->j is
% legal according to the state machine (of the standard), i and j are 
% enumaraions for the states
legalTransitions = [1,1,0,0,1,1,0,0,1,0; 0,1,1,0,1,1,0,0,1,0; 0,0,1,1,0,0,0,0,0,0; 1,1,0,1,1,1,1,0,1,0; 1,0,0,1,1,1,1,0,0,0; 0,0,0,0,0,1,1,0,0,0; 0,0,0,0,1,1,1,1,1,0; 0,0,1,0,1,1,0,1,1,0; 1,1,0,1,0,1,1,0,1,1; 1,1,0,1,0,1,1,0,0,1];

if(legalTransitions(int32(devState.curState), int32(newState)) == 1)
    % it's OK to change, legal transition!
    devState.curState = newState;
else
    % illegal transition !!!
    illegalTransitionException = MException('MyComponent:noSuchVariable', 'illegalTransitionException!');
    throw(illegalTransitionException);
end

end

