unit display;

Interface

uses LMMTypes, util, SDL2;

procedure printChunk(chunk:TChunk);

procedure cameraDisplacement(world: TWorld; position: TPosition; viewHeight,viewWidth: Integer);

Implementation

procedure printChunk(chunk:TChunk);
var i,j:Integer;
begin
    for i := 0 to 99 do
    begin
        for j := 0 to 99 do
            write(chunk.layout[j][99-i]);
        writeln();
    end;
end;

procedure cameraDisplacement(world: TWorld; position: TPosition; viewHeight,viewWidth: Integer);
var i, j, relativeX, heightBot,heightTop, widthLeft,widthRight,restLeft,restRight : Integer; chunkLeft,chunkRight,chunk:TChunk;
begin
    chunk := getChunkByIndex(world,Round(position.x) div 100 );
    chunkLeft := getChunkByIndex(world,Round(position.x) div 100 - 1);
    chunkRight := getChunkByIndex(world,Round(position.x) div 100 + 1);
    //On défini la position du joueur relativement au chunk
    relativeX := abs(Round(position.x) mod 100);

    //On défini les extrémités minimal et maximal en Y a afficher 
    if (Round(position.y) - viewHeight >= 0) and (Round(position.y) + viewHeight <= 99) then
    begin
        heightBot := Round(position.y) - viewHeight;
        heightTop := Round(position.y) + viewHeight;
    end
    else if (Round(position.y) + viewHeight > 99) then
    begin
        heightBot := Round(position.y) - viewHeight;
        heightTop := 99;
    end
    else if (Round(position.y) - viewHeight < 0) then
    begin
        heightBot := 0;
        heightTop := Round(position.y) + viewHeight;
    end;

    //On défini les extrémités minimal et maximal en X a afficher 
    if (relativeX - viewWidth >= 0) and (relativeX + viewWidth <= 99) then 
    begin
        widthLeft := relativeX - viewWidth;
        widthRight := relativeX + viewWidth;
        restLeft := 99;
        restRight := 0;
    end
    else if relativeX - viewWidth < 0 then
    begin
        widthLeft := 0;
        widthRight := relativeX + viewWidth;
        restLeft := 99 + relativeX - viewWidth ;
        restRight := 0;
    end 
    else if relativeX + viewWidth > 99 then
    begin
        widthLeft := relativeX - viewWidth;
        widthRight := 99;
        restLeft := 99;
        restRight := relativeX + viewWidth - 99;
    end;

    //Affichage du chunk relatif a la position du joueur et de ses coordonnées
    for i := heightTop downto heightBot do
    begin
        //Affichage du chunk de droite si il y a besoin
        if restLeft < 99 then
            for j := restLeft to 99 do
                write(chunkLeft.layout[j][i]);
        //Affichage du chunk du joueur 
        for j := widthLeft to widthRight do
            write(chunk.layout[j][i]);
        //Affichage du chunk de droite si il y a besoin
        if restRight > 0 then
            for j := 0 to restRight do
                write(chunkRight.layout[j][i]);
        writeln();
    end;
end;

end.