program test_acts;

uses LMMTypes, worldGeneration, display, act, crt;

procedure action(world:TWorld;var pos:TPosition;var gravity: Boolean ;var fin:Boolean);
var keyInput: String;input: TActs; savedPos: TPosition;
begin
    Writeln('q for Left | d for Right');
    Writeln('z to Jump | s to crouch');
    Write('Which direction : ');
    ReadLn(keyInput);
    input := handleInput(keyInput);
    ClrScr;
    savedPos := pos;

    if (input = WALK_RIGHT) and (world.chunks[1].layout[Round(pos.x) + 1][Round(pos.y)] = 0) then
        pos.x := pos.x + 1

    else if (input = WALK_LEFT) and (world.chunks[1].layout[Round(pos.x) - 1][Round(pos.y)] = 0) then
        pos.x := pos.x - 1;

    if (gravity = True) and (world.chunks[1].layout[Round(pos.x)][Round(pos.y - 1)] = 0) then
    begin
        pos.y := pos.y - 1;
    end;

    if (gravity = False) and (world.chunks[1].layout[Round(pos.x)][Round(pos.y - 1)] = 0) then
    begin
        gravity := True
    end;
    if (gravity = True) and (world.chunks[1].layout[Round(pos.x)][Round(pos.y - 1)] > 0) then
    begin
        gravity := False
    end;

    if (input = JUMP) and (world.chunks[1].layout[Round(pos.x)][Round(pos.y - 1)] > 0) and ( gravity = False) then
    begin
        pos.y := pos.y + 1;
        gravity := True;
    end
    else if input = CROUCH then
        fin := True;

    world.chunks[1].layout[Round(savedPos.x)][Round(savedPos.y)] := 0;
    world.chunks[1].layout[Round(pos.x)][Round(pos.y)] := 9;
end;

function findTop(chunk:TChunk; x:Integer):Integer;
var i:Integer;
begin
    findTop := 0;
    i := 0;
    while (i < 99) and (findTop = 0) do 
    begin
        if chunk.layout[x][i] = 0 then 
            findTop := i;
        i := i + 1;
    end;
end;

var world:TWorld; seed:LongInt; pos:TPosition; fin,gravity:Boolean; 
begin
    fin := false;
    gravity := False;
    seed := NewSeed();
    InitialiseWorld(world,seed);
    pos.x := 49;
    pos.y := findTop(world.chunks[1],Round(pos.x));
    repeat
        action(world, pos, gravity, fin);
        cameraDisplacement(world,pos,10,30);
        WriteLn('X: ', Round(pos.x),', Y: ', Round(pos.y), ', Gravity: ', gravity )
	until fin;
end.