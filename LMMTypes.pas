unit LMMTypes;

interface

uses sdl2,sdl2_image;

type
    IntArray = array of Integer; // Dynamic array of integers
    

    TChunk = record
        layout: array[0..99,0..99] of Integer;
        chunkIndex: Integer;
    end;

    ChunkArray = array of TChunk; // Dynamic array of chunks

    StringArray = array of String;

    TPosition = record
        x: Real;
        y: Real;
    end;

    TVelocity = record
        x: Real;
        y: Real;
    end;

    TBoundingBox = record
        width: Real;
        height: Real;
    end;

    TPlayer = record
        pos: TPosition;
        vel: TVelocity;
        boundingBox: TBoundingBox;
        health: Integer;
        heldItem:Integer;
        direction:Boolean;
    end;

    TMob = record
        pos: TPosition;
        vel: TVelocity;
        boundingBox: TBoundingBox;
        health: Integer;
        direction:Integer;
        lastAttack: Integer;
    end;


    TMobTexture = record
        mobFram: Integer;
        mobAction:integer;
        AnimFinished:Boolean;
    end;

    mobArray = array of TMob;
    mobTextureArray = array of TMobTexture;

    TTextures = record
        blocks: Array[1..6] of PSDL_TEXTURE;
        mobs: Array [1..3] of PSDL_TEXTURE;
        sky: PSDL_TEXTURE;
        player: Array[1..5] of PSDL_TEXTURE;
        logo:PSDL_TEXTURE;
    end;

    TAnimationData = record
        Fram: Integer;
        PlayerNbFram: Array[1..5] of Integer;
        mobNbFram: Array[1..3] of Integer;
        playerStep:Integer;
        playerAction:integer;
        mobsData : mobTextureArray;
    end;

    TWorld = record 
        chunks: ChunkArray;
        lastChunk: Integer;
        unsavedChunks: array of Integer;
        name: String;
        seed:Integer;
        player: TPlayer;
        cameraPos: TPosition;
        mobs: mobArray;
        worldFile: Text;
        time: Integer;
    end;

    TActs = (JUMP, CROUCH, WALK_RIGHT, WALK_LEFT, PLACE_BLOCK, REMOVE_BLOCK);

    actsArray = array of TActs;

    TPlayerAction = record 
        acts : actsArray;
        selectedBlock: TPosition;
    end;

    TWindow = record 
        width, height: Integer;
        window: PSDL_window;
    end;

    TKey = record
        z,q,s,d :Boolean;
    end;

const 
SURFACEWIDTH = 800; { largeur en pixels de la surface de jeu }
SURFACEHEIGHT = 800; { hauteur en pixels de la surface de jeu }
BLOCKDISPLAYED = 13; {Taille de l'intérieur des blocks}
SIZE = Trunc(SURFACEWIDTH/BLOCKDISPLAYED);

implementation
end.