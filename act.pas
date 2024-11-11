unit act;

Interface
uses LMMTypes, SDL2, util; 

function handleInput(keyPressed: SDL_Keycode; var playerAction: TPlayerAction; french: Boolean = False);
procedure playerMove(velocity: TVelocity; blockBelow: Boolean; playerAction: TPlayerAction);
procedure blockAct (playerAction: TPlayerAction; world: TWorld);

Implementation

procedure handleInput(keyPressed: SDL_Keycode; var playerAction: TPlayerAction; french: Boolean = False);
begin
    //Suivant la touche appuyée on effectue différente action
    if french then
        case keyPressed of // FRENCH LAYOUT
            SDLK_q: 
            begin 
                AddActToArray(playerAction.acts, WALK_LEFT);
            end;
            SDLK_d: 
            begin 
                AddActToArray(playerAction.acts, WALK_RIGHT);
            end;
            SDLK_z: 
            begin 
                AddActToArray(playerAction.acts, JUMP);
            end;
            SDLK_s: 
            begin 
                AddActToArray(playerAction.acts, CROUCH);
            end;
    else
        case keyPressed of // ENGLISH LAYOUT
            SDLK_a: 
            begin 
                AddActToArray(playerAction.acts, WALK_LEFT);
            end;
            SDLK_d: 
            begin 
                AddActToArray(playerAction.acts, WALK_RIGHT);
            end;
            SDLK_w: 
            begin 
                AddActToArray(playerAction.acts, JUMP);
            end;
            SDLK_s: 
            begin 
                AddActToArray(playerAction.acts, CROUCH);
            end;
        end;
    end;
end;

procedure playerMove(var velocity: TVelocity; const blockBelow: Boolean; const playerAction: TPlayerAction);
var i: Integer;
    action: TActs;
begin
    for i:= 0 to length(playerAction.acts) - 1 do
    begin
        action := playerAction.acts[i];
        case action of
            WALK_LEFT: 
            begin
                velocity.x := velocity.x - 1;
            end;
            WALK_RIGHT: 
            begin
                velocity.x := velocity.x + 1;
            end;
            JUMP: 
            begin
                if blockBelow then
                    velocity.y := velocity.y + 10;
            end;
            CROUCH: 
            begin
                //On ne fait rien
            end;
        end;
    end;
end;

procedure blockAct (playerAction: TPlayerAction; var world: TWorld);
begin
    for i := 0 to length(playerActionacts) - 1 do
    begin
        case playerAction.player[i] of
            PLACE_BLOCK: 
            begin
                world.chunks[1].layout[playerAction.selectedBlock.x, playerAction.selectedBlock.y] := 1;
            end;
            REMOVE_BLOCK: 
            begin
                world.chunks[1].layout[playerAction.selectedBlock.x, playerAction.selectedBlock.y] := 0;
            end;
        end;
    end;
end;
end.