unit LMMTypes;

interface

uses sdl2;

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

    TPlayer = record
        pos: TPosition;
        vel: TVelocity;
        health: Integer;
    end;

    TMob = record
        pos: TPosition;
        vel: TVelocity;
        health: Integer;
    end;

    TTextures = Array[1..6] of PSDL_TEXTURE;
    
    TWorld = record 
        chunks: ChunkArray;
        lastLeftChunk:Integer;
        LastRightChunk: Integer;
        unsavedChunks: array of Integer;
        name: String;
        seed:Integer;
        player: TPlayer;
        cameraPos: TPosition;
        textures: TTextures;
        mobs: array of TMob;
        worldFile: Text;
        time: Integer;
    end;

    TActs = (JUMP, CROUCH, WALK_RIGHT, WALK_LEFT, PLACE_BLOCK, REMOVE_BLOCK);

    actsArray = array of TActs;

    TPlayerAction = record 
        acts : actsArray;
        selectedBlock: TPosition;
    end;

const 
SURFACEWIDTH = 800; { largeur en pixels de la surface de jeu }
SURFACEHEIGHT = 800; { hauteur en pixels de la surface de jeu }
BLOCKDISPLAYED = 13; {Taille de l'intérieur des blocks}

implementation
end.