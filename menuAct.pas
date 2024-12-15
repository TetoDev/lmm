unit menuAct;

interface
uses LMMTypes, SDL2, display, fileHandler; 

procedure eventMenuListener(var event:TSDL_Event; var world:TWorld ;var windowParam:TWindow; var fileName:String;var page:Integer;var credits,chooseWorld,delete,running,leave,createWorld:Boolean);

procedure handleMouseMenu(x:Integer ; y:Integer; window:TWindow; var fileName:String;var page:Integer; var credits, chooseWorld,delete,running,leave,createWorld:Boolean);

procedure handleInputMenu(keyPressed: String;var fileName:String; var running:Boolean);

implementation


procedure eventMenuListener(var event:TSDL_Event; var world:TWorld ;var windowParam:TWindow; var fileName:String;var page:Integer;var credits, chooseWorld,delete,running,leave,createWorld:Boolean);
begin 
    while SDL_PollEvent(@event) <> 0 do
    begin 
        case event.type_ of

            SDL_QUITEV:
            begin
                Running := False;
                leave := True
            end;
            
            SDL_KEYDOWN:
            begin
              if createWorld then
                    handleInputMenu(SDL_GetKeyName(Event.key.keysym.sym),fileName,running);
            end;

            SDL_MOUSEBUTTONDOWN:
                begin
                    if event.button.button = SDL_BUTTON_LEFT then
                        handleMouseMenu(event.button.x, event.button.y, windowParam, fileName,page, credits,chooseWorld,delete,running,leave,createWorld);
                end;
                
            SDL_WINDOWEVENT:
                if Event.window.event = SDL_WINDOWEVENT_RESIZED then
                begin
                    windowParam.width := event.window.data1; // Nouvelle largeur
                    windowParam.height := event.window.data2; // Nouvelle hauteur
                end;
            
        end;
    end;
end;


procedure handleMouseMenu(x:Integer ; y:Integer; window:TWindow; var fileName:String;var page:Integer; var credits, chooseWorld,delete,running,leave,createWorld:Boolean);
var i:Integer; worlds:StringArray;
begin
    if credits then
    begin
        if ((x > 25) and ( x < 25 + 175 )) and ((y > 25) and ( y < 125)) then
            credits := False;
    end
    // On regarde si le joueur à cliquer sur le bouton pour choisir un monde ou pour quitter le jeu
    else if not chooseWorld and not createWorld then
    begin
        if ((x > window.width div 2 - 150) and ( x < window.width div 2 + 150)) and ((y > window.height div 2 - 125) and ( y < window.height div 2 - 25)) then
            chooseWorld := True;
        if ((x > window.width div 2 - 150) and ( x < window.width div 2 + 150)) and ((y > window.height div 2 + 25) and ( y < window.height div 2 + 125)) then
        begin
            running := False;
            leave := True;
        end;
    end
    // On regarde si le joueur à cliquer sur le bouton pour créer un monde ou pour retourner au menu précédent ou pour supprimer un monde ou encore pour accéder au monde voulu
    else if chooseWorld then  
    begin
        // on regarde si le joueur veux retourner au menu d'avant
        if ((x > 25) and ( x < 25 + 200 )) and ((y > 25) and ( y < 125)) then
            chooseWorld := False;
        // on viens regarder quel monde le joueur à t'il cliquer
        worlds := getWorlds();
        if not Delete then
        begin

            // on regarde si le joueur à cliquer sur un monde en parcourant la liste des mondes
            for i:= 0 to Length(worlds) - 1 do
                if ((x > window.width div 2 - 150) and ( x < window.width div 2 + 150)) and ((y > 250 + i*105) and (y < 250 + i*105 + 100)) then
                begin
                    // on regarde si le joueur à cliquer sur le bouton pour supprimer un monde
                    if ((x > window.width div 2+90) and ( x < (window.width) div 2+140 )) and ((y > 270 + i*105) and (y < 320 + i*105 + 100)) then
                    begin
                        delete := True;
                        fileName := worlds[i + (page-1)*(Trunc((window.height - 250)/105))];
                    end
                    // Sinon on regarde si le joueur à cliquer sur un monde pour le charger
                    else 
                    begin
                        running := False;
                        fileName := worlds[i + (page-1)*(Trunc((window.height - 250)/105))];
                    end;
                end;
        end

        // Si le joueur à cliquer sur le bouton pour supprimer un monde, on regarde si il veux vraiment supprimer le monde ou non
        else if Delete then 
        begin
            // On regarte si le joueur à cliquer sur le bouton oui ou non
            if ((x > window.width div 2 - 125) and ( x < window.width div 2 -50)) and ((y > window.height div 2) and (y < window.height + 60)) then
            begin
                delete := False;
                deleteWorld(fileName);
            end;
            if ((x > window.width div 2 + 50) and ( x < window.width div 2 + 125)) and ((y > window.height div 2) and (y < window.height + 60)) then
            begin
                delete := False;
            end;
        end;

        // Nous venon verifier si il y a trop de monde pour la page, puis si le joueur à cliquer pour acceder à la page suivante ou précédente
        if ((Length(worlds)) > (Trunc((window.height - 250)/105)-1)) and (page <= Length(worlds)-1) then 
            if ((x > window.width div 2 + 170) and ( x < window.width div 2 + 270)) and ((y > (250 + (Trunc((window.height - 250)/105)-1)*105)) and (y < (350 + (Trunc((window.height - 250)/105)-1)*105))) then
                    page := page + 1;
        if page > 1 then 
            if ((x > window.width div 2 -270) and ( x < window.width div 2 - 170)) and ((y > (250 + (Trunc((window.height - 250)/105)-1)*105)) and (y < (350 + (Trunc((window.height - 250)/105)-1)*105))) then
                    page := page - 1;

        // on regarde si le joueur veux créer un monde
        if ((x > (window.width - 300) div 2) and (x < (window.width - 300) div 2 + 300)) and ((y > 100) and (y < 200)) then 
        begin
            createWorld := True;
            chooseWorld := False;
        end;

    end
    
    // Si le joueur à cliquer sur le bouton pour créer un monde, on regarde si il veux retourner au menu précédent ou créer un monde
    else if createWorld then
      begin
         // on regarde si le joueur veux retourner au menu d'avant
        if ((x > 25) and ( x < 25 + 200 )) and ((y > 25) and ( y < 125)) then
        begin
            createWorld := False;
            chooseWorld := True;
        end;
        // on regarde si le joueur veux créer un monde
        if ((x > window.width div 2 - 90) and ( x < window.width div 2 + 90 )) and ((y > window.height div 2 + 75) and ( y < window.height div 2 + 175)) and (Length(fileName) > 0)then
            running := False
      end;
      
end;

procedure handleInputMenu(keyPressed: String;var fileName:String; var running:Boolean);
begin
    // On regarde si le joueur à appuyer sur la touche espace, ou backspace (effacer)
    if keyPressed = 'Space' then
        fileName := fileName + ' '
    else if keyPressed = 'Backspace' then
    begin
        if Length(fileName) > 0 then
            Dec(fileName[0])
    end
    // On regarde si le joueur à appuyer sur une touche de l'alphabet ou un chiffre et que le nom du monde n'est pas plus grand que 12 caractères
    else if (Length(fileName) = 0) and (LowerCase(keyPressed)  >= 'a') and (LowerCase(keyPressed)  <= 'z') and (Length(keyPressed) = 1)then 
        fileName := fileName + keyPressed
    else if (Length(fileName) < 12) and (keyPressed  >= 'A') and (keyPressed  <= 'Z') and (Length(keyPressed) = 1) then
        fileName := fileName + LowerCase(keyPressed)
    else if (Length(fileName) < 12) and (keyPressed  >= '0') and (keyPressed  <= '9') and (Length(keyPressed) = 1) then
        fileName := fileName + keyPressed
    else fileName := fileName;
    
end;


end.