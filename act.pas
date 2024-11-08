unit act;

Interface
uses LMMTypes; 

function handleInput(keyPressed:String):TActs;

Implementation

function handleInput(keyPressed:String):TActs;
begin
    //Suivant la touche appuyée on effectue différente action
    case keyPressed of
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

end.