unit LMMTypes;

interface
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
    
    TWorld = record 
        chunks: ChunkArray;
        unsavedChunks: array of Integer;
        name: String;
        player: TPlayer;
        cameraPos: TPosition;
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
SURFACEWIDTH = 500; { largeur en pixels de la surface de jeu }
SURFACEHEIGHT = 500; { hauteur en pixels de la surface de jeu }
DIMENSIONBLOCK = 5; {Taille de l'intérieur des blocks}

implementation
end.