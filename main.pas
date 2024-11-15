program lmm;



uses SDL2, LMMTypes, util, tick, act, display;

var
    world: TWorld;
    playerAction: TPlayerAction;
begin
    //Initialisation de la SDL
    if SDL_Init(SDL_INIT_VIDEO) <> 0 then
    begin
        writeln('Erreur initialisation SDL : ', SDL_GetError());
        exit;
    end;

    //Création de la fenêtre
    var window := SDL_CreateWindow('LMM', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, SDL_WINDOW_SHOWN);
    if window = nil then
    begin
        writeln('Erreur création fenêtre : ', SDL_GetError());
        exit;
    end;

    //Création du rendu
    var renderer := SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED);
    if renderer = nil then
    begin
        writeln('Erreur création rendu : ', SDL_GetError());
        exit;
    end;

    //Initialisation de la structure du monde
    var world := initWorld('TestWorld'); // TO CHANGE
    playerAction.acts := [];
    playerAction.selectedBlock.x := 0;

    //Initialisation de la santé du joueur
    world.player.health := 100;

    //Boucle principale
    var running := true;
    var event: SDL_Event;
    while running do
    begin
        //Gestion des événements
        while SDL_PollEvent(@event) <> 0 do
        begin
            case event.type_ of
                SDL_QUIT: running := false;
                SDL_KEYDOWN:
                begin
                    case event.key.keysym.sym of
                        SDLK_ESCAPE: running := false;
                    else
                        playerAction := handleInput(event.key.keysym.sym, world.playerAction, true);
                    end;
                end;
            end;
        end;

        //Mise à jour du monde et action du joueur
        tick(world, playerAction);  // NOT TRUE IMPLEMENTATION
        playerAction.acts := [];

        //Affichage du monde
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderClear(renderer);
        //cameraDisplacement(world, world.player.pos, 300, 400); // NOT IMPLEMENTED
end.