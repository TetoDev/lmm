unit worldGeneration;

Interface 
uses LMMTypes, util;


function NewSeed():LongInt;

procedure chunkShapeGeneration(var chunk: TChunk; seed: LongInt);

procedure InitialiseWorld(var world:TWorld);

Implementation

function NewSeed():LongInt;
begin
    Randomize; // Initialise la generation de nombre aleatoire
    NewSeed := Random(100000000); // Seed Choisit au hazard entre 0 et 10^8
end;

procedure chunkShapeGeneration(var chunk: TChunk; seed: LongInt);
var i,j,height:integer; coef:real; variations: Array [0..8] of Integer;
begin

    if chunk.chunkIndex >= 0 then 
        begin
            Randseed := round(seed mod 10000); //Si la generation est vers la droite: 4 dernier nombre
            for i := 0 to chunk.chunkIndex*10 do //On replace la fonction random a la deniere generation a droite
                random(9);
        end
    else
        begin
            Randseed := trunc(seed/10000); //Si la generation est vers la gauche: 4 premier nombre
            for i := 1 to abs(chunk.chunkIndex*10) do //On replace la fonction random a la deniere generation a gauche
                random(9);
        end;
    
    for i := 0 to 8 do  //On genere 8 varations de hauteur 
    begin
        variations[i] := Random(8);
    end;

    chunk.layout[0][0] := 60; //On defini la hauteur du terrain au 2 extreme de la generation
    chunk.layout[99][0] := 60;
    
    for i := 0 to 8 do 
    begin
        //la generation est faite telle que on enchaine une montee puis une descente:
        if (i mod 2 = 0) and ((chunk.layout[i*10][0] + variations[i] <= 80) or (chunk.layout[i*10][0] - variations[i] < 40)) then 
        //verification que la pente monte ET n'atteigne pas la bordure maximum OU n'atteigne pas la bordure minimum
        begin
           chunk.layout[(i+1)*10][0] := chunk.layout[i*10][0] + variations[i];  //Definition de la hauteur au multiple paire de 10
        end;    
        if (i mod 2 = 1) and ((chunk.layout[i*10][0] - variations[i] >= 40) or (chunk.layout[i*10][0] + variations[i] > 80)) then
        //verification que la pente descende ET n'atteigne pas la bordure minimum OU n'atteigne pas la bordure maximum
        begin
            chunk.layout[(i+1)*10][0] := chunk.layout[i*10][0] - variations[i+1]; //Definition de la hauteur au multiple impaire de 10
        end; 
    end;
    
    for i := 0 to 9 do 
    begin
        //On trouve le coefficient de croissance ou decroissance entre 2 hauteur
        if i <> 9 then
            coef := (chunk.layout[(i+1)*10][0]-chunk.layout[i*10][0])/10 
        else
            coef := (60 - chunk.layout[i*10][0])/10; //Cas pour 90-99 et non 90-100

        for j := 1 to 9 do 
        //Definition de la hauteur pour tout les x 
        begin
            chunk.layout[i*10+j][0] := chunk.layout[i*10][0] + round(coef*j);
        end;
    end;

    for i := 0 to 99 do
    //Remplissage du chunk hauteur par hauteur, ici les 1 sont la terre et les 0 sont l´aire
    begin
        height := chunk.layout[i][0];
        for j := 0 to height do
            chunk.layout[i][j] := 1;
        for j := height+1 to 99 do
            chunk.layout[i][j] := 0;
    end;

end;

procedure InitialiseWorld(var world:TWorld);
var chunkLeft, chunkMid, chunkRight:TChunk;
begin
    chunkLeft.chunkIndex := -1;
    chunkMid.chunkIndex:= 0;
    chunkRight.chunkIndex := 1;

    world.lastLeftChunk := -1;
    world.LastRightChunk := 1;

    AddChunkToArray(world.chunks, chunkLeft);
    AddChunkToArray(world.chunks, chunkMid);
    AddChunkToArray(world.chunks, chunkRight);

    chunkShapeGeneration(world.chunks[0],world.seed);
    chunkShapeGeneration(world.chunks[1],world.seed);
    chunkShapeGeneration(world.chunks[2],world.seed);

    world.seed := seed;
end;

end.