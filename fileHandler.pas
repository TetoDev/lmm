unit fileHandler;

// Admettre des strings de plus de 255 caractères
{$H+}

interface

uses
    SysUtils, Classes, LMMTypes, Util, worldGeneration;


procedure worldSave(world: TWorld);
procedure deleteWorld(const worldName: String);
function worldInit(worldName: string): TWorld;
procedure loadPlayerChunks(var world: TWorld);
function getWorlds():StringArray;

implementation

procedure saveToIndex(worldName: String);
var index: Text;
begin
    assign(index, 'world_index.txt');
    append(index);

    writeln(index, worldName);

    close(index)
end;

// Convertir un chunk en string pour le sauvegarder dans un fichier texte dans une ligne
function stringifyChunk(chunk: TChunk): String;
var
    i, j: Integer;
    chunkString: String;
begin
    chunkString := IntToStr(chunk.chunkIndex) + ';[';
    for i := 0 to length(chunk.layout) - 1 do
    begin
        chunkString += '[';
        for j := 0 to length(chunk.layout[i]) - 1 do
        begin
            chunkString += IntToStr(chunk.layout[i][j]);
            if j <> length(chunk.layout[i]) - 1 then
            begin
                chunkString += '-'; // I CHANGED THIS LAST TIME WTF I DONT KNOW WHAT IS GOING ON
            end;
        end;
        chunkString += ']';
        if i <> length(chunk.layout) - 1 then
        begin
            chunkString += ',';
        end;
    end;
    chunkString += ']';
    stringifyChunk := chunkString;
end;

procedure worldSave(world: TWorld);
var
    temp: Text;
    worldStringList: TStringList;
    line: TStringArray;
    i: Integer;
    unsavedChunk: TChunk;
    alreadySavedChunkIndexes: IntArray;
begin
    assign(temp, 'worlds/' + world.name + 'temp.txt');
    rewrite(temp);

    // Sauvegarde des informations du monde et de la position du joueur
    writeln(temp, world.name, ';', world.time); // line 0
    writeln(temp, Trunc(world.player.pos.x), ';', Trunc(world.player.pos.y), ';', Trunc(world.player.vel.x), ';', Trunc(world.player.vel.y), ';', world.player.health);

    // Sauvegarde des chunks non sauvegardés (tous les chunks qui ont été charges par le joueur depuis la dernière sauvegarde)
    for i := 0 to length(world.unsavedChunks)-1 do
    begin
        unsavedChunk := getChunkByIndex(world, world.unsavedChunks[i]); // Chumks may unload before saving TO FIXXX
        writeln(temp, stringifyChunk(unsavedChunk));
        AddIntToArray(alreadySavedChunkIndexes, unsavedChunk.chunkIndex);
    end;
    delete(world.unsavedChunks, 0, length(world.unsavedChunks) - 1); // FLUSHING ALREADY SAVED CHUNKS

    // Verifier si le monde a déjà été sauvegardé avant, si oui, on ajoute les chunks déjà sauvegardés précédemment
    if FileExists('worlds/' + world.name + '.txt') then
    begin
        worldStringList := TStringList.Create();
        worldStringList.LoadFromFile('worlds/' + world.name + '.txt');

        // On commence depuis le 3e (2 ligne) élément car le premier élément est le nom du monde et le temps et le deuxième est la position du joueur
        for i := 2 to worldStringList.Count-1 do
        begin
            line := worldStringList.strings[i].Split(';');
            if not IsIntOnArray(alreadySavedChunkIndexes, StrToInt(line[0])) then
            begin
                writeln(temp, worldStringList.strings[i]);
            end;
        end;

        freeandnil(worldStringList);
        DeleteFile('worlds/' + world.name + '.txt');
    end;

    close(temp);
    RenameFile('worlds/' + world.name + 'temp.txt', 'worlds/' + world.name + '.txt');

    // Avec cette fonction, on sauvegarde le monde dans un fichier texte avec le suivant format:
    // Nom du monde;temps
    // x;y;vx;vy;vie
    // 12;[[1,2,3],[4,5,6],[7,8,9]]
    // -50;[[1,2,3],[4,5,6],[7,8,9]]
    // 4;[[1,2,3],[4,5,6],[7,8,9]]
    // 15;[[1,2,3],[4,5,6],[7,8,9]]
    // -4;[[1,2,3],[4,5,6],[7,8,9]]
    // 17;[[1,2,3],[4,5,6],[7,8,9]]
end;

procedure loadPlayerChunks(var world: TWorld);
var
    worldStringList: TStringList;
    line: TStringArray;
    i, j, k: Integer;
    chunk: TChunk;
    rootChunkIndex: Integer;
    chunkString: String;
begin
    // On charge le fichier texte du monde
    worldStringList := TStringList.Create();
    worldStringList.LoadFromFile('worlds/' + world.name + '.txt');

    // On charge le monde a partir du chunk dans lequel le joueur se trouve
    rootChunkIndex := Round(world.player.pos.x/100);
    for i := 2 to worldStringList.Count-1 do
    begin
        // Recuperation des informations du chunk
        line := worldStringList.strings[i].Split(';');
        chunk.chunkIndex := StrToInt(line[0]);

        // On charge seulement les chunks qui sont a une distance de 1 chunk du chunk dans lequel le joueur se trouve
        if ((rootChunkIndex -1) < chunk.chunkIndex) and (chunk.chunkIndex < (rootChunkIndex + 1)) then
        begin
            chunkString := line[1];
            // On enleve les crochets (mise en propre)
            chunkString := chunkString.Remove(0, 1);
            chunkString := chunkString.Remove(chunkString.Length-1, 1);
            line := chunkString.Split(',');
            for j := 0 to 99 do
            begin
                // On enleve les seconds crochets (mise en propre)
                if j = 0 then
                    line[j] := line[j].Remove(0, 1);
                
                if j = 99 then
                    line[j] := line[j].Remove(line[j].Length-1, 1);
                line := line[j].Split('-');
                for k := 0 to 99 do
                begin
                    // Conversion de la string en entier et ajout dans le chunk
                    chunk.layout[j][k] := StrToInt(line[k]);
                end;
            end;
            // Ajout du chunk dans le monde et dans les chunks non sauvegardés

            AddIntToArray(world.unsavedChunks, chunk.chunkIndex);
            AddChunkToArray(world.chunks, chunk);

            freeandnil(worldStringList);
        end;
    end;
end;

function worldInit(worldName: string): TWorld;
var
    world: TWorld;
    worldStringList: TStringList;
    line: TStringArray;
begin
    world.name := worldName;

    // On charge le monde a partir du fichier texte
    worldStringList := TStringList.Create();
    worldStringList.LoadFromFile('worlds/' + worldName + '.txt');

    // Initialisation du nom du monde et du temps
    line := worldStringList.strings[0].Split(';');
    world.name := line[0];
    world.time := StrToInt(line[1]);
    // Initialisation de la position du joueur et sa vie
    line := worldStringList.strings[1].Split(';');

    world.player.pos.x := StrToFloat(line[0]);
    world.player.pos.y := StrToFloat(line[1]);
    world.player.vel.x := StrToFloat(line[2]);
    world.player.vel.y := StrToFloat(line[3]);
    world.player.health := StrToInt(line[4]);
    freeandnil(worldStringList);
    
    // On charge les chunks autour du jouer
    // loadPlayerChunks(world);  A MODIFIER !!
    world.seed := NewSeed();
    InitialiseWorld(world);
    
    world.player.pos.y := 1 + findTop(world.chunks[1], round(world.player.pos.x)); // Temporary y init pos 

    worldInit := world;
end;

function getWorlds(): StringArray; // TO TEST
var worlds: TStringList; worldArray: StringArray; i:Integer;
begin
    worlds := TStringList.Create();
    worlds.LoadFromFile('world_index.txt');
    setLength(worldArray, worlds.Count);
    i := 0;
    for i := 0 to (worlds.count-1) do
    begin
        worldArray[i] := worlds.strings[i];
    end;

    getWorlds := worldArray;
end;

procedure deleteWorldFromindex(const worldName: String); // TO TEST
var index: TStringList;i:Integer;
begin
    index := TStringList.Create();
    index.LoadFromFile('world_index.txt');

    for i := 0 to index.count -1 do
        if index.strings[i] = 'worldName' then
            index.strings[i] := '';
    
    index.SaveToFile('world_index.text');
end;

procedure deleteWorld(const worldName: String);

begin
    DeleteFile('worlds/' + worldName + '.txt');
    deleteWorldFromindex(worldName);
end;
end.

