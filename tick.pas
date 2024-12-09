unit tick;

interface

uses LMMTypes, fileHandler, act, SysUtils, display, sdl2, util, worldGeneration;

procedure tick(var world: TWorld; window:TWindow; playerAction: TPlayerAction; var renderer:  PSDL_Renderer; textures: TTextures);

implementation

procedure tick(var world: TWorld; window:TWindow; playerAction: TPlayerAction; var renderer:  PSDL_Renderer; textures: TTextures);
var playerPos: TPosition;
    playerVel: TVelocity;
    playerHealth, time: Integer;
    blockBelow: Boolean;
    x, y: Integer;
    currentChunk: TChunk;
    leftChunk, rightChunk: TChunk;
begin
    playerPos := world.player.pos;
    playerVel := world.player.vel;
    playerHealth := world.player.health;
    time := world.time;

    // Player's BLOCK chunk coordinates
    x := Trunc(playerPos.x) mod 100;

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
    if playerVel.x > 0.3 then
        playerVel.x := 0.3;
    if playerVel.x < -0.3 then
        playerVel.x := -0.3;
    
    // Terminal Velocity limit
    if playerVel.y > 1 then
        playerVel.y := 1;
    if playerVel.y < -2 then
        playerVel.y := -2;

    
    handleCollision(playerVel, playerPos, world.player.boundingBox, currentChunk);
    
    // Updating player position
    playerPos.x := playerPos.x + playerVel.x;
    playerPos.y := playerPos.y + playerVel.y;


        
    // Friction
    if blockBelow then
    begin
        if playerVel.x > 0 then
            playerVel.x := playerVel.x - 0.1;
        if playerVel.x < 0 then
            playerVel.x := playerVel.x + 0.1;

        if (playerVel.x > 0) and (playerVel.x < 0.1) then
            playerVel.x := 0;
        if (playerVel.x < 0) and (playerVel.x > -0.1)then
            playerVel.x := 0;
    end
    else
    begin
        if playerVel.x > 0 then
            playerVel.x := playerVel.x - 0.05;
        if playerVel.x < 0 then
            playerVel.x := playerVel.x + 0.05;

        if (playerVel.x > 0) and (playerVel.x < 0.1) then
            playerVel.x := 0;
        if (playerVel.x < 0) and (playerVel.x > -0.1)then
            playerVel.x := 0;
    end;
    // Gravity
    playerVel.y := playerVel.y - 0.1;


    world.player.pos := playerPos;
    world.player.vel := playerVel;
    world.player.health := playerHealth;


    if (time mod 3573876) = 0 then
        worldSave(world);
    if time = 24000 then
        time := 0
    else
        time := time + 1;


    if x > 50 then
        // displayBlocks(world, window,currentChunk, rightChunk, renderer)
        displayBlocksTextured(window,currentChunk, rightChunk, world.player.pos, textures, renderer)
    else
        // displayBlocks(world, window,currentChunk, leftChunk, renderer);
        displayBlocksTextured(window,currentChunk, leftChunk, world.player.pos, textures, renderer);

    //displayChunk(currentChunk,renderer, world.player.pos.x > 0); Si on veut afficher le chunk actuel entierement
    
	SDL_delay(1000 div 60); // pour caper le nombre de fps 60 

    
    displayPlayer(world, window,renderer, False);
    displayInventory(world,window, renderer, textures, True);

    world.lastChunk := currentChunk.chunkIndex;

end;
end.