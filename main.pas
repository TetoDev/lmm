program main;


uses fileHandler,sdl2, SDL2_image, LMMTypes, util, tick, act, display;

var
    world: TWorld;
    textures: TTextures;
    playerAction: TPlayerAction;
    window: PSDL_Window;
    renderer: PSDL_Renderer;
    running:Boolean;
    event: TSDL_Event;
    i: Integer;
begin
    //Initialisation de la SDL
    if SDL_Init(SDL_INIT_VIDEO) < 0 then
    begin
        writeln('Erreur initialisation SDL : ', SDL_GetError());
        exit;
    end;

    if (IMG_Init(IMG_INIT_PNG) and IMG_INIT_PNG) = 0 then
    begin
        Writeln('SDL_image could not initialize! IMG_Error: ', IMG_GetError);
        SDL_Quit;
        Halt(1);
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

    // Initialisation des textures
    LoadTextures(renderer, textures);

    //Initialisation de la structure du monde

    world := worldInit('Save 1'); 
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
        tick.tick(world, playerAction, renderer, textures);  

        playerAction.acts := [];

        //Affichage du monde
        SDL_RenderPresent(renderer);
    end;  

	for i:=1 to 6 do
			SDL_DestroyTexture(textures.blocks[i]);
    SDL_DestroyRenderer(Renderer);
    SDL_DestroyWindow(Window);
    IMG_Quit;
    SDL_Quit;
end.