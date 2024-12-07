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
    world.windowHeight := SURFACEHEIGHT;
    world.windowWidth := SURFACEWIDTH;
    //Initialisation de la SDL
    if SDL_Init(SDL_INIT_VIDEO) < 0 then
    begin
        writeln('Erreur initialisation SDL : ', SDL_GetError());
        exit;
    end;
    //Création de la fenêtre
    window := SDL_CreateWindow('LMM', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, world.windowWidth, world.windowHeight, SDL_WINDOW_RESIZABLE );
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
    LoadTextures(renderer, world.textures);

    //Initialisation de la structure du monde

    world := worldInit('Save 1'); 
    playerAction.acts := [];
    playerAction.selectedBlock.x := 0;


    //Initialisation de la santé du joueur
    world.player.health := 100;
    world.player.heldItem := 1;
    world.windowHeight := SURFACEHEIGHT;
    world.windowWidth := SURFACEWIDTH;

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
                        handleInput(event.key.keysym.sym, playerAction, true);
                end;
                end;
                SDL_MOUSEBUTTONDOWN:
                begin
                    if event.button.button = SDL_BUTTON_RIGHT then
                        handleMouse(event.button.x, event.button.y, world, PLACE_BLOCK, playerAction);
                    if event.button.button = SDL_BUTTON_LEFT then
                        handleMouse(event.button.x, event.button.y, world, REMOVE_BLOCK, playerAction);
                end;
                SDL_MOUSEWHEEL: 
                begin
                    if Event.wheel.y > 0 then
                        world.player.heldItem := (world.player.heldItem + 1) 
                    else 
                    if Event.wheel.y < 0 then
                        world.player.heldItem := (world.player.heldItem - 1) ;
                        
                    if world.player.heldItem = 0 then
                        world.player.heldItem := 1;
                    if world.player.heldItem = 7 then
                        world.player.heldItem := 6;
                end;
                SDL_WINDOWEVENT:
                if Event.window.event = SDL_WINDOWEVENT_RESIZED then
                begin
                    world.windowWidth := event.window.data1; // Nouvelle largeur
                    world.windowHeight := event.window.data2; // Nouvelle hauteur
                end;
            end;
        end;
        
        //Mise à jour du monde et action du joueur
        tick.tick(world, playerAction, renderer);  

        playerAction.acts := [];
        //Affichage du monde
        SDL_RenderPresent(Renderer);
    end;  

    SDL_DestroyRenderer(Renderer);
    SDL_DestroyWindow(Window);
    SDL_Quit;
end.