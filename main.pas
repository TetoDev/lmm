program main;


uses fileHandler,sdl2, LMMTypes, util, tick, act, display;

var
    world: TWorld;
    playerAction: TPlayerAction;
    window: PSDL_Window;
    renderer: PSDL_Renderer;
    running:Boolean;
    event: TSDL_Event;
begin
    //Initialisation de la SDL
    if SDL_Init(SDL_INIT_VIDEO) < 0 then
    begin
        writeln('Erreur initialisation SDL : ', SDL_GetError());
        exit;
    end;
    //Création de la fenêtre
    window := SDL_CreateWindow('LMM', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, SURFACEWIDTH, SURFACEHEIGHT, SDL_WINDOW_SHOWN);
    if window = nil then
    begin
        writeln('Erreur création fenêtre : ', SDL_GetError());
        exit;
    end;

    //Création du rendu
    renderer := SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    if renderer = nil then
    begin
        writeln('Erreur création rendu : ', SDL_GetError());
        exit;
    end;

    //Initialisation de la structure du monde

    world := worldInit('TestWorld'); // TO CHANGE
    playerAction.acts := [];
    playerAction.selectedBlock.x := 0;


    //Initialisation de la santé du joueur
    world.player.health := 100;

    //Boucle principale
    running := true;
    while running do
    begin
        //Gestion des événements
        while SDL_PollEvent(@event) <> 0 do
        begin 
            case event.type_ of
                SDL_QUITEV: 
                begin
                    running := false;
                end;
                SDL_KEYDOWN:
                begin
                    case event.key.keysym.sym of
                        SDLK_ESCAPE: running := false;
                    else
                    begin
                        handleInput(event.key.keysym.sym, playerAction, true);
                    end;
                    end;
                end;
            end;
        end;
        
        //Mise à jour du monde et action du joueur
        tick.tick(world, playerAction);  // NOT TRUE IMPLEMENTATION

        playerAction.acts := [];
        //Affichage du monde
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);
        displayChunk(world, renderer);
        displayPlayer(world, renderer);
        SDL_RenderPresent(Renderer);

	    SDL_delay(1000 div 60); // pour caper le nombre de fps 60 
    end;  
    SDL_DestroyRenderer(Renderer);
    SDL_DestroyWindow(Window);
    SDL_Quit;
end.