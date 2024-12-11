unit act;

Interface
uses LMMTypes, SDL2, util, display, math, fileHandler; 

// acts procedure for the menu 
procedure eventMenuListener(var event:TSDL_Event; var world:TWorld ;var windowParam:TWindow; var fileName:String;var chooseWorld,running,leave:Boolean);
procedure handleMouseMenu(x:Integer ; y:Integer; window:TWindow; var fileName:String;var chooseWorld,running,leave:Boolean);

// acts procedure for the in game
procedure eventGameListener(var event:TSDL_Event;var world:TWorld; var windowParam:TWindow; var key:TKey ;var playerAction:TPlayerAction; var running,pause:Boolean);
procedure handleInput(keyPressed: String;var key:TKey; var direction: Boolean; french,state: Boolean; var running:Boolean; var pause:Boolean);
procedure handleMouse(x:Integer ; y:Integer; world:TWorld; window:TWindow; action:TActs; var playerAction: TPlayerAction; var pause,running:Boolean);
procedure addAction(var playerAction: TPlayerAction; key:TKey);
procedure playerMove(var player: TPlayer; var vel: TVelocity; blockBelow: Boolean; playerAction: TPlayerAction; time: Integer);
procedure blockAct(playerAction: TPlayerAction; var world: TWorld); 
procedure handleCollision(var velocity: TVelocity; var pos: TPosition; box: TBoundingBox; chunk: TChunk);
function checkVerticalCollision(corner: TPosition; chunk: TChunk; isRight, isDown: Boolean): Boolean;
function checkHorizontalCollision(corner: TPosition; chunk: TChunk; isRight, isDown: Boolean): Boolean;
function isBlockBelow (pos: TPosition; box: TBoundingBox; chunk: TChunk): Boolean;
procedure inflictDamage (var targetHealth: Integer; damage: Integer);
procedure playerAttack (var player: TPlayer; var vel: TVelocity; time: Integer);
procedure resetPlayerAttack(var player: TPlayer; time: Integer; var world: TWorld);

Implementation


procedure eventMenuListener(var event:TSDL_Event; var world:TWorld ;var windowParam:TWindow; var fileName:String;var chooseWorld,running,leave:Boolean);
begin 
    while SDL_PollEvent(@event) <> 0 do
    begin 
        case event.type_ of

            SDL_QUITEV:
            begin
                Running := False;
                leave := True
            end;
            SDL_MOUSEBUTTONDOWN:
                begin
                    if event.button.button = SDL_BUTTON_LEFT then
                        handleMouseMenu(event.button.x, event.button.y, windowParam, fileName,chooseWorld,running,leave);
                end;

            SDL_MOUSEWHEEL: 
                begin
                   
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


procedure handleMouseMenu(x:Integer ; y:Integer; window:TWindow; var fileName:String;var chooseWorld,running,leave:Boolean);
begin
    if not chooseWorld then
    begin
        if ((x > window.width div 2 - 150) and ( x < window.width div 2 + 150)) and ((y > window.height div 2 - 125) and ( y < window.height div 2 - 25)) then
            chooseWorld := True;
        if ((x > window.width div 2 - 150) and ( x < window.width div 2 + 150)) and ((y > window.height div 2 + 25) and ( y < window.height div 2 + 125)) then
        begin
            running := False;
            leave := True;
        end;
    end
    else 
    begin
        if ((x > window.width div 2 - 150) and ( x < window.width div 2 + 150)) and ((y > window.height div 2 - 125) and ( y < window.height div 2 - 25)) then
            running := False;
        if ((x > window.width div 2 - 150) and ( x < window.width div 2 + 150)) and ((y > window.height div 2 + 25) and ( y < window.height div 2 + 125)) then
             begin
            chooseWorld := False;
        end;
    end;
end;








procedure eventGameListener(var event:TSDL_Event;var world:TWorld; var windowParam:TWindow; var key:TKey ;var playerAction:TPlayerAction; var running,pause:Boolean);
begin 
    while SDL_PollEvent(@event) <> 0 do
    begin 
        case event.type_ of

            SDL_KEYDOWN:
                    handleInput(SDL_GetKeyName(Event.key.keysym.sym),key, world.player.direction,true, true, running, pause);

            SDL_KEYUP:
                    handleInput(SDL_GetKeyName(Event.key.keysym.sym),key, world.player.direction,true, false, running, pause);

            SDL_MOUSEBUTTONDOWN:
                begin
                    if event.button.button = SDL_BUTTON_RIGHT then
                        handleMouse(event.button.x, event.button.y, world,windowParam, PLACE_BLOCK, playerAction ,pause,running);
                    if event.button.button = SDL_BUTTON_LEFT then
                        handleMouse(event.button.x, event.button.y, world,windowParam, REMOVE_BLOCK, playerAction, pause,running);
                end;

            SDL_MOUSEWHEEL: 
                begin
                    if Event.wheel.y > 0 then
                        world.player.heldItem := (world.player.heldItem - 1) 
                    else 
                    if Event.wheel.y < 0 then
                        world.player.heldItem := (world.player.heldItem + 1) ;
                        
                    if world.player.heldItem = 0 then
                        world.player.heldItem := 1;
                    if world.player.heldItem = 7 then
                        world.player.heldItem := 6;
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

procedure handleInput(keyPressed: String;var key:TKey; var direction: Boolean; french,state: Boolean; var running:Boolean; var pause:Boolean);
begin
    //Suivant la touche appuyée on effectue différente action
    if not pause then 
    begin
        if french then
            case keyPressed of // FRENCH LAYOUT
                'Q': 
                begin 
                    key.q := state;
                    direction:=False;
                end;
                'D': 
                begin 
                    key.d := state;
                    direction:=True;
                end;
                'Z': 
                    key.z := state;
                'S': 
                    key.s := state;
                'Escape':
                    pause := True;
                'F':
                    key.f := state;
        else
            case keyPressed of // ENGLISH LAYOUT
                'A': 
                begin 
                    key.q := state;
                    direction:=False;
                end;
                'D': 
                begin 
                    key.d := state;
                    direction:=True;
                end;
                'W': 
                    key.z := state;
                'S': 
                    key.s := state;
                'Escape':
                    pause := True;
                'F':
                    key.f := state;
            end;
        end;
    end;
end;


procedure addAction(var playerAction: TPlayerAction; key:TKey);
begin
    if key.z then 
        AddActToArray(playerAction.acts, JUMP);
    if key.q then 
        AddActToArray(playerAction.acts, WALK_LEFT); 
    if key.d then 
        AddActToArray(playerAction.acts, WALK_RIGHT);
    if key.f then
        AddActToArray(playerAction.acts, ATTACK);
      
end;

procedure handleMouse(x:Integer ; y:Integer; world:TWorld; window:TWindow; action:TActs; var playerAction: TPlayerAction; var pause,running:Boolean);
var i : Integer;
begin
    if not pause then
    begin
        playerAction.selectedBlock.x := world.player.pos.x + x/Trunc(SURFACEWIDTH/BLOCKDISPLAYED) - ((window.width/SIZE)-world.player.boundingBox.width)/ 2;
        playerAction.selectedBlock.y := world.player.pos.y - y/Trunc(SURFACEWIDTH/BLOCKDISPLAYED) + ((window.height/SIZE)-world.player.boundingBox.height*2)/ 2;
        AddActToArray(playerAction.acts, action)
    end
    else 
    begin
        if ((x > window.width div 2 - 150) and ( x < window.width div 2 + 150)) and ((y > window.height div 2 - 125) and ( y < window.height div 2 - 25)) then
            pause := False;
        if ((x > window.width div 2 - 150) and ( x < window.width div 2 + 150)) and ((y > window.height div 2 + 25) and ( y < window.height div 2 + 125)) then
        begin
            running := False;
            for i := 0 to Length(world.chunks) - 1 do
              AddIntIfNotOnArray(world.unsavedChunks,world.chunks[i].chunkIndex);
            worldSave(world);
        end;
    end;
end;

procedure playerMove(var player: TPlayer; var vel: TVelocity; blockBelow: Boolean; playerAction: TPlayerAction; time: Integer);
var i: Integer;
    action: TActs;
begin
    for i:= 0 to length(playerAction.acts) -1 do
    begin
        action := playerAction.acts[i];
        case action of
            WALK_LEFT: 
            begin
                vel.x := vel.x - 0.4;
            end;
            WALK_RIGHT: 
            begin
                vel.x := vel.x + 0.4;
            end;
            JUMP: 
            begin
                if blockBelow then
                    vel.y := vel.y + 0.65;
            end;
            CROUCH: 
            begin
                // NOT IMPLEMENTED, cool but not relevant
            end;
            ATTACK:
            begin
                playerAttack(player, vel, time);
            end;
        end;
    end;
end;

procedure blockAct(playerAction: TPlayerAction; var world: TWorld); 
var i,x,y:Integer;currentChunk:TChunk;
begin
    // Calculate current chunk
    x := Trunc(playerAction.selectedBlock.x) mod 100;
    y := Trunc(playerAction.selectedBlock.y);
    currentChunk := getChunkByIndex(world, getChunkIndex(playerAction.selectedBlock.x));
    for i := 0 to length(playerAction.acts) - 1 do
    begin
        case playerAction.acts[i] of
            PLACE_BLOCK: 
            begin
                currentChunk.layout[abs(x)][y]:= world.player.heldItem;
                AddIntIfNotOnArray(world.unsavedChunks, currentChunk.chunkIndex);
            end;
            REMOVE_BLOCK: 
            begin
                currentChunk.layout[abs(x)][y] := 0;
                AddIntIfNotOnArray(world.unsavedChunks, currentChunk.chunkIndex);
            end;
        end;
    end;
    reinsertChunk(world,currentChunk)
end;

function checkVerticalCollision(corner: TPosition; chunk: TChunk; isRight, isDown: Boolean): Boolean;
var toleranceY, toleranceX, correctionX, correctionY : Real; BlockX, BlockY: Integer;
begin
    toleranceY := 0.0001;
    toleranceX := 0.01;

    if isRight then
        correctionX := corner.x - toleranceX
    else
        correctionX := corner.x + toleranceX;

    if isDown then
        correctionY := corner.y - toleranceY
    else
        correctionY := corner.y + toleranceY;

    // checkVerticalCollision := false; 

    // Checking vertical collisions
    BlockX := abs(Floor(correctionX)) - abs(trunc(correctionX/100)*100);
    // Writeln(BlockX);
    BlockY := floor(correctionY);

    if chunk.layout[BlockX][BlockY] > 0 then
        begin
            checkVerticalCollision := true;
        end;
end;

function checkHorizontalCollision(corner: TPosition; chunk: TChunk; isRight, isDown: Boolean): Boolean;
var toleranceX, toleranceY, correctionX, correctionY : Real; BlockX, BlockY: Integer;
begin
    toleranceX := 0.0001;
    toleranceY := 0.25;

    if isRight then
        correctionX := corner.x + toleranceX
    else
        correctionX := corner.x - toleranceX;

    if isDown then
        correctionY := corner.y + toleranceY
    else
        correctionY := corner.y - toleranceY;

    // checkHorizontalCollision := false;

    // Checking horizontal collisions
    BlockX := abs(floor(correctionX)) - abs(trunc(correctionX/100)*100);
    // Writeln(BlockX);
    BlockY := floor(correctionY);
    
    if chunk.layout[BlockX][BlockY] > 0 then
    begin
        checkHorizontalCollision := true;
    end;
end;

function isBlockBelow (pos: TPosition; box: TBoundingBox; chunk: TChunk): Boolean;
var br, bl: TPosition;
begin
    bl.x := pos.x;
    bl.y := pos.y - box.height;
    br.x := pos.x + box.width;
    br.y := pos.y - box.height;
    

    isBlockBelow := checkVerticalCollision(br, chunk, true, true) or checkVerticalCollision(bl, chunk, false, true);
end;

procedure handleCollision(var velocity: TVelocity; var pos: TPosition; box: TBoundingBox; chunk: TChunk);
var tl, tr, bl, br: TPosition; i: Integer;
begin
    for i := 0 to 1 do
    begin
    // Defining the corners of the player's bounding box
    // Top Left Corner
    tl.x := pos.x + i* velocity.x;
    tl.y := pos.y + i*velocity.y;
    // Top Right Corner
    tr.x := pos.x + box.width + i*velocity.x;
    tr.y := pos.y + i*velocity.y;
    // Bottom Left Corner
    bl.x := pos.x + i*velocity.x;
    bl.y := pos.y - box.height + i*velocity.y;
    // Bottom Right Corner
    br.x := pos.x + box.width + i*velocity.x;
    br.y := pos.y - box.height + i*velocity.y;

    writeln('Player Position: (', pos.x, ', ', pos.y, ')');
    writeln('Top Left: (', tl.x, ', ', tl.y, ')');
    writeln('Top Right: (', tr.x, ', ', tr.y, ')');
    writeln('Bottom Left: (', bl.x, ', ', bl.y, ')');
    writeln('Bottom Right: (', br.x, ', ', br.y, ')');

    // Checking for collision
    // For right corner horizontal collisions
    if checkHorizontalCollision(tr, chunk, true, false) or checkHorizontalCollision(br, chunk, true, true) then
    begin
        writeln('block right');
        if velocity.x >= 0 then
        begin
            velocity.x := 0;
            pos.x := floor(tr.x) - box.width;
        end;
    end;
    // For vertical corner colllisions
    if checkVerticalCollision(tr, chunk, true, false) or checkVerticalCollision(tl, chunk, false, false) then
    begin
        writeln('block above');
        if velocity.y > 0 then
        begin
            velocity.y := 0;
            pos.y := floor(tl.y);
        end;
    end;
    if checkVerticalCollision(br, chunk, true, true) or checkVerticalCollision(bl, chunk, false, true) then
    begin
        writeln('block below');
        if velocity.y < 0 then
        begin
            velocity.y := 0;
            pos.y := ceil(tl.y+0.19)- (ceil(box.height)-box.height);
        end;
    end;
    // For left corner horizontal collisions
    if checkHorizontalCollision(tl, chunk, false, false) or checkHorizontalCollision(bl, chunk, false, true) then
    begin
        writeln('block left');
        if velocity.x <= 0 then
        begin
            velocity.x := 0;
            pos.x := floor(tl.x+0.2);
        end;
    end;
    end;
end;

procedure inflictDamage (var targetHealth: Integer; damage: Integer);
begin
    targetHealth := targetHealth - damage;
end;

procedure playerAttack (var player: TPlayer; var vel: TVelocity; time: Integer);
begin
    if abs(time - player.lastAttack) > 20 then
    begin
        player.attacking := true;
        if player.direction then
            vel.x := 0.10
        else
            vel.x := -0.10;
        vel.y := 0.2;
        player.lastAttack := time
    end;
end;

procedure resetPlayerAttack(var player: TPlayer; time: Integer; var world: TWorld);
var i: Integer;
begin
    if abs(time - player.lastAttack) > 5 then
    begin
        player.attacking := false; // MAYBE DO SOMETHING WITH ANIMATION I DUNNO
    end
    else
        if player.direction then
            player.vel.x := 0.20
        else
            player.vel.x := -0.20;
        for i := 0 to length(world.mobs) -1 do
        begin
            if (floor(world.mobs[i].pos.x) = floor(player.pos.x)) and (floor(world.mobs[i].pos.y) = floor(player.pos.y)) and player.attacking then
                inflictDamage(world.mobs[i].health, 50);
            writeln(world.mobs[i].health);
        end;
end;

end.