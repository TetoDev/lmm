program test_display;

uses  display,LMMTypes, worldGeneration;

procedure test_show_world(var chunk:TChunk;seed:Integer;pos:TPosition);
begin
  chunkShapeGeneration(chunk,seed);
  printChunk(chunk);
  WriteLn();
  WriteLn();
end;

var chunk:TChunk;seed:Integer; input:String;pos:TPosition;
begin
    input := 'd';
    pos.x := 0;
    pos.y := 40;
    writeln('Hello, world!');
    seed := (NewSeed);
    test_show_world(chunk,seed,pos);
    while (input = 'd') or (input = 'l') do
    begin
        Write('Which direction (L for Left| D for Right) : ');
        ReadLn(input);
        if input = 'd' then
            pos.x := pos.x + 5
        else if input = 'l' then
            pos.x := pos.x - 5;
        printPerspectiveChunk(chunk,pos,4,10);
    end;
end.