unit act;

Interface
uses LMMTypes, SDL2, util, display; 

procedure handleInput(keyPressed: TSDL_Keycode; var playerAction: TPlayerAction; french: Boolean);
procedure handleMouse(x:Integer ; y:Integer; world:TWorld; window:TWindow; action:TActs; var playerAction: TPlayerAction);
procedure playerMove(var velocity: TVelocity; blockBelow: Boolean; playerAction: TPlayerAction);
procedure blockAct(playerAction: TPlayerAction; var world: TWorld); 

Implementation

procedure handleInput(keyPressed: TSDL_Keycode; var playerAction: TPlayerAction; french: Boolean);
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

procedure handleMouse(x:Integer ; y:Integer; world:TWorld; window:TWindow; action:TActs; var playerAction: TPlayerAction);
begin
    playerAction.selectedBlock.x := world.player.pos.x + x div Trunc(SURFACEWIDTH/BLOCKDISPLAYED) - ((window.width div SIZE)-1) div 2;
    playerAction.selectedBlock.y := world.player.pos.y - y div Trunc(SURFACEWIDTH/BLOCKDISPLAYED) + ((window.height div SIZE)-1) div 2;
    AddActToArray(playerAction.acts, action)
end;
procedure playerMove(var velocity: TVelocity; blockBelow: Boolean; playerAction: TPlayerAction);
var i: Integer;
    action: TActs;
begin
    for i:= 0 to length(playerAction.acts) -1 do
    begin
        action := playerAction.acts[i];
        case action of
            WALK_LEFT: 
            begin
                velocity.x := velocity.x - 0.5;
            end;
            WALK_RIGHT: 
            begin
                velocity.x := velocity.x + 0.5;
            end;
            JUMP: 
            begin
                if blockBelow then
                    velocity.y := velocity.y + 1;
            end;
            CROUCH: 
            begin
                //On ne fait rien
            end;
        end;
    end;
end;

procedure blockAct(playerAction: TPlayerAction; var world: TWorld); 
var i,x,y:Integer;currentChunk:TChunk;
begin
    // Calculate current chunk
    x := Trunc(playerAction.selectedBlock.x) mod 100;
    y := Trunc(playerAction.selectedBlock.y);

    currentChunk := getChunkByIndex(world, getChunkIndex(playerAction.selectedBlock.x));

    for i := 0 to length(playerAction.acts) - 1 do
    begin
        case playerAction.acts[i] of
            PLACE_BLOCK: 
            begin
                currentChunk.layout[x][y]:= world.player.heldItem; 
            end;
            REMOVE_BLOCK: 
            begin
                currentChunk.layout[x][y] := 0;
            end;
        end;
    end;
    reinsertChunk(world,currentChunk)
end;
end.