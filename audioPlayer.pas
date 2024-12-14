unit audioPlayer;

Interface

uses LMMTypes, SDL2, sdl2_mixer, sysutils, util;

procedure InitAudio (var audio: TAudio);
procedure playPlayerEffect (audio: TAudio; effect: Integer);
procedure stopChannelEffects (channel: Integer);
procedure stopEffects ();
procedure playMobEffect (audio: TAudio; effect: Integer);
procedure stopMobEffect (audio: TAudio; effect: Integer);
procedure playRandomMobEffect (audio: TAudio);
function isPlaying (audio: TAudio; effect: Integer): Boolean;


implementation

procedure loadEffects (var audio: TAudio);
begin
    audio.playerEffects[1] := Mix_LoadWAV('assets/audio/running.ogg');
    audio.playerEffects[2] := Mix_LoadWAV('assets/audio/jump.ogg');
    audio.playerEffects[3] := Mix_LoadWAV('assets/audio/attack.ogg');
    audio.playerEffects[4] := Mix_LoadWAV('assets/audio/hurt.ogg');
    audio.playerEffects[5] := Mix_LoadWAV('assets/audio/place.ogg');
    audio.playerEffects[6] := Mix_LoadWAV('assets/audio/break.ogg');

    audio.mobEffects[1] := Mix_LoadWAV('assets/audio/rat1.ogg');
    audio.mobEffects[2] := Mix_LoadWAV('assets/audio/rat2.ogg');
    audio.mobEffects[3] := Mix_LoadWAV('assets/audio/rat3.ogg');
end;

procedure InitAudio (var audio: TAudio);
begin
    if Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) < 0 then
    begin
    
        WriteLn('Failed to initialize SDL_mixer: ', Mix_GetError);
        SDL_Quit;
        Halt(1);
    end;

    loadEffects(audio);
end;

procedure playPlayerEffect (audio: TAudio; effect: Integer);
begin
    stopEffects();
    if not isPlaying(audio, effect) then
        if effect = 1 then
            begin
            stopChannelEffects(1);
            Mix_PlayChannel(1, audio.playerEffects[effect], 0)
            end
        else
            Mix_PlayChannel(-1, audio.playerEffects[effect], 0);
end;

procedure stopEffects ();
begin
    Mix_HaltChannel(-1);
end;

procedure stopChannelEffects (channel: Integer);
begin
    Mix_HaltChannel(channel);
end;

procedure playMobEffect (audio: TAudio; effect: Integer);
begin
    if not isPlaying(audio, effect) then
        Mix_PlayChannel(-1, audio.mobEffects[effect], 0);
end;

procedure stopMobEffect (audio: TAudio; effect: Integer);
begin
    Mix_HaltChannel(effect);
end;

procedure playRandomMobEffect (audio: TAudio);
var index: Integer;
begin
    index := Random(length(audio.mobEffects)+1);
    if not isPlaying(audio, index) then
        Mix_PlayChannel(-1, audio.mobEffects[index], 0);
end;

function isPlaying (audio: TAudio; effect: Integer): Boolean;
begin
    if Mix_Playing(effect) = 1 then
        isPlaying := True
    else
        isPlaying := False;
end;


end.