unit Util;

{$mode objfpc}{$H+}

interface
uses LMMTypes;


procedure AddIntToArray(var Arr: IntArray; const Element: Integer);
procedure AddActToArray(var Arr: ActsArray; Element: TActs);
procedure AddMobToArray(var Arr: mobArray; const Element: TMob);
procedure AddMobInfoToArray(var Arr: mobTextureArray; const Element: TMobTexture);
procedure AddIntIfNotOnArray(var Arr: IntArray; const Element: Integer);
function IsIntOnArray(Arr: IntArray; const Element: Integer): Boolean;
function getChunkByIndex(world: TWorld; chunkIndex: Integer): TChunk;
procedure AddChunkToArray(var Arr: ChunkArray; const Element: TChunk);
function getChunkIndex(x : Real): Integer;
function findTop(chunk:TChunk; x:Integer):Integer;
procedure reinsertChunk(var world: TWorld; chunk: TChunk);
procedure checkBlockAdjency(world:TWorld; pos:TPosition; var blockLeft,blockBelow,blockRight :Boolean);


implementation

procedure reinsertChunk(var world: TWorld; chunk: TChunk);
var i: Integer;
begin
    for i := 0 to Length(world.chunks) - 1 do
    begin
        if world.chunks[i].chunkIndex = chunk.chunkIndex then
        begin
            world.chunks[i] := chunk;
            Exit;
        end;
    end;
end;

function getChunkIndex(x : Real):Integer;
begin
    if 0 <= x then
        getChunkIndex := Trunc(x / 100)
    else 
        getChunkIndex := Trunc(x / 100)-1;
end;

procedure AddIntToArray(var Arr: IntArray; const Element: Integer);
begin
    SetLength(Arr, Length(Arr) + 1);
    Arr[High(Arr)] := Element;
end;

procedure AddActToArray(var Arr: ActsArray; Element: TActs);
begin
    SetLength(Arr, Length(Arr) + 1);
    Arr[High(Arr)] := Element;
end;

procedure AddChunkToArray(var Arr: ChunkArray; const Element: TChunk);
begin
    SetLength(Arr, Length(Arr) + 1);
    Arr[High(Arr)] := Element;
end;

procedure AddMobToArray(var Arr: mobArray; const Element: TMob);
begin
    SetLength(Arr, Length(Arr) + 1);
    Arr[High(Arr)] := Element;
end;

procedure AddMobInfoToArray(var Arr: mobTextureArray; const Element: TMobTexture);
begin
    SetLength(Arr, Length(Arr) + 1);
    Arr[High(Arr)] := Element;
end;

function IsIntOnArray(Arr: IntArray; const Element: Integer): Boolean;
var
    i: Integer;
begin
    Result := False;
    for i := 0 to Length(Arr) - 1 do
    begin
        if Arr[i] = Element then
        begin
            Result := True;
            Exit;
        end;
    end;
end;

procedure AddIntIfNotOnArray(var Arr: IntArray; const Element: Integer);
begin
    if not IsIntOnArray(Arr, Element) then
    begin
        AddIntToArray(Arr, Element);
    end;
end;

function getChunkByIndex(world: TWorld; chunkIndex: Integer): TChunk;
var
    i: Integer;
begin
    Result := Default(TChunk);
    for i := 0 to Length(world.chunks) - 1 do
    begin
        if world.chunks[i].chunkIndex = chunkIndex then
        begin
            Result := world.chunks[i];
            Exit;
        end;
    end;
end;

function findTop(chunk:TChunk; x:Integer):Integer;
var i:Integer;xRelatif:Integer;
begin
    findTop := 0;
    i := 0;
    if x > 0 then
        xRelatif:= x  - 100 * Trunc(x / 100)
    else 
        xRelatif:= 99 - (abs(x)  - 100 * Trunc(abs(x) / 100));
    while (i < 99) and (findTop = 0) do 
    begin
        if chunk.layout[xRelatif][i] = 0 then 
        begin
            findTop := i;
            Exit
        end;
        i := i + 1;
    end;
end;

procedure checkBlockAdjency(world:TWorld; pos:TPosition; var blockLeft,blockBelow,blockRight :Boolean);
var x,y:Integer; currentChunk,leftChunk,rightChunk:TChunk;
begin
    x := Trunc(pos.x) mod 100;
    y := Trunc(pos.y);

    // Current chunk
    currentChunk := getChunkByIndex(world, getChunkIndex(pos.x));
    leftChunk := getChunkByIndex(world, currentChunk.chunkIndex - 1);
    rightChunk := getChunkByIndex(world, currentChunk.chunkIndex + 1);

    // Checking block adjacency for collision checking
    if x = 0 then
        blockLeft := leftChunk.layout[99][y] > 0
    else
        blockLeft := currentChunk.layout[abs(x - 1)][y] > 0;
    
    if x = 99 then
        blockRight := rightChunk.layout[0][y] > 0
    else
        blockRight := currentChunk.layout[abs(x + 1)][y] > 0;

    blockBelow := currentChunk.layout[abs(x)][y-1] > 0;
end;

end.