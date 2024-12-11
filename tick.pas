unit tick;

interface

uses LMMTypes, fileHandler, act, SysUtils, display, sdl2, sdl2_ttf, util, worldGeneration, mob, menu;

procedure tick(var world: TWorld; window:TWindow; playerAction: TPlayerAction; var renderer:  PSDL_Renderer; var textures: TTextures; var data:TAnimationData; Font: PTTF_Font;key:TKey);

implementation

procedure tick(var world: TWorld; window:TWindow; playerAction: TPlayerAction; var renderer:  PSDL_Renderer; var textures: TTextures; var data:TAnimationData; Font: PTTF_Font;key:TKey);
var playerPos: TPosition;
    playerVel: TVelocity;
    playerHealth, time: Integer;
    blockBelow: Boolean;
    currentChunk: TChunk;
    leftChunk, rightChunk: TChunk;
begin

    SDL_SetRenderDrawColor(Renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
    SDL_RenderClear(Renderer);

    playerPos := world.player.pos;
    playerVel := world.player.vel;
    playerHealth := world.player.health;
    time := world.time;

    // Current chunk
    currentChunk := getChunkByIndex(world, getChunkIndex(playerPos.x));
    
    if not (world.lastChunk = currentChunk.chunkIndex) then
        loadPlayerChunks(world);


    leftChunk := getChunkByIndex(world, currentChunk.chunkIndex - 1);
    rightChunk := getChunkByIndex(world, currentChunk.chunkIndex + 1);

    blockBelow := isBlockBelow(playerPos, world.player.boundingBox, currentChunk);


    // Enacting layer input
    playerMove(playerVel, blockBelow, playerAction);
    blockAct(playerAction, world);


    // Max running speed
    if playerVel.x > 0.15 then
        playerVel.x := 0.15;
    if playerVel.x < -0.15 then
        playerVel.x := -0.15;
    
    // Terminal Velocity limit
    if playerVel.y > 0.4 then
        playerVel.y := 0.4;
    if playerVel.y < -0.8 then
        playerVel.y := -0.8;

    
    handleCollision(playerVel, playerPos, world.player.boundingBox, currentChunk);
    
    // Updating player position
    playerPos.x := playerPos.x + playerVel.x;
    playerPos.y := playerPos.y + playerVel.y;

    // we update which animation the player will have depending on its velocity and the player input
    if not (playerVel.x = 0) and (playerVel.y = 0) then
        data.playerAction := 2
    else if not(playerVel.y = 0) then
        data.playerAction := 3
     else 
        data.playerAction := 1;

    // Friction
    if playerVel.x > 0 then
        playerVel.x := playerVel.x - 0.074;
    if playerVel.x < 0 then
        playerVel.x := playerVel.x + 0.074;

    // we add a tolerance just in case 
    if (playerVel.x > 0) and (playerVel.x < 0.075) then
        playerVel.x := 0;
    if (playerVel.x < 0) and (playerVel.x > -0.075)then
        playerVel.x := 0;

    // Gravity
    playerVel.y := playerVel.y - 0.05;

    // Player healing
    if playerHealth < 100 then
        playerHealth := playerHealth + 1;
    
    world.player.pos := playerPos;
    world.player.vel := playerVel;
    world.player.health := playerHealth;
    updateMob(world);

    if (time mod 15000) = 0 then
        worldSave(world);
    if time >= 24000 then
        time := 0
    else
        time := time + 1;
    world.time := time;

    displaySky(renderer, world, textures);

    // we calculate the fram of the sprite we have to display 
    data.Fram := data.Fram + 1;
    if data.Fram >= data.PlayerNbFram[data.playerAction]*5 then
    begin
        data.Fram := 1;
        data.playerStep := 1;
    end;
    if data.playerStep < Trunc(data.Fram/5) then
    begin
        data.playerStep := Trunc(data.Fram/5);
    end;


    if abs(trunc(playerPos.x)) - abs(trunc(playerPos.x/100)*100) > 50 then
        // displayBlocks(world, window,currentChunk, rightChunk, renderer)
        displayBlocksTextured(window,currentChunk, rightChunk, world.player.pos, textures, renderer)
    else
        // displayBlocks(world, window,currentChunk, leftChunk, renderer);
        displayBlocksTextured(window,currentChunk, leftChunk, world.player.pos, textures, renderer);

    //displayChunk(currentChunk,renderer, world.player.pos.x > 0); Si on veut afficher le chunk actuel entierement
    
	

    
    displayPlayer(world, window, textures, data, renderer);
    displayMobs(world,window,textures, data,renderer); 
    displayHpBar(world,window,renderer);

    // affichage du nombre de PV
    DisplayText(PChar(IntToStr(playerHealth) +' HP'), window.window,renderer, Font, window.width div 2 - 180,window.height - 145);
    // affichage des coordonnées du joueur
    DisplayText(PChar('X :' + IntToStr(Trunc(playerPos.x)) + ' | Y : ' + IntToStr(Trunc(playerPos.y))), window.window,renderer, Font, trunc(SIZE/2),trunc(SIZE/2));

    displayInventory(world,window, renderer, textures, True);


    world.lastChunk := currentChunk.chunkIndex;

end;
end.