unit act;

Interface
uses LMMTypes, SDL2, util, display, math; 

procedure handleInput(keyPressed: TSDL_Keycode; var playerAction: TPlayerAction; french: Boolean);
procedure handleMouse(x:Integer ; y:Integer; world:TWorld; window:TWindow; action:TActs; var playerAction: TPlayerAction);
procedure playerMove(var velocity: TVelocity; blockBelow: Boolean; playerAction: TPlayerAction);
procedure blockAct(playerAction: TPlayerAction; var world: TWorld); 
procedure handleCollision(var velocity: TVelocity; var playerPos: TPosition; box: TBoundingBox; chunk: TChunk);

Implementation

procedure handleInput(keyPressed: TSDL_Keycode; var playerAction: TPlayerAction; french: Boolean);
begin
    //Suivant la touche appuyée on effectue différente action
    if french then
        case keyPressed of // FRENCH LAYOUT
            SDLK_q: 
            begin 
                AddActToArray(playerAction.acts, WALK_LEFT);
            end;
            SDLK_d: 
            begin 
                AddActToArray(playerAction.acts, WALK_RIGHT);
            end;
            SDLK_z: 
            begin 
                AddActToArray(playerAction.acts, JUMP);
            end;
            SDLK_s: 
            begin 
                AddActToArray(playerAction.acts, CROUCH);
            end;
    else
        case keyPressed of // ENGLISH LAYOUT
            SDLK_a: 
            begin 
                AddActToArray(playerAction.acts, WALK_LEFT);
            end;
            SDLK_d: 
            begin 
                AddActToArray(playerAction.acts, WALK_RIGHT);
            end;
            SDLK_w: 
            begin 
                AddActToArray(playerAction.acts, JUMP);
            end;
            SDLK_s: 
            begin 
                AddActToArray(playerAction.acts, CROUCH);
            end;
        end;
    end;
end;

procedure handleMouse(x:Integer ; y:Integer; world:TWorld; window:TWindow; action:TActs; var playerAction: TPlayerAction);
begin
    playerAction.selectedBlock.x := world.player.pos.x + x div Trunc(SURFACEWIDTH/BLOCKDISPLAYED) - ((window.width div SIZE)-1) div 2;
    playerAction.selectedBlock.y := world.player.pos.y - y div Trunc(SURFACEWIDTH/BLOCKDISPLAYED) + ((window.height div SIZE)-1) div 2;
    AddActToArray(playerAction.acts, action)
end;
procedure playerMove(var velocity: TVelocity; blockBelow: Boolean; playerAction: TPlayerAction);
var i: Integer;
    action: TActs;
begin
    for i:= 0 to length(playerAction.acts) -1 do
    begin
        action := playerAction.acts[i];
        case action of
            WALK_LEFT: 
            begin
                velocity.x := velocity.x - 0.5;
            end;
            WALK_RIGHT: 
            begin
                velocity.x := velocity.x + 0.5;
            end;
            JUMP: 
            begin
                if blockBelow then
                    velocity.y := velocity.y + 1;
            end;
            CROUCH: 
            begin
                //On ne fait rien
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
            end;
            REMOVE_BLOCK: 
            begin
                currentChunk.layout[abs(x)][y] := 0;
            end;
        end;
    end;
    reinsertChunk(world,currentChunk)
end;

function checkVerticalCollision(corner: TPosition; chunk: TChunk; isDown: Boolean): Boolean;
var tolerance, correctionY : Real; BlockX, BlockY: Integer;
begin
    tolerance := 0.0001;

    if isDown then
        correctionY := corner.y - tolerance
    else
        correctionY := corner.y + tolerance;

    // checkVerticalCollision := false; 

    // Checking vertical collisions
    BlockX := floor(corner.x);
    BlockY := floor(correctionY);

    if chunk.layout[BlockX][BlockY] > 0 then
        begin
            checkVerticalCollision := true;
        end;
end;

function checkHorizontalCollision(corner: TPosition; chunk: TChunk; isRight: Boolean): Boolean;
var tolerance, correctionX : Real; BlockX, BlockY: Integer;
begin
    tolerance := 0.0001;

    if isRight then
        correctionX := corner.x + tolerance
    else
        correctionX := corner.x - tolerance;

    // checkHorizontalCollision := false;

    // Checking horizontal collisions
    BlockX := floor(correctionX);
    BlockY := floor(corner.y);
    
    if chunk.layout[BlockX][BlockY] > 0 then
    begin
        checkHorizontalCollision := true;
    end;
end;

procedure handleCollision(var velocity: TVelocity; var playerPos: TPosition; box: TBoundingBox; chunk: TChunk);
var tl, tr, bl, br: TPosition;
begin
    writeln(box.width);
    // Defining the corners of the player's bounding box
    // Top Left Corner
    tl.x := playerPos.x;
    tl.y := playerPos.y;
    // Top Right Corner
    tr.x := playerPos.x + box.width;
    tr.y := playerPos.y;
    // Bottom Left Corner
    bl.x := playerPos.x;
    bl.y := playerPos.y - box.height;
    // Bottom Right Corner
    br.x := playerPos.x + box.width;
    br.y := playerPos.y - box.height;

    writeln('Player Position: (', playerPos.x, ', ', playerPos.y, ')');
    writeln('Top Left: (', tl.x, ', ', tl.y, ')');
    writeln('Top Right: (', tr.x, ', ', tr.y, ')');
    writeln('Bottom Left: (', bl.x, ', ', bl.y, ')');
    writeln('Bottom Right: (', br.x, ', ', br.y, ')');

    // Checking for collision
    // For right corner horizontal collisions
    if checkHorizontalCollision(tr, chunk, true) or checkHorizontalCollision(br, chunk, true) then
    begin
        writeln('block right');
        velocity.x := 0;
        playerPos.x := tr.x - box.width;
    end;

    // For vertical corner colllisions
    if checkVerticalCollision(tr, chunk, false) or checkVerticalCollision(tl, chunk, false) then
    begin
        writeln('block above');
        velocity.y := 0;
    end;
    if checkVerticalCollision(br, chunk, true) or checkVerticalCollision(bl, chunk, true) then
    begin
        writeln('block below');
        velocity.y := 0;
    end;

    // For left corner horizontal collisions
    if checkHorizontalCollision(tl, chunk, false) or checkHorizontalCollision(bl, chunk, false) then
    begin
        writeln('block left');
        velocity.x := 0;
        playerPos.x := tl.x;
    end;
end;
end.