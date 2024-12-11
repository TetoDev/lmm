unit game;

interface

uses fileHandler,sdl2, sdl2_ttf,SDL2_image, LMMTypes, util, tick, act, display, mob, menu;

procedure homeScreen(var world:TWorld;var windowParam:TWindow; var renderer:PSDL_renderer; var Font:PTTF_Font;textures:TTextures ;var leave:Boolean; var fileName:String); 
procedure playGame(var world:TWorld;var windowParam:TWindow; var renderer:PSDL_renderer; var Font:PTTF_Font; var textures:TTextures; var data:TAnimationData); 

implementation


procedure homeScreen(var world:TWorld;var windowParam:TWindow; var renderer:PSDL_renderer; var Font:PTTF_Font;textures:TTextures ;var leave:Boolean; var fileName:String);
var running,chooseWorld:Boolean;
    event: TSDL_Event;
    page:integer;
begin
    running := true;
    chooseWorld:=False;
    page := 1;
    while running do
    begin
        eventMenuListener(event,world,windowParam, fileName, page ,chooseWorld,running,leave);
        MenuHomescreen(renderer,windowParam, Font, textures,page,chooseWorld);
        //Affichage du monde
        SDL_RenderPresent(renderer);
        SDL_delay(1000 div 60); // pour caper le nombre de fps 60 
    end;  
end;


procedure playGame(var world:TWorld;var windowParam:TWindow; var renderer:PSDL_renderer; var Font:PTTF_Font; var textures:TTextures; var data:TAnimationData); 
var running,pause:Boolean;
    event: TSDL_Event;
    playerAction: TPlayerAction;
    key:TKey;
begin
    playerAction.acts := [];
    playerAction.selectedBlock.x := 0;
    running := true;
    pause := False;
    key.q := False;
    key.d:= False;
    key.f:= False;
    key.z := False;
    while running do // Changer de place act.pas
    begin
        //Gestion des événements
        eventGameListener(event,world,windowParam, key, playerAction ,running,pause);
        addAction(playerAction,key); 
        //Mise à jour du monde et action du joueur
        tick.tick(world,windowParam, playerAction, renderer, textures, data, Font, key);  
        
        if pause then // act.pas
          MenuQuitter(renderer,windowParam, Font);

        playerAction.acts := []; 

        //Affichage du monde
        SDL_RenderPresent(renderer);
        SDL_delay(1000 div 60); // pour caper le nombre de fps 60 
    end;  
end;

end.