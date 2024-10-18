program test_acts;

uses LMMTypes,sdl2,act;

var input:TActs; fin:Boolean; event: PSDL_Event;
begin
    fin := false;
    repeat
		{On se limite a 25 fps.}
		SDL_Delay(40);
		{On lit un evenement et on agit en consequence}
		SDL_PollEvent(event);
        
        if event^.type_ = SDL_KEYDOWN then
            input := handleInput(event^.key);
        
        if input = WALK_LEFT then
            writeln('Player walk to the left');
            
        if input = WALK_RIGHT then
            writeln('Player walk to the right');
            
        if input = JUMP then
            writeln('Player jump');
            
        if input = PLACE_BLOCK then 
            fin:=True;	
	  until fin;
end.