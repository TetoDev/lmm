unit tick;

interface

uses LMMTypes, fileHandler, act, SysUtils, display;

procedure tick(var world: TWorld; playerAction: TPlayerAction);

implementation

procedure tick(var world: TWorld; playerAction: TPlayerAction);
var playerPos: TPosition;
    playerVel: TVelocity;
    playerHealth, time: Integer;
    blockLeft, blockRight, blockBelow: Boolean;
begin
    playerPos := world.player.pos;
    playerVel := world.player.vel;
    playerHealth := world.player.health;
    time := world.time;
   
    if (Round(playerPos.x) - 1) >= 0 then
        blockLeft := world.chunks[1].layout[Round(playerPos.x) - 1][Trunc(playerPos.y)] > 0 // BUG: playerPos.x or playerPos.y will round wierldly and stop the player from moving in any direction TRUNCATE MIGHT ALSO BE WRONG BUT I'M NOT SURE
    else
        blockLeft := False; // BUG: playerPos.x or playerPos.y will round wierldly and stop the player from moving in any direction TRUNCATE MIGHT ALSO BE WRONG BUT I'M NOT SURE

    if (Round(playerPos.x) + 1) <= 99 then
        blockRight := world.chunks[1].layout[Round(playerPos.x) + 1][Trunc(playerPos.y)] > 0
    else
        blockRight := False;


    blockBelow := world.chunks[1].layout[Round(playerPos.x)][Trunc(playerPos.y-1)] > 0;

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
    if playerVel.x > 0 then
        playerVel.x := playerVel.x - 0.1;
    if playerVel.x < 0 then
        playerVel.x := playerVel.x + 0.1;

    if (playerVel.x > 0) and (playerVel.x < 0.1) then
        playerVel.x := 0;
    if (playerVel.x < 0) and (playerVel.x > -0.1)then
        playerVel.x := 0;

    // Gravity
    playerVel.y := playerVel.y - 0.1;


    world.player.pos := playerPos;
    world.player.vel := playerVel;
    world.player.health := playerHealth;


    if (time mod 3500) = 0 then
        worldSave(world);
    if time = 24000 then
        time := 0
    else
        time := time + 1;
end;
end.