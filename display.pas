unit display;

Interface

uses LMMTypes, util, sdl2,sdl2_image,sdl2_ttf,sdl2_mixer, SysUtils;

procedure printChunk(chunk:TChunk);

procedure cameraDisplacement(world: TWorld; position: TPosition; viewHeight,viewWidth: Integer);

procedure LoadTextures(var renderer: PSDL_Renderer; var Textures: TTextures);

procedure displayPlayer(world:TWorld; window:TWindow;var renderer: PSDL_Renderer; displayAsChunk: Boolean);

procedure displayInventory(world:TWorld; window:TWindow; var renderer: PSDL_renderer);

procedure displayChunk(chunk:TChunk; var renderer: PSDL_Renderer; positiveDir:Boolean);

procedure displayBlocks(world:TWorld;window:TWindow; chunk,nextChunk:TChunk; var renderer: PSDL_Renderer);

procedure displayBlocksTextured(window:TWindow;chunk,nextChunk:TChunk; pos:TPosition; textures:TTextures; var renderer: PSDL_Renderer);

procedure destroyTextures(var textures: TTextures);


Implementation

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


procedure LoadTextures(var renderer: PSDL_Renderer; var textures: TTextures);
var chemin:String; pchemin:PChar; i:Integer;
begin
	for i := 1 to 6 do
    begin
        chemin := 'assets/textures/'+IntToStr(i)+'.png';
        pchemin:=StrAlloc(length(chemin)+1);
        strPCopy(pchemin, chemin);
        textures.blocks[i]:=IMG_LoadTexture(renderer, pchemin);
        StrDispose(pchemin);
    end

end;

procedure displayPlayer(world:TWorld; window:TWindow; var renderer: PSDL_Renderer; displayAsChunk: Boolean);
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
        width := Trunc(SURFACEWIDTH/BLOCKDISPLAYED);
        height := Trunc(SURFACEHEIGHT/BLOCKDISPLAYED);
        Rect.x := (((window.width div SIZE)-1) div 2)*SIZE;
        Rect.y := (((window.height div SIZE)-1) div 2)*SIZE;
        Rect.w := width;
        Rect.h := height;
        SDL_RenderFillRect(Renderer, @Rect);
    end;
end;

procedure displayInventory(world:TWorld; window:TWindow; var renderer: PSDL_renderer);
var Rect: TSDL_Rect;
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
                        Rect.y :=  i*height;
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
var i,j,x,y,xAdjustement,yAdjustement,delta:Integer; Rect: TSDL_Rect;
begin
    x:= Trunc(pos.x) mod 100; 
    y:= 99 - Trunc(pos.y);

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