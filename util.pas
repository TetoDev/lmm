unit Util;

interface

type
    TArray<T> = array of T;

procedure AddToArray<T>(var Arr: TArray<T>; const Element: T);

implementation

procedure AddToArray<T>(var Arr: TArray<T>; const Element: T);
begin
    SetLength(Arr, Length(Arr) + 1);
    Arr[High(Arr)] := Element;
end;

end.