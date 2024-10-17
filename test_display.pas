program test_display;

uses  display,LMMTypes, worldGeneration, util;

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
        if input = 'd' then
            pos.x := pos.x + 5
        else if input = 'q' then
            pos.x := pos.x - 5;
        if input = 'z' then
            pos.y := pos.y - 2
        else if input = 's' then
            pos.y := pos.y + 2;
        cameraDisplacement(world,pos,4,20);
    end;
end;

var chunkLeft,chunkMid,chunkRight:TChunk; world:TWorld; seed:Integer;pos:TPosition;
begin

    pos.x := 10;
    pos.y := 40;

    chunkLeft.chunkIndex := -1;
    chunkMid.chunkIndex:= 0;
    chunkRight.chunkIndex := 1;
    AddChunkToArray(world.chunks, chunkLeft);
    AddChunkToArray(world.chunks, chunkMid);
    AddChunkToArray(world.chunks, chunkRight);
    seed := (NewSeed);
    chunkShapeGeneration(world.chunks[0],seed);
    chunkShapeGeneration(world.chunks[1],seed);
    chunkShapeGeneration(world.chunks[2],seed);

end.