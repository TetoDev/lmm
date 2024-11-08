unit act;

Interface
uses LMMTypes; 

function handleInput(keyPressed:String):TActs;
procedure playerMove(velocity: TVelocity, blockBelow: Boolean, playerAction: TPlayerAction);
procedure blockAct (playerAction: TPlayerAction; world: TWorld);

Implementation

function handleInput(keyPressed:String):TActs; // SHOULD RETURN TYPE TPlayerAction WITH A SELECTED BLOCK ATTRIBUTE
begin
    //Suivant la touche appuyée on effectue différente action
    case keyPressed of // VERY FRENCH LAYOUT
        'q': 
        begin 
            handleInput := WALK_LEFT;
        end;
        'd': 
        begin 
            handleInput := WALK_RIGHT; 
        end;
        'z': 
        begin 
            handleInput := JUMP; 
        end;
        's': 
        begin 
            handleInput := CROUCH; 
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