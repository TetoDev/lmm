program main;


uses fileHandler,sdl2, sdl2_ttf,SDL2_image, LMMTypes, display, mob, menu, game, audioPlayer;

var
    world: TWorld;
    textures: TTextures;
    data:TAnimationData;
    audio: TAudio;
    renderer: PSDL_Renderer;
    windowParam:TWindow;
    Font: PTTF_Font;
    leave:Boolean;
    fileName:String;
begin
    leave := False;
    InitDisplay(windowParam,renderer,Font,textures,data);
    InitAudio(audio);
    // Depends on world menu

    // Initialisation of window parameter
    windowParam.width := SURFACEHEIGHT;
    windowParam.height := SURFACEWIDTH;

    repeat

        homeScreen(world,windowParam,renderer,Font,textures, leave, fileName);
        if not leave then
        begin
            world := worldInit(fileName);
            // ajout de mob;
            generateMob(world,data); // rendu pas très beau, a modifier
            //Boucle principale
            playGame(world,windowParam,renderer,Font,textures,data,audio);
        end;
      
    until leave;

    //Fermeture de la fenêtre
    destroyTextures(textures);
    SDL_DestroyRenderer(Renderer);
    SDL_DestroyWindow(windowParam.window);
    IMG_Quit;
    SDL_Quit;
end.