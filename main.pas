program main;


uses fileHandler,sdl2, sdl2_ttf,SDL2_image, LMMTypes, util, tick, act, display, mob, menu;

var
    world: TWorld;
    textures: TTextures;
    data:TAnimationData;
    playerAction: TPlayerAction;
    window: PSDL_Window;
    renderer: PSDL_Renderer;
    running,pause:Boolean;
    event: TSDL_Event;
    key:TKey;
    windowParam:TWindow;
    Font: PTTF_Font;
begin
    windowParam.height := SURFACEHEIGHT;
    windowParam.width := SURFACEWIDTH;
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

    if TTF_Init < 0 then
    begin
        Writeln('Erreur lors de l''initialisation de SDL_ttf: ', TTF_GetError);
        SDL_Quit;
        Halt(1);
    end;

    //Création de la fenêtre
    window := SDL_CreateWindow('LMM', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, windowParam.width, windowParam.height, SDL_WINDOW_RESIZABLE );
    if window = nil then
    begin
        writeln('Erreur création fenêtre : ', SDL_GetError());
        exit;
    end;

    windowParam.window := window;

    //Création du rendu
    renderer := SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);

    if renderer = nil then
    begin
        writeln('Erreur création rendu : ', SDL_GetError());
        exit;
    end;

    // Charger une police de caractères
    Font := TTF_OpenFont(PChar('assets/GoblinOne-Regular.ttf'), 24); // Charge la police Arial taille 24
    if Font = nil then
    begin
        Writeln('Erreur lors du chargement de la police: ', TTF_GetError);
        SDL_DestroyRenderer(Renderer);
        SDL_DestroyWindow(Window);
        TTF_Quit;
        SDL_Quit;
        Halt(1);
    end;


    // Initialisation des textures
    LoadTextures(renderer, textures, data);
    data.Fram:= 1;
    data.playerAction := 1;
    //Initialisation de la structure du monde

    world := worldInit('Save 1'); 
    playerAction.acts := [];
    playerAction.selectedBlock.x := 0;


    //Initialisation des paramètres du joueur
    world.player.health := 100;
    world.player.heldItem := 1;
    world.player.direction := True;
    windowParam.width := SURFACEHEIGHT;
    windowParam.height := SURFACEWIDTH;

    //Boucle principale
    running := true;

    // ajout de mob;
    generateMob(world,data); // rendu pas très beau, a modifier
    world.mobs[0].direction := 0; 

    while running do
    begin
        //Gestion des événements
        while SDL_PollEvent(@event) <> 0 do
        begin 
            case event.type_ of
                SDL_QUITEV: 
                    running := false;

                SDL_KEYDOWN:
                        handleInput(SDL_GetKeyName(Event.key.keysym.sym),key, playerAction, world.player.direction,true, true, running, pause);

                SDL_KEYUP:
                        handleInput(SDL_GetKeyName(Event.key.keysym.sym),key, playerAction, world.player.direction,true, false, running, pause);

                SDL_MOUSEBUTTONDOWN:
                    begin
                        if event.button.button = SDL_BUTTON_RIGHT then
                        begin
                            if not pause then
                                handleMouse(event.button.x, event.button.y, world,windowParam, PLACE_BLOCK, playerAction,pause,running)
                            else 
                                handleMouse(event.button.x, event.button.y, world,windowParam, PLACE_BLOCK, playerAction ,pause,running);
                        end;
                        if event.button.button = SDL_BUTTON_LEFT then
                        begin
                            if not pause then
                                handleMouse(event.button.x, event.button.y, world,windowParam, REMOVE_BLOCK, playerAction, pause,running);
                        end;
                    end;

                SDL_MOUSEWHEEL: 
                    begin
                        if Event.wheel.y > 0 then
                            world.player.heldItem := (world.player.heldItem - 1) 
                        else 
                        if Event.wheel.y < 0 then
                            world.player.heldItem := (world.player.heldItem + 1) ;
                            
                        if world.player.heldItem = 0 then
                            world.player.heldItem := 1;
                        if world.player.heldItem = 7 then
                            world.player.heldItem := 6;
                    end;
                    
                SDL_WINDOWEVENT:
                    if Event.window.event = SDL_WINDOWEVENT_RESIZED then
                    begin
                        windowParam.width := event.window.data1; // Nouvelle largeur
                        windowParam.height := event.window.data2; // Nouvelle hauteur
                    end;
                
            end;
            
        end;
        addAction(playerAction,key);
        
        
        
        // on clear l'écran avant de réafficher le monde 
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);

        //Mise à jour du monde et action du joueur
        tick.tick(world,windowParam, playerAction, renderer, textures, data, Font, key);  
        if pause then
          MenuQuitter(window,renderer,windowParam);

        playerAction.acts := [];

        //Affichage du monde
        SDL_RenderPresent(renderer);
        SDL_delay(1000 div 60); // pour caper le nombre de fps 60 
    end;  

    //Fermeture de la fenêtre
    destroyTextures(textures);
    SDL_DestroyRenderer(Renderer);
    SDL_DestroyWindow(Window);
    IMG_Quit;
    SDL_Quit;
end.