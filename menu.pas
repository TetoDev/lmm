unit menu;

interface

uses LMMTypes, util, sdl2,sdl2_image,sdl2_ttf, SysUtils;

procedure DisplayText(Text:PChar;Window: PSDL_Window; var Renderer: PSDL_Renderer; Font: PTTF_Font;x,y:Integer);

procedure MenuQuitter(Window: PSDL_Window; var Renderer: PSDL_Renderer; windowParam:TWindow);

implementation

procedure DisplayText(Text:PChar;Window: PSDL_Window; var Renderer: PSDL_Renderer; Font: PTTF_Font;x,y:Integer);
var
  Surface: PSDL_Surface;
  Texture: PSDL_Texture;
  Color: TSDL_Color;
  TextRect: TSDL_Rect;
begin
 
  // Définir la couleur du texte
  Color.r := 255; // Rouge
  Color.g := 255; // Vert
  Color.b := 255; // Bleu
  Color.a := 255; // Opacité

  // Créer une surface à partir du texte
  Surface := TTF_RenderText_Solid(Font, Text, Color);
  if Surface = nil then
  begin
    Writeln('Erreur lors du rendu du texte: ', TTF_GetError);
    TTF_CloseFont(Font);
    SDL_DestroyRenderer(Renderer);
    SDL_DestroyWindow(Window);
    TTF_Quit;
    SDL_Quit;
    Halt(1);
  end;

  // Convertir la surface en texture
  Texture := SDL_CreateTextureFromSurface(Renderer, Surface);
  SDL_FreeSurface(Surface); // Libérer la surface car elle n'est plus nécessaire

  if Texture = nil then
  begin
    Writeln('Erreur lors de la création de la texture: ', SDL_GetError);
    TTF_CloseFont(Font);
    SDL_DestroyRenderer(Renderer);
    SDL_DestroyWindow(Window);
    TTF_Quit;
    SDL_Quit;
    Halt(1);
  end;

  // Définir la position et la taille du texte
  TextRect.x := x; // Position X
  TextRect.y := y;  // Position Y
  SDL_QueryTexture(Texture, nil, nil, @TextRect.w, @TextRect.h); // Taille automatique selon le texte
  SDL_RenderCopy(Renderer, Texture, nil, @TextRect); // Affiche le texte
  SDL_RenderPresent(Renderer);
end;


procedure MenuQuitter(Window: PSDL_Window; var Renderer: PSDL_Renderer; windowParam:TWindow);
var Rect: TSDL_Rect;
begin
    
    SDL_SetRenderDrawColor(renderer, 128, 128, 128, 128); 
    SDL_SetRenderDrawBlendMode(Renderer, SDL_BLENDMODE_BLEND); // Mode de fusion
    SDL_RenderFillRect(Renderer, nil);

    SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255);
    Rect.w := 200;
    Rect.h := 100;
    Rect.x := windowParam.width div 2 - 100;
    Rect.y := windowParam.height div 2 - 150;
    SDL_RenderFillRect(Renderer, @Rect);

    SDL_SetRenderDrawColor(renderer, 200, 200, 200, 255);
    Rect.w := 200;
    Rect.h := 100;
    Rect.x := windowParam.width div 2 - 100;
    Rect.y := windowParam.height div 2 + 50;
    SDL_RenderFillRect(Renderer, @Rect);
end;

end.