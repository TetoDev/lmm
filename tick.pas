unit tick;

interface

uses LMMTypes, fileHandler, act, SysUtils, display, sdl2, util;

procedure tick(var world: TWorld; playerAction: TPlayerAction; var renderer:  PSDL_Renderer);

implementation

procedure tick(var world: TWorld; playerAction: TPlayerAction; var renderer:  PSDL_Renderer);
var playerPos: TPosition;
    playerVel: TVelocity;
    playerHealth, time: Integer;
    blockLeft, blockRight, blockBelow: Boolean;
    lastChunkIndex, x, y: Integer;
    currentChunk, leftChunk, rightChunk: TChunk;
begin
    playerPos := world.player.pos;
    playerVel := world.player.vel;
    playerHealth := world.player.health;
    time := world.time;

    // Player's BLOCK chunk coordinates
    x := Trunc(playerPos.x) mod 100;
    y := Trunc(playerPos.y);

    // Current chunk
    currentChunk := getChunkByIndex(world, getChunkIndex(playerPos.x));

    leftChunk := getChunkByIndex(world, currentChunk.chunkIndex - 1);
    rightChunk := getChunkByIndex(world, currentChunk.chunkIndex + 1);


    // Checking block adjacency for collision checking
    if x = 0 then
        blockLeft := leftChunk.layout[99][y] > 0
    else
        blockLeft := currentChunk.layout[x - 1][y] > 0;
    
    if x = 99 then
        blockRight := rightChunk.layout[0][y] > 0
    else
        blockRight := currentChunk.layout[x + 1][y] > 0;


    blockBelow := currentChunk.layout[x][y-1] > 0;

    // Enacting layer input
    playerMove(playerVel, blockBelow, playerAction);
    blockAct(playerAction, world);

    // Collision detection
    if blockBelow then
        if playerVel.y < 0 then
            playerVel.y := 0;
    if blockLeft then
        if playerVel.x < 0 then
            playerVel.x := 0;
    if blockRight then
        if playerVel.x > 0 then
            playerVel.x := 0;

    // Max running speed
    if playerVel.x > 0.5 then
        playerVel.x := 0.5;
    if playerVel.x < -0.5 then
        playerVel.x := -0.5;
    
    // Terminal Velocity limit
    if playerVel.y > 1 then
        playerVel.y := 1;
    if playerVel.y < -2 then
        playerVel.y := -2;
    
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

    // Save world on chunk change
    //if not (lastChunkIndex = currentChunk.chunkIndex) then
    //begin
    //    AddIntToArray(world.unsavedChunks, lastChunkIndex);
    //    worldSave(world);
    //end;

    if (time mod 35000) = 0 then
        worldSave(world);
    if time = 24000 then
        time := 0
    else
        time := time + 1;
    
    lastChunkIndex := currentChunk.chunkIndex;

    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    SDL_RenderClear(renderer);
    displayChunk(currentChunk, renderer);
    displayPlayer(world, renderer);

    
	SDL_delay(1000 div 60); // pour caper le nombre de fps 60 

end;
end.