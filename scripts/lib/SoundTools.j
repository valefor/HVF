/***********************************************
*
*   SoundTools
*   v3.0.0.2
*   By Magtheridon96
*
*   (Special Thanks to Rising_Dusk)
*
*   - Allows you to play sounds immediately after creating them.
*   - Uses a sound recycler to increase efficiency and save RAM.
*
*   Requirements:
*   -------------
*
*       - Table by Bribe
*           - hiveworkshop.com/forums/jass-resources-412/snippet-new-table-188084/
*       - TimerUtils by Vexorian
*           - wc3c.net/showthread.php?t=101322
*
*   API:
*   ----
*
*       constant boolean DEFAULT_SOUND_STOPS_ON_LEAVE_RANGE
*       constant integer DEFAULT_SOUND_FADE_IN_RATE
*       constant integer DEFAULT_SOUND_FADE_OUT_RATE
*       constant string  DEFAULT_SOUND_EAX_SETTINGS
*       constant integer DEFAULT_SOUND_VOLUME
*       constant integer DEFAULT_SOUND_PITCH
*
*       struct Sound extends array
*
*           readonly string file
*           readonly integer duration
*           readonly boolean looping
*           readonly boolean is3D
*           readonly boolean stopOnLeaveRange
*           readonly integer fadeIn
*           readonly integer fadeOut
*           readonly string eaxSetting
*
*           static method create takes string fileName, integer duration, boolean looping, boolean is3D returns thistype
*               - Creates a sound struct given the filepath, the duration in milliseconds, whether it is looping or not, and whether it is 3D or not.
*           static method createEx takes string fileName, integer duration, boolean looping, boolean is3D, boolean stopOnExitRange, integer fadeIn, integer fadeOut, string eaxSetting returns thistype
*               - In addition to static method create, this allows you to specificy whether the sound stops when the player leaves range, the fadeIn/fadeOut rates and the EAX Setting.
*           static method release takes sound s returns boolean
*               - Releases a sound and throws it into the recycler. Also stops the sound.
*
*           method run takes nothing returns sound
*               - Plays the sound.
*           method runUnit takes unit whichUnit returns sound
*               - Plays the sound on a unit.
*           method runPoint takes real x, real y, real z returns sound
*               - Plays the sound at a point.
*           method runPlayer takes player whichPlayer returns sound
*               - Plays the sound for a player.
*
*           method runEx takes integer volume, integer pitch returns sound
*               - Plays the sound. This function allows you to pass in extra arguments.
*           method runUnitEx takes unit whichUnit, integer volume, integer pitch returns sound
*               - Plays the sound on a unit. This function allows you to pass in extra arguments.
*           method runPointEx takes real x, real y, real z, integer volume, integer pitch returns sound
*               - Plays the sound at a point. This function allows you to pass in extra arguments.
*           method runPlayerEx takes player whichPlayer, integer volume, integer pitch returns sound
*               - Plays the sound for a player. This function allows you to pass in extra arguments.
*
*       function NewSound takes string fileName, integer duration, boolean looping, boolean is3D returns Sound
*           - Creates a sound struct given the filepath, the duration in milliseconds, whether it is looping or not, and whether it is 3D or not.
*       function NewSoundEx takes string fileName, integer duration, boolean looping, boolean is3D, boolean stop, integer fadeInRate, integer fadeOutRate, string eax returns Sound
*           - In addition to static method create, this allows you to specificy whether the sound stops when the player leaves range, the fadeIn/fadeOut rates and the EAX Setting.
*       function ReleaseSound takes sound s returns boolean
*           - Releases a sound and throws it into the recycler. Also stops the sound.
*       function RunSound takes Sound this returns sound
*           - Plays the sound.
*       function RunSoundEx takes Sound this, integer volume, integer pitch returns sound
*           - Plays the sound. This function allows you to pass in extra arguments.
*       function RunSoundOnUnit takes Sound this, unit whichUnit returns sound
*           - Plays the sound on a unit.
*       function RunSoundAtPoint takes Sound this, real x, real y, real z returns sound
*           - Plays the sound at a point.
*       function RunSoundForPlayer takes Sound this, player p returns sound
*           - Plays the sound for a player.
*       function RunSoundOnUnitEx takes Sound this, unit whichUnit, integer volume, real pitch returns sound
*           - Plays the sound on a unit. This function allows you to pass in extra arguments.
*       function RunSoundAtPointEx takes Sound this, real x, real y, real z, integer volume, real pitch returns sound
*           - Plays the sound at a point. This function allows you to pass in extra arguments.
*       function RunSoundForPlayerEx takes Sound this, player p, integer volume, real pitch returns sound
*           - Plays the sound for a player. This function allows you to pass in extra arguments.
*
*   Credits:
*   --------
*
*       - Rising_Dusk (The original system)
*       - Zwiebelchen (Research - He found a ton of Wc3 sound bugs and ways to fix them)
*
***********************************************/
library SoundTools requires Table, TimerUtils
    
    /*
    *   Configuration
    */
    
    globals
        constant boolean DEFAULT_SOUND_STOPS_ON_LEAVE_RANGE = true
        constant integer DEFAULT_SOUND_FADE_IN_RATE = 10
        constant integer DEFAULT_SOUND_FADE_OUT_RATE = 10
        constant string  DEFAULT_SOUND_EAX_SETTINGS = "CombatSoundsEAX"
        constant integer DEFAULT_SOUND_VOLUME = 127
        constant integer DEFAULT_SOUND_PITCH = 1
    endglobals
    
    globals
        private constant integer SOUND_CHANNEL = 5
        private constant integer SOUND_MIN_DIST = 600
        private constant integer SOUND_MAX_DIST = 10000
        private constant integer SOUND_DIST_CUT = 3000
    endglobals
    
    /*
    *   End of Configuration
    */
    
    struct Sound extends array
        private static key tk
        private static key pk
        private static Table tb = tk
        private static Table pt = pk
        private static integer index = 1
        
        private static Table array stack
        private static integer array count
        
        readonly string file
        readonly integer duration
        readonly boolean looping
        readonly boolean is3D
        readonly boolean stopOnLeaveRange
        readonly integer fadeIn
        readonly integer fadeOut
        readonly string eaxSetting
        
        private real pitch
        
        static method createEx takes string fileName, integer dur, boolean loopng, boolean isTD, boolean stop, integer fadeInRate, integer fadeOutRate, string eax returns thistype
            local thistype this = index
            set index = index + 1
            
            set this.file = fileName
            set this.duration = dur
            set this.looping = loopng
            set this.is3D = isTD
            set this.stopOnLeaveRange = stop
            set this.fadeIn = fadeInRate
            set this.fadeOut = fadeOutRate
            set this.eaxSetting = eax
            set this.pitch = 1
            
            set stack[this] = Table.create()
            
            return this
        endmethod
        
        static method create takes string fileName, integer dur, boolean loopng, boolean isTD returns thistype
            return createEx(fileName, dur, loopng, isTD, DEFAULT_SOUND_STOPS_ON_LEAVE_RANGE, DEFAULT_SOUND_FADE_IN_RATE, DEFAULT_SOUND_FADE_OUT_RATE, DEFAULT_SOUND_EAX_SETTINGS)
        endmethod
        
        // Credits to Zwiebelchen for this function
        // He discovered a bug with sound pitches and this function was written to fix that.
        method setSoundPitch takes sound s, real newPitch returns nothing
            if GetSoundIsPlaying(s) or GetSoundIsLoading(s) then
                call SetSoundPitch(s, 1/this.pitch)
                call SetSoundPitch(s, newPitch)
                set this.pitch = newPitch
            elseif newPitch == 1 then
                call SetSoundPitch(s, 1.0001)
                set this.pitch = 1.0001
            else
                call SetSoundPitch(s, newPitch)
                set this.pitch = newPitch
            endif
        endmethod
        
        private static sound snd
        
        private method get takes nothing returns sound
            if count[this] == 0 then
            
                /*
                *   Create new sound and point it to
                *   Sound struct instance.
                */
                set snd = CreateSound(this.file, this.looping, this.is3D, this.stopOnLeaveRange, this.fadeIn, this.fadeOut, this.eaxSetting)
                set pt[GetHandleId(snd)] = this
                
                /*
                *   Configure sound
                */
                call SetSoundDuration(snd, this.duration)
                call SetSoundChannel(snd, SOUND_CHANNEL)
                call SetSoundVolume(snd, DEFAULT_SOUND_VOLUME)
                call this.setSoundPitch(snd, DEFAULT_SOUND_PITCH)
                
                /*
                *   Proper 3D sound configuration
                */
                if this.is3D then
                    call SetSoundDistances(snd, SOUND_MIN_DIST, SOUND_MAX_DIST)
                    call SetSoundDistanceCutoff(snd, SOUND_DIST_CUT)
                    call SetSoundConeAngles(snd, 0, 0, DEFAULT_SOUND_VOLUME)
                    call SetSoundConeOrientation(snd, 0, 0, 0)
                endif
                
                return snd
            endif
            
            /*
            *   Pop out of sound stack.
            */
            set count[this] = count[this] - 1
            return stack[this].sound[count[this]]
        endmethod
        
        private method push takes sound s returns nothing
            set stack[this].sound[count[this]] = s
            set count[this] = count[this] + 1
        endmethod
        
        private static method recycle takes nothing returns nothing
            local timer t = GetExpiredTimer()
            local sound s = tb.sound[GetHandleId(t)]
            
            /*
            *   Stop sound and push to the
            *   stack.
            */
            call StopSound(s, false, true)
            call thistype(GetTimerData(t)).push(s)
            call ReleaseTimer(t)
            
            set t = null
            set s = null
        endmethod
        
        private static integer array next
        private static sound array media
        
        private static method runSounds takes nothing returns nothing
            local thistype this = next[0]
            local timer t
            
            call ReleaseTimer(GetExpiredTimer())
            
            loop
                exitwhen this == 0
                
                /*
                *   Play the sound.
                */
                call StartSound(media[this])
                
                /*
                *   If it is not looping,
                *   we can recycle it when 
                *   it finishes playing.
                */
                if not this.looping then
                    set t = NewTimerEx(this)
                    set tb.sound[GetHandleId(t)] = media[this]
                    call TimerStart(t, this.duration * 0.001, false, function thistype.recycle)
                endif
                
                set media[this] = null
                set this = next[this]
            endloop
            
            set next[0] = 0
            
            set t = null
        endmethod
        
        method run takes nothing returns sound
            debug if this == 0 then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "[SoundTools]Error: Attempted to play null sound.")
                debug return null
            debug endif
            
            if next[0] == 0 then
                call TimerStart(NewTimer(), 0, false, function thistype.runSounds)
            endif
            
            if media[this] == null then
                set next[this] = next[0]
                set next[0] = this
                set media[this] = this.get()
            debug else
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "[SoundTools]Warning: Attempted to run the same sound twice.")
            endif
            
            return media[this]
        endmethod
        
        method runEx takes integer volume, integer newPitch returns sound
            set snd = this.run()
            call SetSoundVolume(snd, volume)
            call this.setSoundPitch(snd, newPitch)
            return snd
        endmethod
        
        static method release takes sound s returns boolean
            local integer id = GetHandleId(s)
            
            if s == null then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "[SoundTools]Error: Attempted to release a null sound.")
                return false
            elseif pt[id] == 0 then
                debug call DisplayTimedTextToPlayer(GetLocalPlayer(), 0, 0, 60, "[SoundTools]Error: Attempted to release a sound not allocated by RunSound.")
                return false
            endif
            
            /*
            *   Stop the sound and push it
            *   to the stack.
            */
            call StopSound(s, false, true)
            call thistype(pt[id]).push(s)
            
            return true
        endmethod
        
        method runUnit takes unit whichUnit returns sound
            set snd = this.run()
            call AttachSoundToUnit(snd, whichUnit)
            return snd
        endmethod
        
        method runUnitEx takes unit whichUnit, integer volume, integer newPitch returns sound
            set snd = this.runUnit(whichUnit)
            call SetSoundVolume(snd, volume)
            call this.setSoundPitch(snd, newPitch)
            return snd
        endmethod
        
        method runPoint takes real x, real y, real z returns sound
            set snd = this.run()
            call SetSoundPosition(snd, x, y, z)
            return snd
        endmethod
        
        method runPointEx takes real x, real y, real z, integer volume, integer newPitch returns sound
            set snd = this.runPoint(x, y, z)
            call SetSoundVolume(snd, volume)
            call this.setSoundPitch(snd, newPitch)
            return snd
        endmethod
        
        method runPlayer takes player p returns sound
            set snd = this.run()
            if GetLocalPlayer() != p then
                call SetSoundVolume(snd, 0)
            endif
            return snd
        endmethod
        
        method runPlayerEx takes player p, integer volume, integer newPitch returns sound
            set snd = this.runPlayer(p)
            call SetSoundVolume(snd, volume)
            call this.setSoundPitch(snd, newPitch)
            return snd
        endmethod
    endstruct
    
    function NewSoundEx takes string fileName, integer duration, boolean looping, boolean is3D, boolean stop, integer fadeInRate, integer fadeOutRate, string eax returns Sound
        return Sound.createEx(fileName, duration, looping, is3D, stop, fadeInRate, fadeOutRate, eax)
    endfunction
    
    function NewSound takes string fileName, integer duration, boolean looping, boolean is3D returns Sound
        return Sound.create(fileName, duration, looping, is3D)
    endfunction
    
    function RunSound takes Sound this returns sound
        return this.run()
    endfunction
    
    function RunSoundEx takes Sound this, integer volume, integer pitch returns sound
        return this.runEx(volume, pitch)
    endfunction
    
    function ReleaseSound takes sound s returns boolean
        return Sound.release(s)
    endfunction
    
    function RunSoundOnUnit takes Sound this, unit whichUnit returns sound
        return this.runUnit(whichUnit)
    endfunction
    
    function RunSoundOnUnitEx takes Sound this, unit whichUnit, integer volume, integer pitch returns sound
        return this.runUnitEx(whichUnit, volume, pitch)
    endfunction
    
    function RunSoundAtPoint takes Sound this, real x, real y, real z returns sound
        return this.runPoint(x, y, z)
    endfunction
    
    function RunSoundAtPointEx takes Sound this, real x, real y, real z, integer volume, integer pitch returns sound
        return this.runPointEx(x, y, z, volume, pitch)
    endfunction
    
    function RunSoundForPlayer takes Sound this, player p returns sound
        return this.runPlayer(p)
    endfunction
    
    function RunSoundForPlayerEx takes Sound this, player p, integer volume, integer pitch returns sound
        return this.runPlayerEx(p, volume, pitch)
    endfunction
    
endlibrary
