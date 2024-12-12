unit mob;

interface

uses LMMTypes, util, act, sysutils;

procedure generateMob(var world:TWorld; var data:TAnimationData);

procedure updateMob(var world:TWorld; var data:TAnimationData);

procedure spawnMobs(var world:TWorld; var data:TAnimationData);

implementation

procedure generateMob(var world:TWorld; var data:TAnimationData);
var mob:TMob; mobData:TMobTexture;
begin
    mob.health := 100;
    mob.pos.x := world.player.pos.x + (Random(100) - 50);
    mob.pos.y := findTop(getChunkByIndex(world, getChunkIndex(mob.pos.x)), Trunc(mob.pos.x));
    mob.vel.x := 0;
    mob.vel.y := 0; 
    mob.boundingBox.width := 0.6;
    mob.boundingBox.height := 0.25;
    mob.lastAttack := 0;
    mob.lastDamaged := 0;
    mob.id := world.mobsGenerated + 1;
    AddMobToArray(world.mobs,mob);
    mobData.mobId := mob.id;
    mobData.mobFram:= 1;
    mobData.mobAction := 1;
    mobData.AnimFinished := False;
    mob.direction := 0;
    AddMobInfoToArray(data.mobsData, mobData);
end;

procedure spawnMobs(var world:TWorld; var data:TAnimationData);
var spawnCriterion: Boolean;
begin
    if world.time > 19000 then
        spawnCriterion := (Random(200) < 1)
    else
        spawnCriterion := (Random(4000) < 1);
    
    if spawnCriterion then
        generateMob(world, data);
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
    if (checkHorizontalCollision(br, chunk, true, true) or checkHorizontalCollision(bl, chunk, false, true)) and isBlockBelow(mob.pos, mob.boundingBox, chunk) and (mob.lastJump > 40) then
    begin
        mob.lastJump := 0;
        mob.vel.y := mob.vel.y + 0.5;
    end;
    mob.lastJump := mob.lastJump + 1;

    // Gravity
    mob.vel.y := mob.vel.y - 0.1;

    // Follow the player if close enough
    if (abs(playerPos.x - mob.pos.x) < 10) and (abs(playerPos.y - mob.pos.y) < 10) then
    begin
        if playerPos.x - mob.pos.x > 0 then
            mob.vel.x := 0.05
        else
            mob.vel.x := -0.05;
    end
    else
        mob.vel.x := 0;

    // Check for collisions so that mobs don't go through walls (allegedly)
    handleCollision(mob.vel, mob.pos, mob.boundingBox, chunk);
    mob.pos.x := mob.pos.x + mob.vel.x;
    mob.pos.y := mob.pos.y + mob.vel.y;
end;

procedure mobAttack(player: TPlayer; var mob: TMob; var playerHealth: Integer; time, damage: Integer);
begin
    // Attack if close enough and if its last attack has been more than 15 ticks ago
    if (abs(playerPos.pos.x - mob.pos.x) < 0.1) and (abs(player.pos.y - mob.pos.y) < 0.8) then
        if abs(time - mob.lastAttack) > 15 then
        begin
            inflictDamage(playerHealth, 10);
            player.lastDamaged := time;
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

procedure destroyMob(var world:TWorld; var data: TAnimationData ; index: Integer);
var i, limit: Integer;
begin
    limit := Length(world.mobs) - 1;

    for i := 0 to Length(data.mobsData) - 1 do
        if data.mobsData[i].mobId = world.mobs[index].id then
            begin
            delete(data.mobsData, i,1);
            break;
            end;

    for i := index to limit - 1 do
        world.mobs[i] := world.mobs[i + 1];

    SetLength(world.mobs, limit);
end;


procedure updateMob(var world:TWorld; var data:TAnimationData);
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
        data.mobsData[i].mobAction := 1;
        updateDirection(mob);
        mobAttack(world.player, mob, world.player.health, world.time, 10);

        writeln('Mob ', i, ' health: ', mob.health);

        if mob.health <= 0 then
        begin
            destroyMob(world, data, i-j);
            j := j + 1;
        end
        else
            world.mobs[i-j] := mob;
    end;
end;

end.