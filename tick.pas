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
    leftChunk, rightChunk, sideChunk: TChunk;
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
    playerMove(world.player, playerVel, blockBelow, playerAction, world.time);
    blockAct(playerAction, world);


    // Max running speed, depending on if the player is attacking or not
    if not world.player.attacking then
        if (playerVel.x > 0.15) then
            playerVel.x := 0.15;
        if (playerVel.x < -0.15) and (not world.player.attacking) then
            playerVel.x := -0.15
    else
    begin
        if (playerVel.x > 0.20) then
            playerVel.x := 0.20;
        if (playerVel.x < -0.20) then
            playerVel.x := -0.20;
    end;
    
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
    if world.player.attacking then
      data.playerAction := 4
    else if (abs(world.time-world.player.lastDamaged) <= 18)then
        data.playerAction := 5
    else if not (playerVel.x = 0) and (playerVel.y = 0) then
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
    playerVel.y := playerVel.y - 0.04;

    // Player healing
    if playerHealth < 100 then
        playerHealth := playerHealth + 1;
    
    world.player.pos := playerPos;
    world.player.vel := playerVel;
    world.player.health := playerHealth;


    updateMob(world, data);
    spawnMobs(world, data);
    resetPlayerAttack(world.player, world.time, world);

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

    if playerPos.x > 0.0 then
    begin
        if abs(trunc(playerPos.x)) - abs(trunc(playerPos.x/100)*100) > 50 then
            sideChunk := rightChunk // Si positif et 50% a droite
        else
            sideChunk := leftChunk // Si positif et 50% a gauche
    end
    else
    begin
        if abs(trunc(playerPos.x)) - abs(trunc(playerPos.x/100)*100) > 50 then
            sideChunk := leftChunk // Si negatif et 50% a droite
        else
            sideChunk := rightChunk; // Si negatif et 50% a gauche
    end;

        
    // On affiche le monde avec les textures charges dans TTextures, on passe comme argument le chunk dans lequel le player se trouve et aussi celui qui est a cote.
    displayBlocksTextured(window,currentChunk, sideChunk, world.player.pos, textures, renderer);
    //affichage du joueur
    displayPlayer(world, window, textures, data, renderer);
    //affichage des mobs
    displayMobs(world,window,textures, data,renderer); 

    //affichage d'information supplémentaire
    displayHpBar(world,window,renderer);
    displayInventory(world,window, renderer, textures);
    // affichage du nombre de PV
    DisplayText(PChar(IntToStr(playerHealth) +' HP'), window.window,renderer, Font, window.width div 2 - 180,window.height - 145);
    // affichage des coordonnées du joueur
    DisplayText(PChar('X :' + IntToStr(Trunc(playerPos.x)) + ' | Y : ' + IntToStr(Trunc(playerPos.y))), window.window,renderer, Font, trunc(SIZE/2),trunc(SIZE/2));


    world.lastChunk := currentChunk.chunkIndex;

end;
end.