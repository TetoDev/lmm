program test_main;
uses fileHandler, LMMTypes;



procedure test_worldSave();
var
    world: TWorld;
    chunk, chunk2, chunk3: TChunk;
    chunklist: ChunkArray;
    i, j: Integer;
begin
    world.name := 'TestWorld';
    world.time := 12345;
    world.player.pos.x := 0;
    world.player.pos.y := 2;
    world.player.vel.x := 3;
    world.player.vel.y := 4;
    world.player.health := 100;

    chunk.chunkIndex := 4;
    chunk2.chunkIndex := 2;
    chunk3.chunkIndex := 3;
    SetLength(chunk.layout, 100, 100);
    SetLength(chunk2.layout, 100, 100);
    SetLength(chunk3.layout, 100, 100);

    for i := 0 to 99 do
    begin
        for j := 0 to 99 do
        begin
            chunk.layout[i][j] := 1;
            chunk2.layout[i][j] := i + j;
            chunk3.layout[i][j] := i + j;
        end;
    end;

    world.chunks := [chunk, chunk2, chunk3];
    world.unsavedChunks := [4];

    worldSave(world);
end;


begin
    writeln('Hello, world!');
    test_worldSave();
end.