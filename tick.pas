unit tick;

interface

uses LMMTypes, fileHandler, act, SysUtils, display, sdl2, sdl2_ttf, util, worldGeneration, mob, menu;

procedure tick(var world: TWorld; window:TWindow; playerAction: TPlayerAction; var renderer:  PSDL_Renderer; var textures: TTextures; var data:TAnimationData; Font: PTTF_Font;key:TKey; audio: TAudio);

implementation

procedure tick(var world: TWorld; window:TWindow; playerAction: TPlayerAction; var renderer:  PSDL_Renderer; var textures: TTextures; var data:TAnimationData; Font: PTTF_Font;key:TKey; audio: TAudio);
var 
    time: Integer;
    currentChunk: TChunk;
begin
    SDL_SetRenderDrawColor(Renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
    SDL_RenderClear(Renderer);

    time := world.time;

    // Current chunk
    currentChunk := getChunkByIndex(world, getChunkIndex(world.player.pos.x));
    
    if not (world.lastChunk = currentChunk.chunkIndex) then
        loadPlayerChunks(world);

    // Update player
    updatePlayer(world,playerAction,data, audio);
    // Update mobs
    updateMob(world, data, audio);
    spawnMobs(world, data);
    resetPlayerAttack(world.player, world.time, world);

    // Update world time
    if (time mod 15000) = 0 then
        worldSave(world);
    if time >= 24000 then
        time := 0
    else
        time := time + 1;
    world.time := time;


    // we calculate the fram of the sprite we have to display 
    updateFrame(data);
    // we display the game 
    DisplayGame(window,renderer, Font,textures, data, world);
    
    // we update last chunk index
    world.lastChunk := currentChunk.chunkIndex;
end;
end.