program test_main;
uses fileHandler, LMMTypes, Classes;



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

procedure test_getWorlds();
var i: Integer; worldNames: StringArray;
begin
    worldNames := getWorlds();
    for i:=0 to length(worldNames)-1 do
        writeln(worldNames[i]);
end;

procedure test_loadPlayerChunks();
var world: TWorld;
begin
    world.player.pos.x := 1;
    world.player.pos.y := 2;
    world.name := 'Save 1';
    writeln('Test 1');
    loadPlayerChunks(world);
    worldSave(world);
    world.player.pos.x := 500;
    writeln('Test 2');
    loadPlayerChunks(world);
    writeln('Test 3');
    loadPlayerChunks(world);
end;


begin
    test_worldSave();
    test_getWorlds();
    test_loadPlayerChunks();
end.