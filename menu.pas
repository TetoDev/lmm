unit menu;

// Admettre des strings de plus de 255 caractères
{$H+}
{$MODE DELPHI}

interface

uses LMMTypes, util, sdl2,sdl2_image,sdl2_ttf, SysUtils, math, fileHandler;

procedure DisplayText(Text:PChar;Window: PSDL_Window; var Renderer: PSDL_Renderer; Font: PTTF_Font;x,y:Integer);

procedure MenuQuitter(var Renderer: PSDL_Renderer; window:TWindow; Font: PTTF_Font);

procedure MenuHomescreen(var Renderer: PSDL_Renderer; window:TWindow; Font: PTTF_Font;textures:TTextures;page:Integer; chooseWorld:Boolean);

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

procedure background(textures:TTextures;var renderer:PSDL_Renderer; window:TWindow; chooseWorld:Boolean);
var Rect: TSDL_Rect;i,j:Integer;
begin
    //affichage du back ground constitué de blocks et du ciel
    //affichage du ciel en arrière plan
    Rect.w := Round(1107/1.4);
    Rect.h := Round(707/1.4);
    Rect.x := 0;
    Rect.y := 0;
    SDL_RenderCopy(Renderer, textures.sky, @Rect, nil);
    SDL_SetTextureAlphaMod(textures.sky, 255);
    //on parametre l'affichage des blocks
    Rect.w := SIZE;
    Rect.h := SIZE;
    //on affiche la couche d'herbe
    for i := 0 to ceil(window.width/SIZE) do
    begin 
        Rect.x := i*SIZE;
        Rect.y := 5*SIZE;
        SDL_RenderCopy(renderer, textures.blocks[1], nil, @Rect);
    end;
    //on affiche les couches de terre
    for j := 6 to ceil(window.height/SIZE) do
      for i := 0 to ceil(window.width/SIZE) do
      begin 
          Rect.x := i*SIZE;
          Rect.y := j*SIZE;
	        SDL_RenderCopy(renderer, textures.blocks[2], nil, @Rect);
      end;

    //si on est en selection de monde alors le fond est grisé
    if chooseWorld then
    begin
      SDL_SetRenderDrawColor(renderer, 80, 80, 80, 128); 
      SDL_SetRenderDrawBlendMode(Renderer, SDL_BLENDMODE_BLEND); // Mode de fusion
      SDL_RenderFillRect(Renderer, nil);
    end;
end;

procedure button(var Renderer: PSDL_Renderer; window:TWindow; Font: PTTF_Font; text:PChar;x,y, width,height:Integer);
var Rect: TSDL_Rect;
begin  
    //affichage des fond des boutons
    Rect.w := width;
    Rect.h := height;
    Rect.x := x;
    Rect.y := y;
    SDL_RenderFillRect(Renderer, @Rect);
    //affichage du text 
    DisplayText(text, window.window,renderer, Font, x + 20, y + 38);
  
end;

procedure MenuWorldsList(var Renderer: PSDL_Renderer; window:TWindow; Font: PTTF_Font;page:Integer);
var worlds : StringArray; i,n : Integer;Buffer: array[0..255] of Char;Rect: TSDL_Rect;
begin
  Rect.w := 320;
        Rect.h := 20 + trunc((window.height - 250)/105)*105;
        Rect.x := window.width div 2 - 160;
        Rect.y := 240;
        SDL_RenderFillRect(Renderer, @Rect);
        worlds := getWorlds();
        for i:=0 to min(Length(worlds) - 1 - (page-1)*(Trunc((window.height - 250)/105)-1), Trunc((window.height - 250)/105)-1) do 
        begin
          n := i + (page-1)*(Trunc((window.height - 250)/105)-1);
          button(Renderer,window,Font,StrPCopy(Buffer,worlds[n]),(window.width - 300) div 2, (250 + i*105),300,100);
        end;
        if (Length(worlds) - 1) > (page)*(Trunc((window.height - 250)/105)-1) then 
          button(Renderer,window,Font,PChar('   >'),(window.width div 2 +170), (250 + (Trunc((window.height - 250)/105)-1)*105),100,100);
        if page > 1 then 
          button(Renderer,window,Font,PChar('   <'),(window.width div 2 -270), (250 + (Trunc((window.height - 250)/105)-1)*105),100,100);

        button(Renderer,window,Font,PChar('Back'),25, 25,150,100);
end;

procedure MenuHomescreen(var Renderer: PSDL_Renderer; window:TWindow; Font: PTTF_Font;textures:TTextures;page:Integer; chooseWorld:Boolean);
begin
    background(textures,Renderer, window, chooseWorld);

    SDL_SetRenderDrawColor(renderer, 20, 20, 20, 220);

    if not chooseWorld then
    begin
        button(Renderer,window,Font,PChar('Play'),(window.width - 300) div 2, (window.height div 2 -125),300,100);
        button(Renderer,window,Font,PChar('Leave'),(window.width - 300) div 2, (window.height div 2 +25),300,100);
    end;
    if chooseWorld then
    begin
        button(Renderer,window,Font,PChar('New World'),(window.width - 300) div 2, 100 ,300,100);
        MenuWorldsList(Renderer,window,Font,page);
    end;
end;


end.