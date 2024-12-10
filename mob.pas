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
    mob.pos.x := world.player.pos.x + (Random(200) - 100);
    mob.pos.y := findTop(getChunkByIndex(world, getChunkIndex(mob.pos.x)), Trunc(mob.pos.x));
    mob.vel.x := 0;
    mob.vel.y := 0; 
    AddMobToArray(world.mobs,mob);
    mobData.mobFram:= 1;
    mobData.mobAction := 1;
    mobData.AnimFinished := False;
    AddMobInfoToArray(data.mobsData, mobData);
end;

procedure updateMob(var world:TWorld);
var i, direction : Integer; blockBelow,blockLeft,blockLeftUp,blockRight, blockRightUp:Boolean; stepThrough:TPosition;
begin
    for i := 0 to (Length(world.mobs)-1) do
    begin
        
        stepThrough.x := world.mobs[i].pos.x; 
        stepThrough.y := world.mobs[i].pos.y + 1;

        checkBlockAdjency(world,world.mobs[i].pos, blockLeft, blockBelow, blockRight);
        checkBlockAdjency(world,stepThrough, blockLeftUp, blockBelow, blockRightUp);
        
        if world.mobs[i].direction > 0 then
        begin
            world.mobs[i].direction := world.mobs[i].direction -1 ;
            direction := 1
        end
        else if  world.mobs[i].direction < 0 then
        begin
            world.mobs[i].direction := world.mobs[i].direction + 1 ;
            direction := -1
        end
        else
        begin
            world.mobs[i].direction := random(50) - 25;
            direction := 0;
        end;

        if ((direction > 0) and blockRight and blockRightUp) or ((direction < 0) and blockLeft and blockLeftUp)then
            world.mobs[i].vel.x := 0
        else 
            world.mobs[i].vel.x := 0.05*direction;
        world.mobs[i].pos.x := world.mobs[i].pos.x + world.mobs[i].vel.x;
        world.mobs[i].pos.y := findTop(getChunkByIndex(world, getChunkIndex(world.mobs[i].pos.x )), Trunc(world.mobs[i].pos.x )) - 1;
    end;
end;

end.