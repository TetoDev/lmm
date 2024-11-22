unit Util;

{$mode objfpc}{$H+}

interface
uses LMMTypes;


procedure AddIntToArray(var Arr: IntArray; const Element: Integer);
procedure AddActToArray(var Arr: ActsArray; Element: TActs);
function IsIntOnArray(Arr: IntArray; const Element: Integer): Boolean;
function getChunkByIndex(world: TWorld; chunkIndex: Integer): TChunk;
procedure AddChunkToArray(var Arr: ChunkArray; const Element: TChunk);
function findTop(chunk:TChunk; x:Integer):Integer;


implementation

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

end.