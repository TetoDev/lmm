program test_display;

uses  display,LMMTypes, worldGeneration, util, crt;

procedure test_move_camera(world:TWorld; pos:TPosition);
var input: String;
begin
    input := 'd';
    while (input = 'q') or (input = 'd') or (input = 's') or (input = 'z') do
    begin
        Writeln('q for Left | d for Right');
        Writeln('z for Up | s for Down');
        Write('Which direction : ');
        ReadLn(input);
        ClrScr;
        if input = 'd' then
            pos.x := pos.x + 5
        else if input = 'q' then
            pos.x := pos.x - 5;
        if input = 'z' then
            pos.y := pos.y - 2
        else if input = 's' then
            pos.y := pos.y + 2;
        cameraDisplacement(world,pos,6,20);
    end;
end;

var world:TWorld; seed:LongInt;pos:TPosition;
begin

    pos.x := 10;
    pos.y := 40;
    
    seed := (NewSeed);
    InitialiseWorld(world, seed);
    printChunk(world.chunks[0]);
    test_move_camera(world,pos);
end.