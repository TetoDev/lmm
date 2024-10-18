unit act;

Interface
uses LMMTypes, sdl2; 

function handleInput(keyPressed:TSDL_KeyboardEvent):TActs;

Implementation

function handleInput(keyPressed:TSDL_KeyboardEvent):TActs;
begin
    //Suivant la touche appuyée on effectue différente action
    case keyPressed of
        SDLK_LEFT: 
        begin 
            handleInput := WALK_LEFT; 
        end;
        SDLK_RIGHT: 
        begin 
            handleInput := WALK_RIGHT; 
        end;
        SDLK_UP: 
        begin 
            handleInput := JUMP; 
        end;
        SDLK_DOWN: 
        begin 
            handleInput := PLACE_BLOCK; 
        end;
    end;

    writeln(SDL_getKeyName(keyPressed.keysym.sym));
end;

end.