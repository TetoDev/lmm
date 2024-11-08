unit Game;

interface

uses LMMTypes, fileHandler, act;

uses
    SysUtils;

procedure tick(world: TWorld; playerAction: TPlayerAction);
procedure game(world: TWorld);

implementation

procedure tick(world: TWorld; playerAction: TPlayerAction);
var playerPos: TPosition;
    playerVel: TVelocity;
    playerHealth, time: Integer;
    blockLeft, blockRight, blockBelow: Boolean;
begin
    playerPos := world.player.pos;
    playerVel := world.player.vel;
    playerHealth := world.player.health;
    time := world.time;

    blockLeft := world.chunks[1].layout[Round(playerPos.x) - 1][Trunc(playerPos.y)] > 0; // BUG: playerPos.x or playerPos.y will round wierldly and stop the player from moving in any direction TRUNCATE MIGHT ALSO BE WRONG BUT I'M NOT SURE
    blockRight := world.chunks[1].layout[Round(playerPos.x) + 1][Trunc(playerPos.y)] > 0;
    blockBelow := world.chunks[1].layout[Round(playerPos.x)][Trunc(playerPos.y)] > 0;

    // Enacting layer input
    act(playerVel, blockBelow, playerAction);
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
    if playerVel.x > 5 then
        playerVel.x := 5;
    if playerVel.x < -5 then
        playerVel.x := -5;
    
    // Terminal Velocity
    if playerVel.y > 100 then
        playerVel.y := 100;
    if playerVel.y < -100 then
        playerVel.y := -100;
    
    // Updating player position
    playerPos.x := playerPos.x + playerVel.x;
    playerPos.y := playerPos.y + playerVel.y;

    // Friction
    if playerVel.x > 0 then
        playerVel.x := playerVel.x - 0.1;
    if playerVel.x < 0 then
        playerVel.x := playerVel.x + 0.1;

    // Gravity
    playerVel.y := playerVel.y - 9.81/60;
    
    
    playerHealth := playerHealth + 1; // REMOVE THIS LINE eventually


    world.player.pos := playerPos;
    world.player.vel := playerVel;
    world.player.health := playerHealth;


    if time = 24000 then
        time := 0
        worldSave(world);
    else
        time := time + 1;
end;

procedure game(world: TWorld);
var acts: TActs;
begin
    acts := handleInput();
    tick(world, acts);
    // Display
end;

end.