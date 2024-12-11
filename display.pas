unit display;

Interface

uses LMMTypes, util, sdl2,sdl2_image,sdl2_ttf, SysUtils;


procedure InitDisplay(var windowParam:TWindow; var renderer:PSDL_renderer; var Font:PTTF_Font; var textures:TTextures; var data:TAnimationData);

procedure printChunk(chunk:TChunk);

procedure cameraDisplacement(world: TWorld; position: TPosition; viewHeight,viewWidth: Integer);

procedure LoadTextures(var renderer: PSDL_Renderer; var textures: TTextures; var data:TAnimationData);

procedure displayPlayerBlock(world:TWorld; window:TWindow;var renderer: PSDL_Renderer; displayAsChunk: Boolean);

procedure displayPlayer(world:TWorld; window:TWindow;Textures:TTextures; data:TAnimationData;var renderer: PSDL_Renderer);

procedure displayMobs(world:TWorld; window:TWindow; Textures: TTextures; data:TAnimationData; var renderer: PSDL_Renderer);

procedure displayInventory(world:TWorld; window:TWindow; var renderer: PSDL_renderer; textures:TTextures; textured :Boolean);

procedure displayHpBar(world:TWorld; window:TWindow; var renderer: PSDL_renderer);

procedure displayChunk(chunk:TChunk; var renderer: PSDL_Renderer; positiveDir:Boolean);

procedure displayBlocks(world:TWorld;window:TWindow; chunk,nextChunk:TChunk; var renderer: PSDL_Renderer);

procedure displayBlocksTextured(window:TWindow;chunk,nextChunk:TChunk; pos:TPosition; textures:TTextures; var renderer: PSDL_Renderer);

procedure destroyTextures(var textures: TTextures);

procedure displaySky(var renderer: PSDL_Renderer; world: TWorld; textures:TTextures);


Implementation

procedure InitDisplay(var windowParam:TWindow; var renderer:PSDL_renderer; var Font:PTTF_Font; var textures:TTextures; var data:TAnimationData);
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
    windowParam.window := SDL_CreateWindow('LMM', SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, windowParam.width, windowParam.height, SDL_WINDOW_RESIZABLE );
    if windowParam.window = nil then
    begin
        writeln('Erreur création fenêtre : ', SDL_GetError());
        exit;
    end;


    //Création du rendu
    renderer := SDL_CreateRenderer(windowParam.window, -1, SDL_RENDERER_ACCELERATED);

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
        SDL_DestroyWindow(windowParam.window);
        TTF_Quit;
        SDL_Quit;
        Halt(1);
    end;


    // Initialisation des textures
    LoadTextures(renderer, textures, data);
    data.Fram:= 1;
    data.playerAction := 1;
end;

// procedure pour afficher le chunk entier dans le terminal
procedure printChunk(chunk:TChunk);
var i,j:Integer;
begin
    for i := 0 to 99 do
    begin
        for j := 0 to 99 do
            write(chunk.layout[j][99-i]);
        writeln();
    end;
end;

// procedure pour afficher les alentours d'ou se trouve le joueur dans le terminal
procedure cameraDisplacement(world: TWorld; position: TPosition; viewHeight,viewWidth: Integer);
var i, j, relativeX, heightBot,heightTop, widthLeft,widthRight,restLeft,restRight : Integer; chunkLeft,chunkRight,chunk:TChunk;
begin
    chunk := getChunkByIndex(world,Round(position.x) div 100 );
    chunkLeft := getChunkByIndex(world,Round(position.x) div 100 - 1);
    chunkRight := getChunkByIndex(world,Round(position.x) div 100 + 1);
    //On défini la position du joueur relativement au chunk
    relativeX := abs(Round(position.x) mod 100);

    //On défini les extrémités minimal et maximal en Y a afficher 
    if (Round(position.y) - viewHeight >= 0) and (Round(position.y) + viewHeight <= 99) then
    begin
        heightBot := Round(position.y) - viewHeight;
        heightTop := Round(position.y) + viewHeight;
    end
    else if (Round(position.y) + viewHeight > 99) then
    begin
        heightBot := Round(position.y) - viewHeight;
        heightTop := 99;
    end
    else if (Round(position.y) - viewHeight < 0) then
    begin
        heightBot := 0;
        heightTop := Round(position.y) + viewHeight;
    end;

    //On défini les extrémités minimal et maximal en X a afficher 
    if (relativeX - viewWidth >= 0) and (relativeX + viewWidth <= 99) then 
    begin
        widthLeft := relativeX - viewWidth;
        widthRight := relativeX + viewWidth;
        restLeft := 99;
        restRight := 0;
    end
    else if relativeX - viewWidth < 0 then
    begin
        widthLeft := 0;
        widthRight := relativeX + viewWidth;
        restLeft := 99 + relativeX - viewWidth ;
        restRight := 0;
    end 
    else if relativeX + viewWidth > 99 then
    begin
        widthLeft := relativeX - viewWidth;
        widthRight := 99;
        restLeft := 99;
        restRight := relativeX + viewWidth - 99;
    end;

    //Affichage du chunk relatif a la position du joueur et de ses coordonnées
    for i := heightTop downto heightBot do
    begin
        //Affichage du chunk de droite si il y a besoin
        if restLeft < 99 then
            for j := restLeft to 99 do
                write(chunkLeft.layout[j][i]);
        //Affichage du chunk du joueur 
        for j := widthLeft to widthRight do
            write(chunk.layout[j][i]);
        //Affichage du chunk de droite si il y a besoin
        if restRight > 0 then
            for j := 0 to restRight do
                write(chunkRight.layout[j][i]);
        writeln();
    end;
end;


procedure LoadTextures(var renderer: PSDL_Renderer; var textures: TTextures; var data:TAnimationData);
var chemin:String; pchemin:PChar; i:Integer;
begin
	for i := 1 to 6 do
    begin
        chemin := 'assets/textures/'+IntToStr(i)+'.png';
        pchemin:=StrAlloc(length(chemin)+1);
        strPCopy(pchemin, chemin);
        textures.blocks[i]:=IMG_LoadTexture(renderer, pchemin);
        StrDispose(pchemin);
    end;
    for i := 1 to 5 do
    begin
        chemin := 'assets/player/'+IntToStr(i)+'.png';
        pchemin:=StrAlloc(length(chemin)+1);
        strPCopy(pchemin, chemin);
        textures.player[i]:=IMG_LoadTexture(renderer, pchemin);
        StrDispose(pchemin);
    end;
    textures.sky:=IMG_LoadTexture(renderer, PChar('assets/sky/sky.png'));
    data.PlayerNbFram[1] := 4;
    data.PlayerNbFram[2] := 6;
    data.PlayerNbFram[3] := 6;
    data.PlayerNbFram[4] := 6;
    data.PlayerNbFram[5] := 3;
    
    textures.logo:=IMG_LoadTexture(renderer, PChar('assets/logo/logo_LMM.png'));

    for i := 1 to 3 do
    begin
        chemin := 'assets/mob/'+IntToStr(i)+'.png';
        pchemin:=StrAlloc(length(chemin)+1);
        strPCopy(pchemin, chemin);
        textures.mobs[i]:=IMG_LoadTexture(renderer, pchemin);
        StrDispose(pchemin);
    end;
    data.mobNbFram[1] := 4;
    data.mobNbFram[2] := 4;
    data.mobNbFram[3] := 2;
end;

procedure displayPlayerBlock(world:TWorld; window:TWindow; var renderer: PSDL_Renderer; displayAsChunk: Boolean);
var Rect: TSDL_Rect;height,width:Integer;
begin
    if displayAsChunk then
    begin
        SDL_SetRenderDrawColor(Renderer, 255, 255, 255, SDL_ALPHA_OPAQUE);
        width := Trunc(window.width/100);
        height := Trunc(window.height/100);
        if world.player.pos.x >= 0 then
            Rect.x := Trunc(world.player.pos.x) mod 100*width
        else
            Rect.x := (99 + Trunc(world.player.pos.x) mod 100)*width;
        Rect.y := Trunc(SURFACEHEIGHT - (world.player.pos.y)) mod 100 *height;
        Rect.w := width;
        Rect.h := height;
        SDL_RenderFillRect(Renderer, @Rect);
    end
    else
    begin
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
        width := Trunc(SURFACEWIDTH/BLOCKDISPLAYED*0.8);
        height := Trunc(SURFACEHEIGHT/BLOCKDISPLAYED*1.8);
        Rect.x := (((window.width div SIZE)-1) div 2)*SIZE;
        Rect.y := (((window.height div SIZE)-1) div 2)*SIZE;
        Rect.w := width;
        Rect.h := height;
        SDL_RenderFillRect(Renderer, @Rect);
    end;
end;


procedure displayPlayer(world:TWorld; window:TWindow;Textures:TTextures; data:TAnimationData;var renderer: PSDL_Renderer);
var Rect, subRect : TSDL_RECT;
begin

    // the direction of the sprite change the way it is render so we have to modify the coords
    if world.player.direction then 
	    Rect.x := (((window.width div SIZE)-1) div 2)*SIZE
    else 
	    Rect.x := (((window.width div SIZE)-2) div 2)*SIZE;

    Rect.y := (((window.height div SIZE)-2) div 2)*SIZE;
	
    Rect.w := SIZE*2;
    Rect.h := SIZE*2;

    SDL_QueryTexture(Textures.player[data.playerAction], nil, nil, @subRect.w, @subRect.h);

    subRect.w := subRect.w div data.PlayerNbFram[data.playerAction];
    subRect.x := subRect.w * data.playerStep;
    subRect.y := 0;

    if world.player.direction then
        SDL_RenderCopyEx(renderer, Textures.player[data.playerAction], @subRect, @Rect, 0, nil, SDL_FLIP_NONE )
    else
        SDL_RenderCopyEx(renderer, Textures.player[data.playerAction], @subRect, @Rect, 0, nil, SDL_FLIP_HORIZONTAL);

end;

procedure displayMobs(world:TWorld; window:TWindow; Textures: TTextures; data:TAnimationData; var renderer: PSDL_Renderer);
var i,xAdjustement,yAdjustement:Integer; Rect, subRect : TSDL_RECT;x,y,xMob:Real;
begin
    x:= world.player.pos.x - 100*(trunc(world.player.pos.x/100)); 
    y:= 99 - world.player.pos.y;


    Rect.w := SIZE;
    Rect.h := SIZE;

    xAdjustement := ((window.width div SIZE)-1) div 2;
    yAdjustement := ((window.height div SIZE)-2) div 2;

    for i:= 0 to (Length(world.mobs)-1) do
    begin
        xMob := world.mobs[i].pos.x - 100*world.player.pos.x/100;
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
        Rect.x := Trunc(xMob - x + xAdjustement)*SIZE;
        Rect.y := Trunc(y - 1 - Trunc(world.mobs[i].pos.y)  + yAdjustement)*SIZE;

        SDL_QueryTexture(Textures.mobs[data.mobsData[i].mobAction], nil, nil, @subRect.w, @subRect.h);

        subRect.w := subRect.w div data.mobNbFram[data.mobsData[i].mobAction];
        subRect.x := subRect.w * (data.playerStep mod data.mobNbFram[data.mobsData[i].mobAction]);
        subRect.y := 0;
        if world.mobs[i].direction > 0 then
            SDL_RenderCopyEx(renderer, Textures.mobs[data.mobsData[i].mobAction], @subRect, @Rect, 0, nil, SDL_FLIP_NONE )
        else
            SDL_RenderCopyEx(renderer, Textures.mobs[data.mobsData[i].mobAction], @subRect, @Rect, 0, nil, SDL_FLIP_HORIZONTAL);
    end;
end;

procedure displayInventory(world:TWorld; window:TWindow; var renderer: PSDL_renderer; textures:TTextures; textured :Boolean);
var Rect: TSDL_Rect; i :Integer;
begin
    
    SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255);
    Rect.w := 370;
    Rect.h := 70;
    Rect.x := window.width div 2 - 185;
    Rect.y := window.height - 100;
    SDL_RenderFillRect(Renderer, @Rect);

    SDL_SetRenderDrawColor(renderer, 100, 100, 100, 255);
    Rect.w := 70;
    Rect.h := 70;
    Rect.x := window.width div 2 - 185 + (world.player.heldItem-1)*60;
    Rect.y := window.height - 100;
    SDL_RenderFillRect(Renderer, @Rect);

    Rect.w := 50;
    Rect.h := 50;


    if not textured then
    begin
    SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
    Rect.x := window.width div 2 - 175 ;
    Rect.y := window.height - 90;
    SDL_RenderFillRect(Renderer, @Rect);

    SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255); 
    Rect.x := window.width div 2 - 115 ;
    Rect.y := window.height - 90;
    SDL_RenderFillRect(Renderer, @Rect);

    SDL_SetRenderDrawColor(renderer, 63, 33, 7, 255); 
    Rect.x := window.width div 2 - 55 ;
    Rect.y := window.height - 90;
    SDL_RenderFillRect(Renderer, @Rect);

    SDL_SetRenderDrawColor(renderer, 28, 66, 32, 255); 
    Rect.x := window.width div 2 + 5 ;
    Rect.y := window.height - 90;
    SDL_RenderFillRect(Renderer, @Rect);

    SDL_SetRenderDrawColor(renderer, 134, 134, 134, 255);
    Rect.x := window.width div 2 + 65 ;
    Rect.y := window.height - 90;
    SDL_RenderFillRect(Renderer, @Rect);

    SDL_SetRenderDrawColor(renderer, 26, 26, 26, 255);   
    Rect.x := window.width div 2 + 125 ;
    Rect.y := window.height - 90;
    SDL_RenderFillRect(Renderer, @Rect);
    end
    else
    begin
    for i := 0 to 5 do 
    begin
        Rect.x := window.width div 2 - 175 +i*60;
        Rect.y := window.height - 90;
        SDL_RenderCopy(renderer, textures.blocks[i+1], nil, @Rect);
    end;
    end;
end;

procedure displayHpBar(world:TWorld; window:TWindow; var renderer: PSDL_renderer);
var Rect: TSDL_Rect;
begin
    SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255);
    Rect.w := 370;
    Rect.h := 40;
    Rect.x := window.width div 2 - 185;
    Rect.y := window.height - 1650;
    SDL_RenderFillRect(Renderer, @Rect);

    SDL_SetRenderDrawColor(renderer, 240, 0, 0, 255);
    Rect.w := 370*Trunc(world.player.health/100);
    Rect.h := 40;
    Rect.x := window.width div 2 - 185;
    Rect.y := window.height - 150;
    SDL_RenderFillRect(Renderer, @Rect);
end;

procedure displayChunk(chunk:TChunk; var renderer: PSDL_Renderer;positiveDir:Boolean);
var i,j,height,width:Integer; Rect: TSDL_Rect;
begin
    width := SURFACEWIDTH div 100;
    height := SURFACEHEIGHT div 100;
    Rect.w := width;
    Rect.h := height;
    for i := 0 to 99 do
        begin
            if positiveDir then 
                for j := 0 to 99 do
                begin
                    if chunk.layout[j][99-i] > 0 then 
                    begin
                        SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
                        if chunk.layout[j][99-i] = 2 then 
                            SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255); 
                        if chunk.layout[j][99-i] = 3 then 
                            SDL_SetRenderDrawColor(renderer, 63, 33, 7, 255); 
                        if chunk.layout[j][99-i] = 4 then 
                            SDL_SetRenderDrawColor(renderer, 28, 66, 32, 255); 
                        if chunk.layout[j][99-i] = 5 then 
                            SDL_SetRenderDrawColor(renderer, 134, 134, 134, 255);
                        if chunk.layout[j][99-i] = 6 then 
                            SDL_SetRenderDrawColor(renderer, 26, 26, 26, 255);      
                        Rect.x := j*width;
                        Rect.y := i*height;
                        SDL_RenderFillRect(Renderer, @Rect);
                    end;
                end
            else
                for j := 0 to 99 do
                begin
                    if chunk.layout[99-j][99-i] > 0 then 
                    begin
                        SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
                        if chunk.layout[99-j][99-i] = 2 then 
                            SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255); 
                        if chunk.layout[99-j][99-i] = 3 then 
                            SDL_SetRenderDrawColor(renderer, 63, 33, 7, 255); 
                        if chunk.layout[99-j][99-i] = 4 then 
                            SDL_SetRenderDrawColor(renderer, 28, 66, 32, 255);
                        if chunk.layout[99-j][99-i] = 5 then 
                            SDL_SetRenderDrawColor(renderer, 134, 134, 134, 255);
                        if chunk.layout[99-j][99-i] = 6 then 
                            SDL_SetRenderDrawColor(renderer, 26, 26, 26, 255);       
                        Rect.x := j*width;
                        Rect.y := i*height;
                        SDL_RenderFillRect(Renderer, @Rect);
                    end;
                end
        end;
end;

procedure displayBlocks(world:TWorld; window:TWindow; chunk,nextChunk:TChunk; var renderer: PSDL_Renderer);
var i,j,x,y,delta, xAdjustement, yAdjustement:Integer; Rect: TSDL_Rect;
begin
    x:= Trunc(world.player.pos.x) mod 100; 
    y:= 99 - Trunc(world.player.pos.y);

    Rect.w := SIZE;
    Rect.h := SIZE;

    xAdjustement := ((window.width div SIZE)-1) div 2;
    yAdjustement := ((window.height div SIZE)-1) div 2;

    // We render the current chunk
    if chunk.chunkIndex >=0 then 
    for i := 0 to 99 do
        for j := 0 to 99 do
        begin
            if chunk.layout[j][99-i] > 0 then 
            begin
                SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
                if chunk.layout[j][99-i] = 2 then 
                    SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255);
                if chunk.layout[j][99-i] = 3 then 
                    SDL_SetRenderDrawColor(renderer, 63, 33, 7, 255); 
                if chunk.layout[j][99-i] = 4 then 
                    SDL_SetRenderDrawColor(renderer, 28, 66, 32, 255); 
                if chunk.layout[j][99-i] = 5 then 
                    SDL_SetRenderDrawColor(renderer, 134, 134, 134, 255);
                if chunk.layout[j][99-i] = 6 then 
                    SDL_SetRenderDrawColor(renderer, 26, 26, 26, 255);         
                Rect.x := (j - x + xAdjustement)*SIZE;
                Rect.y := (i - y + yAdjustement)*SIZE;
                SDL_RenderFillRect(Renderer, @Rect);
            end;
        end
    // But if the chunk is negative we render it in the opposite direction
    else
    for i := 0 to 99 do
        for j := 0 to 99 do
        begin
            if chunk.layout[99-j][99-i] > 0 then 
            begin
                SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
                if chunk.layout[99-j][99-i] = 2 then 
                    SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255);
                if chunk.layout[99-j][99-i] = 3 then 
                    SDL_SetRenderDrawColor(renderer, 63, 33, 7, 255); 
                if chunk.layout[99-j][99-i] = 4 then 
                    SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255); 
                if chunk.layout[99-j][99-i] = 5 then 
                    SDL_SetRenderDrawColor(renderer, 134, 134, 134, 255); 
                if chunk.layout[99-j][99-i] = 6 then 
                    SDL_SetRenderDrawColor(renderer, 26, 26, 26, 255);      
                Rect.x := (j - (99+x) + 6)*SIZE;
                Rect.y := (i - y  + 6)*SIZE;
                SDL_RenderFillRect(Renderer, @Rect);
            end;  
        end;
    delta:= nextChunk.chunkIndex - chunk.chunkIndex;
    //We render the next chunk
    if nextChunk.chunkIndex >=0 then 
    for i := 0 to 99 do
        for j := 0 to 99 do
        begin
            if nextChunk.layout[j][99-i] > 0 then 
            begin
                SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
                if nextChunk.layout[j][99-i] = 2 then 
                    SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255);
                if nextChunk.layout[j][99-i] = 3 then 
                    SDL_SetRenderDrawColor(renderer, 63, 33, 7, 255); 
                if nextChunk.layout[j][99-i] = 4 then 
                    SDL_SetRenderDrawColor(renderer, 28, 66, 32, 255); 
                if nextChunk.layout[j][99-i] = 5 then 
                    SDL_SetRenderDrawColor(renderer, 134, 134, 134, 255);
                if nextChunk.layout[j][99-i] = 6 then 
                    SDL_SetRenderDrawColor(renderer, 26, 26, 26, 255);         
                Rect.x := (j - x + 6)*SIZE + 100*SIZE*delta;
                Rect.y := (i - y + 6)*SIZE;
                SDL_RenderFillRect(Renderer, @Rect);
            end;
        end
    // But if the chunk is negative we render it in the opposite direction
    else
    for i := 0 to 99 do
        for j := 0 to 99 do
        begin
            if nextChunk.layout[99-j][99-i] > 0 then 
            begin
                SDL_SetRenderDrawColor(renderer, 0, 255, 0, 255);
                if nextChunk.layout[99-j][99-i] = 2 then 
                    SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255);
                if nextChunk.layout[99-j][99-i] = 3 then 
                    SDL_SetRenderDrawColor(renderer, 63, 33, 7, 255); 
                if nextChunk.layout[99-j][99-i] = 4 then 
                    SDL_SetRenderDrawColor(renderer, 139, 69, 19, 255); 
                if nextChunk.layout[99-j][99-i] = 5 then 
                    SDL_SetRenderDrawColor(renderer, 134, 134, 134, 255); 
                if nextChunk.layout[99-j][99-i] = 6 then 
                    SDL_SetRenderDrawColor(renderer, 26, 26, 26, 255);      
                Rect.x := Trunc((j - (99+x) + 6)*SIZE) + 100*SIZE*delta;
                Rect.y := Trunc((i - y  + 6)*SIZE);
                SDL_RenderFillRect(Renderer, @Rect);
            end;  
        end;
end;


procedure displayBlocksTextured(window:TWindow;chunk,nextChunk:TChunk; pos:TPosition; textures:TTextures; var renderer: PSDL_Renderer);
var i,j,xAdjustement,yAdjustement,delta:Integer; Rect: TSDL_Rect; x,y:Real;
begin
    x:= pos.x - 100*(trunc(pos.x/100)); 
    y:= 99 - pos.y;

    Rect.w := SIZE;
    Rect.h := SIZE;

    xAdjustement := ((window.width div SIZE)-1) div 2 ;
    yAdjustement := trunc(((window.height div SIZE)-1.2)/2);

    // We render the current chunk
    if chunk.chunkIndex >=0 then 
    for i := 0 to 99 do
        for j := 0 to 99 do
        begin
            if chunk.layout[j][99-i] > 0 then 
            begin  
                Rect.x := Trunc((j - x + xAdjustement)*SIZE);
                Rect.y := Trunc((i - y + yAdjustement)*SIZE);
	            SDL_RenderCopy(renderer, textures.blocks[chunk.layout[j][99-i]], nil, @Rect);
            end;
        end
    // But if the chunk is negative we render it in the opposite direction
    else
    for i := 0 to 99 do
        for j := 0 to 99 do
        begin
            if chunk.layout[99-j][99-i] > 0 then 
            begin 
                Rect.x := Trunc((j - (99+x) + xAdjustement)*SIZE);
                Rect.y := Trunc((i - y  + yAdjustement)*SIZE);
	            SDL_RenderCopy(renderer, textures.blocks[chunk.layout[99-j][99-i]], nil, @Rect)
            end;  
        end;
    delta:= nextChunk.chunkIndex - chunk.chunkIndex; // We determine if the next chunk is on the right or on the left

    //We render the next chunk
    if nextChunk.chunkIndex >=0 then 
    for i := 0 to 99 do
        for j := 0 to 99 do
        begin
            if nextChunk.layout[j][99-i] > 0 then 
            begin      
                Rect.x := Trunc((j - x + xAdjustement)*SIZE) + 100*SIZE*delta;
                Rect.y := Trunc((i - y + yAdjustement)*SIZE);
	            SDL_RenderCopy(renderer, textures.blocks[nextChunk.layout[j][99-i]], nil, @Rect)
            end;
        end
    // But if the chunk is negative we render it in the opposite direction
    else
    for i := 0 to 99 do
        for j := 0 to 99 do
        begin
            if nextChunk.layout[99-j][99-i] > 0 then 
            begin   
                Rect.x := Trunc((j - (99+x) + xAdjustement)*SIZE) + 100*SIZE * delta;
                Rect.y := Trunc((i - y  + yAdjustement)*SIZE);
	            SDL_RenderCopy(renderer, textures.blocks[nextChunk.layout[99-j][99-i]], nil, @Rect)
            end;  
        end;
end;

procedure displaySky(var renderer: PSDL_Renderer; world: TWorld; textures:TTextures);
var Rect: TSDL_Rect; opacity:Integer;
begin
    opacity := 255 - trunc(world.time/24000)*255;

    SDL_SetTextureAlphaMod(textures.sky, opacity);

    Rect.w := Round(1107/1.4);
    Rect.h := Round(707/1.4);
    Rect.x := Round(world.player.pos.x);
    Rect.y := Round(707/2 - world.player.pos.y*0.5);
    SDL_RenderCopy(Renderer, textures.sky, @Rect, nil);

    SDL_SetTextureAlphaMod(textures.sky, 255);
end;

procedure destroyTextures(var textures: TTextures);
var i:Integer;
begin
    for i := 1 to 6 do
        SDL_DestroyTexture(textures.blocks[i]);
    SDL_DestroyTexture(textures.sky);
    for i := 1 to 2 do
        SDL_DestroyTexture(textures.mobs[i]);
    for i := 1 to 2 do
        SDL_DestroyTexture(textures.player[i]);
end;

end.