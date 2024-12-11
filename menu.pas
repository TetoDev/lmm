unit menu;

interface

uses LMMTypes, util, sdl2,sdl2_image,sdl2_ttf, SysUtils, math;

procedure DisplayText(Text:PChar;Window: PSDL_Window; var Renderer: PSDL_Renderer; Font: PTTF_Font;x,y:Integer);

procedure MenuQuitter(var Renderer: PSDL_Renderer; window:TWindow; Font: PTTF_Font);

procedure MenuHomescreen(var Renderer: PSDL_Renderer; window:TWindow; Font: PTTF_Font;textures:TTextures; chooseWorld:Boolean);

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
end;


procedure MenuQuitter(var Renderer: PSDL_Renderer; window:TWindow; Font: PTTF_Font);
var Rect: TSDL_Rect;
begin
    
    SDL_SetRenderDrawColor(renderer, 128, 128, 128, 128); 
    SDL_SetRenderDrawBlendMode(Renderer, SDL_BLENDMODE_BLEND); // Mode de fusion
    SDL_RenderFillRect(Renderer, nil);

    SDL_SetRenderDrawColor(renderer, 20, 20, 20, 210);
    Rect.w := 300;
    Rect.h := 100;
    Rect.x := window.width div 2 - 150;
    Rect.y := window.height div 2 - 125;
    SDL_RenderFillRect(Renderer, @Rect);
    
    DisplayText(PChar('Resume'), window.window,renderer, Font, window.width div 2 - 130, window.height div 2 - 87);

    Rect.w := 300;
    Rect.h := 100;
    Rect.x := window.width div 2 - 150;
    Rect.y := window.height div 2 + 25;
    SDL_RenderFillRect(Renderer, @Rect);

    DisplayText(PChar('Leave'), window.window,renderer, Font, window.width div 2 - 130 ,window.height div 2 + 63);
end;


procedure MenuHomescreen(var Renderer: PSDL_Renderer; window:TWindow; Font: PTTF_Font;textures:TTextures; chooseWorld:Boolean);
var Rect: TSDL_Rect;i,j:Integer;
begin
    Rect.w := SIZE;
    Rect.h := SIZE;
    for j := 0 to ceil(window.width/SIZE) do
      for i := 0 to ceil(window.height/SIZE) do
      begin 
          Rect.x := i*SIZE;
          Rect.y := j*SIZE;
	        SDL_RenderCopy(renderer, textures.blocks[2], nil, @Rect);
      end;

    
    if chooseWorld then
    begin
      SDL_SetRenderDrawColor(renderer, 80, 80, 80, 128); 
      SDL_SetRenderDrawBlendMode(Renderer, SDL_BLENDMODE_BLEND); // Mode de fusion
      SDL_RenderFillRect(Renderer, nil);
    end;

    SDL_SetRenderDrawColor(renderer, 20, 20, 20, 220);


    Rect.w := 300;
    Rect.h := 100;
    Rect.x := window.width div 2 - 150;
    Rect.y := window.height div 2 - 125;
    SDL_RenderFillRect(Renderer, @Rect);
    if not chooseWorld then
      DisplayText(PChar('Play'), window.window,renderer, Font, window.width div 2 - 130, window.height div 2 - 87);
    if chooseWorld then
      DisplayText(PChar('Save 1'), window.window,renderer, Font, window.width div 2 - 130, window.height div 2 - 87);
    Rect.x := window.width div 2 - 150;
    Rect.y := window.height div 2 + 25;
    SDL_RenderFillRect(Renderer, @Rect);

    if not chooseWorld then
      DisplayText(PChar('Leave'), window.window,renderer, Font, window.width div 2 - 130 ,window.height div 2 + 63);
    if chooseWorld then
      DisplayText(PChar('Back'), window.window,renderer, Font, window.width div 2 - 130, window.height div 2 + 63);
end;


end.