program testpascal;

var h: array of Integer;
    i: Integer;
begin
    setLength(h,10);
    for i := 0 to length(h) -1 do
    begin
        h[i] := i
    end;

    delete(h,2,1);

    for i:= 0 to length(h) - 1 do
    begin
        writeln(h[i])
    end;
end.