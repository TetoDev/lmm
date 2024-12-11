unit mob;

interface

uses LMMTypes, util, act, sysutils;

procedure generateMob(var world:TWorld; var data:TAnimationData);

procedure updateMob(var world:TWorld);

implementation

procedure generateMob(var world:TWorld; var data:TAnimationData);
var mob:TMob; mobData:TMobTexture;
begin
    mob.health := 100;
    mob.pos.x := world.player.pos.x + 2;//(Random(200) - 100);
    mob.pos.y := findTop(getChunkByIndex(world, getChunkIndex(mob.pos.x)), Trunc(mob.pos.x));
    mob.vel.x := 0;
    mob.vel.y := 0; 
    mob.boundingBox.width := 0.5;
    mob.boundingBox.height := 0.5;
    mob.lastAttack := 0;
    AddMobToArray(world.mobs,mob);
    mobData.mobFram:= 1;
    mobData.mobAction := 1;
    mobData.AnimFinished := False;
    mob.direction := 0;
    AddMobInfoToArray(data.mobsData, mobData);
end;

procedure mobMove (playerPos: TPosition; var mob: TMob; chunk: TChunk);
var br, bl: TPosition;
begin
    // Bottom right bounding box corner
    br.x := mob.pos.x + mob.boundingBox.width;
    br.y := mob.pos.y - mob.boundingBox.height;
    // Bottom left bounding box corner
    bl.x := mob.pos.x;
    bl.y := mob.pos.y - mob.boundingBox.height;

    // Check horizontal collisions for jumping
    if checkHorizontalCollision(br, chunk, true, true) or checkHorizontalCollision(bl, chunk, false, true) then
        mob.vel.y := mob.vel.y + 0.4;

    // Gravity
    mob.vel.y := mob.vel.y - 0.1;

    // Follow the player if close enough
    if (abs(playerPos.x - mob.pos.x) < 10) and (abs(playerPos.y - mob.pos.y) < 10) then
    begin
        if playerPos.x - mob.pos.x > 0 then
            mob.vel.x := 0.2
        else
            mob.vel.x := -0.2;
    end
    else
        mob.vel.x := 0;

    // Check for collisions so that mobs don't go through walls (allegedly)
    handleCollision(mob.vel, mob.pos, mob.boundingBox, chunk);

    mob.pos.x := mob.pos.x + mob.vel.x;
    mob.pos.y := mob.pos.y + mob.vel.y;
end;

procedure mobAttack(playerPos: TPosition; var mob: TMob; var playerHealth: Integer; time, damage: Integer);
begin
    // Attack if close enough and if its last attack has been more than 15 ticks ago
    if (abs(playerPos.x - mob.pos.x) < 0.1) and (abs(playerPos.y - mob.pos.y) < 0.8) then
        if abs(time - mob.lastAttack) > 15 then
        begin
            inflictDamage(playerHealth, 10);
            mob.lastAttack := time;
        end;
end;

procedure updateDirection (var mob: TMob);
begin
    if mob.vel.x > 0 then
        mob.direction := 1
    else
        mob.direction := -1;
end;


procedure updateMob(var world:TWorld);
var i, j, limit: Integer; mob: TMob; chunk: TChunk; playerPos: TPosition;
begin
    playerPos := world.player.pos;
    limit := Length(world.mobs) - 1;
    j := 0;

    for i := 0 to limit do
    begin
        mob := world.mobs[i-j];
        chunk := getChunkByIndex(world, getChunkIndex(mob.pos.x));

        mobMove(playerPos, mob, chunk);
        updateDirection(mob);
        mobAttack(playerPos, mob, world.player.health, world.time, 10);

        if mob.health < 1 then
        begin
            delete(world.mobs,i-j,1);
            limit := limit - 1;
            j := j + 1;
        end;

        // world.mobs[i] := mob;
    end;
end;

end.