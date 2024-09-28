unit LMMTypes;

interface
type
    TChunk = record
        layout: array[0..99] of array[0.99] of Integer;
        chunkIndex: Integer;
    end;

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
        chunks: array of TChunk;
        unsavedChunks: array of Integer;
        name: String;
        player: TPlayer;
        mobs: array of TMob;
        worldFile: Text;
        time: Integer;
    end;

    IntArray = array of Integer; // Dynamic array of integers
    ChunkArray = array of TChunk; // Dynamic array of chunks

implementation
end.