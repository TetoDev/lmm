unit LMMTypes;

interface
type
    IntArray = array of Integer; // Dynamic array of integers
    

    TChunk = record
        layout: array[0..99,0..99] of Integer;
        chunkIndex: Integer;
    end;

    ChunkArray = array of TChunk; // Dynamic array of chunks

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
        mobs: array of TMob;
        worldFile: Text;
        time: Integer;
    end;

    

implementation
end.