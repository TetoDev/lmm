unit display;

Interface

uses LMMTypes;

procedure printChunk(chunk:TChunk);

procedure printPerspectiveChunk(chunk: TChunk; position: TPosition; viewHeight,viewWidth: Integer);

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

procedure printPerspectiveChunk(chunk: TChunk; position: TPosition; viewHeight,viewWidth: Integer);
var i, j, relativeX, heightBot,heightTop, widthLeft,widthRight : Integer;
begin
    //On défini la position du joueur relativement au chunk
    relativeX := abs(Round(position.x) mod 100);

    //On défini les extrémités minimal et maximal en y a afficher 
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

    //On défini les extrémités minimal et maximal en x a afficher 
    if (relativeX - viewWidth >= 0) and (relativeX + viewWidth <= 99) then 
    begin
        widthLeft := relativeX - viewWidth;
        widthRight := relativeX + viewWidth;
    end
    else if relativeX - viewWidth < 0 then
    begin
        widthLeft := 0;
        widthRight := relativeX + viewWidth;
    end 
    else if relativeX + viewWidth > 99 then
    begin
        widthLeft := relativeX - viewWidth;
        widthRight := 0;
    end;

    WriteLn(widthLeft,' ',widthRight,' ',heightBot,' ',heightTop);

    //Affichage du chunk relatif a la position du joueur et de ses coordonnées
    for i := heightBot to heightTop do
    begin
        for j := widthLeft to widthRight do
            write(chunk.layout[j][99-i]);
        writeln();
    end;
end;

end.