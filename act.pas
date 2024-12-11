unit act;

Interface
uses LMMTypes, SDL2, util, display, math; 

procedure handleInput(keyPressed: String;var key:TKey; var playerAction: TPlayerAction; var direction: Boolean; french,state: Boolean; var running:Boolean; var pause:Boolean);
procedure handleMouse(x:Integer ; y:Integer; world:TWorld; window:TWindow; action:TActs; var playerAction: TPlayerAction; var pause,running:Boolean);
procedure addAction(var playerAction: TPlayerAction; key:TKey);
procedure playerMove(var velocity: TVelocity; blockBelow: Boolean; playerAction: TPlayerAction);
procedure blockAct(playerAction: TPlayerAction; var world: TWorld); 
procedure handleCollision(var velocity: TVelocity; var playerPos: TPosition; box: TBoundingBox; chunk: TChunk);
function isBlockBelow (playerPos: TPosition; box: TBoundingBox; chunk: TChunk): Boolean;

Implementation

procedure handleInput(keyPressed: String;var key:TKey; var playerAction: TPlayerAction; var direction: Boolean; french,state: Boolean; var running:Boolean; var pause:Boolean);
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
      
end;

procedure handleMouse(x:Integer ; y:Integer; world:TWorld; window:TWindow; action:TActs; var playerAction: TPlayerAction; var pause,running:Boolean);
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
            running := False;
    end;
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
                velocity.x := velocity.x - 0.4;
            end;
            WALK_RIGHT: 
            begin
                velocity.x := velocity.x + 0.4;
            end;
            JUMP: 
            begin
                if blockBelow then
                    velocity.y := velocity.y + 0.65;
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
    toleranceY := 0.3;

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

function isBlockBelow (playerPos: TPosition; box: TBoundingBox; chunk: TChunk): Boolean;
var br, bl: TPosition;
begin
    bl.x := playerPos.x;
    bl.y := playerPos.y - box.height;
    br.x := playerPos.x + box.width;
    br.y := playerPos.y - box.height;
    

    isBlockBelow := checkVerticalCollision(br, chunk, true, true) or checkVerticalCollision(bl, chunk, false, true);
end;

procedure handleCollision(var velocity: TVelocity; var playerPos: TPosition; box: TBoundingBox; chunk: TChunk);
var tl, tr, bl, br: TPosition; i: Integer;
begin
    for i := 0 to 1 do
    begin
    // Defining the corners of the player's bounding box
    // Top Left Corner
    tl.x := playerPos.x + i* velocity.x;
    tl.y := playerPos.y + i*velocity.y;
    // Top Right Corner
    tr.x := playerPos.x + box.width + i*velocity.x;
    tr.y := playerPos.y + i*velocity.y;
    // Bottom Left Corner
    bl.x := playerPos.x + i*velocity.x;
    bl.y := playerPos.y - box.height + i*velocity.y;
    // Bottom Right Corner
    br.x := playerPos.x + box.width + i*velocity.x;
    br.y := playerPos.y - box.height + i*velocity.y;

    writeln('Player Position: (', playerPos.x, ', ', playerPos.y, ')');
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
            playerPos.x := floor(tr.x) - box.width;
        end;
    end;
    // For vertical corner colllisions
    if checkVerticalCollision(tr, chunk, true, false) or checkVerticalCollision(tl, chunk, false, false) then
    begin
        writeln('block above');
        if velocity.y > 0 then
        begin
            velocity.y := 0;
            playerPos.y := floor(tl.y);
        end;
    end;
    if checkVerticalCollision(br, chunk, true, true) or checkVerticalCollision(bl, chunk, false, true) then
    begin
        writeln('block below');
        if velocity.y < 0 then
        begin
            velocity.y := 0;
            playerPos.y := ceil(tl.y+0.19)- (ceil(box.height)-box.height);
        end;
    end;
    // For left corner horizontal collisions
    if checkHorizontalCollision(tl, chunk, false, false) or checkHorizontalCollision(bl, chunk, false, true) then
    begin
        writeln('block left');
        if velocity.x < 0 then
        begin
            velocity.x := 0;
            playerPos.x := floor(tl.x+0.2);
        end;
    end;
    end;
end;
end.