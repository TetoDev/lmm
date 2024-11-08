unit act;

Interface
uses LMMTypes; 

function handleInput(keyPressed:String):TActs;

Implementation

function handleInput(keyPressed:String):TActs;
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

procedure act(velocity: TVelocity, blockBelow: Boolean, acts: actsArray);
var i: Integer;
    action: TActs;
begin
    for i:= 0 to length(acts) - 1 do
    begin
        action := acts[i];
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

end.