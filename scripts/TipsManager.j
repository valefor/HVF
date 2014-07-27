library TipsManager initializer init /* v0.0.1 by Xandria
*/  uses    Alloc         /*
*/          TimeManager   /*
*/          YDWERecord    /*
********************************************************************************
*   Tips Manager: Manage Quests and Helper Message
*******************************************************************************/

globals
    constant integer QUESTTYPE_REQ_DISCOVERED   = 0
    constant integer QUESTTYPE_REQ_UNDISCOVERED = 1
    constant integer QUESTTYPE_OPT_DISCOVERED   = 2
    constant integer QUESTTYPE_OPT_UNDISCOVERED = 3
    
    constant string QUESTICON_Ambush = "ReplaceableTextures\\CommandButtons\\BTNAmbush.blp"
    
endglobals

struct Quests extends array

    static method create takes nothing returns thistype
        call CreateQuestBJ( QUESTTYPE_REQ_DISCOVERED, QST_H_TitleBasic, QST_H_IntroBasic, QUESTICON_Ambush )
        call CreateQuestBJ( QUESTTYPE_REQ_DISCOVERED, QST_F_TitleBasic, QST_F_IntroBasic, QUESTICON_Ambush )
        
        return -1
    endmethod
endstruct

struct Helper
    private static string array HunterHelper
    private static string array FarmerHelper
    private static integer ticks

    // Init helper message
    private static method initMsgs takes nothing returns nothing
        set HunterHelper[1] = HELP_H_1_HelpCommand
        set HunterHelper[2] = HELP_H_2_HellFire
        set HunterHelper[3] = HELP_H_3_NeuAnimal
        set HunterHelper[4] = HELP_H_4_RocketLauncher
        set HunterHelper[5] = HELP_H_5_MagicSeed
        set HunterHelper[6] = HELP_H_6_TechResearch
        set HunterHelper[7] = HELP_H_7_MineInShop
        set HunterHelper[8] = HELP_H_8_HowToDestoryTower
        set HunterHelper[9] = HELP_H_9_Avantar
        set HunterHelper[10] = HELP_H_10_SkeletonFighter
        set HunterHelper[11] = HELP_H_11_InvisiblePotion
        set HunterHelper[12] = HELP_H_12_StunMine
        set HunterHelper[13] = HELP_H_13_TeleportAndEscape
        set HunterHelper[14] = HELP_H_14_HideAndWin    
    
        set FarmerHelper[1] = HELP_F_1_HelpCommand          // 1
        set FarmerHelper[2] = HELP_F_2_FarmerChar           // 3
        set FarmerHelper[3] = HELP_F_3_PigenUpgrade         // 5
        set FarmerHelper[4] = HELP_F_4_PunishInfighting     // 7
        set FarmerHelper[5] = HELP_F_5_HideYourBase         // 10
        set FarmerHelper[6] = HELP_F_6_Slaughterhouse       // 13
        set FarmerHelper[7] = HELP_F_7_TechResearch         // 16
        set FarmerHelper[8] = HELP_F_8_ConscriptionStrategy // 19
        set FarmerHelper[9] = HELP_F_9_FarmerShop           // 22
        set FarmerHelper[10] = HELP_F_10_WoodingAxe         // 26
        set FarmerHelper[11] = HELP_F_11_Avatar             // 30
        set FarmerHelper[12] = HELP_F_12_SuperTank          // 34
        set FarmerHelper[13] = HELP_F_13_ArchMage           // 38
        set FarmerHelper[14] = HELP_F_14_SlaughterThemAll
    endmethod
    
    private static method showIndexMsg takes integer idx returns nothing
        local Hunter h = Hunter[Hunter.first]
		local Farmer f = Farmer[Farmer.first]
		local string tag = "[*" + ARGB(CST_COLOR_Tips).str(MSG_Tips) + "*]"
        loop
            exitwhen f.end
            call DisplayTimedTextToPlayer(f.get, 0, 0, CST_MSGDUR_Beaware, tag+ARGB(CST_COLOR_Beaware).str(FarmerHelper[idx]))
            set f = f.next
        endloop
        
        loop
            exitwhen h.end
            call DisplayTimedTextToPlayer(h.get, 0, 0, CST_MSGDUR_Beaware, tag+ARGB(CST_COLOR_Beaware).str(HunterHelper[idx]))
            set h = h.next
        endloop
    endmethod
    
    // Show helper message
    static method show takes nothing returns boolean
        local integer index = ticks
        local boolean showMsg = false
        
        set thistype.ticks = thistype.ticks + 1
        debug call BJDebugMsg("Debug >>>> ticks:" + I2S(ticks))            
        if ticks > 22 and ticks <=38 then
            if IsIntDividableBy(ticks - 22, 4) then
                set index = 9 + R2I((ticks - 22)/4)
                set showMsg = true
            endif
        elseif ticks > 7 and ticks <=22 then
            if IsIntDividableBy(ticks - 7, 3) then
                set index = 4 + R2I((ticks - 7)/3)
                set showMsg = true
            endif
        elseif ticks > 1 and ticks <=7 then
            if IsIntDividableBy(ticks - 1, 2) then
                set index = 1 + R2I((ticks - 1)/2)
                set showMsg = true
            endif
        else
            set index = 1
            set showMsg = true
        endif
        
        // Calculate index
        if ticks >= TimerManager.otDetectionOff.count then
            set index = 14
            // Show this message every 3 minitues
            if IsIntDividableBy((ticks-TimerManager.otDetectionOff.count), 3) then
                set showMsg = true
            endif
        endif
        
        if showMsg then
            call thistype.showIndexMsg(index)
        endif
        
        return false
    endmethod
    
    private static method onInit takes nothing returns nothing
        set thistype.ticks = 0
        call thistype.initMsgs()
        
        // Register to TimerManger
        call TimerManager.pt60s.register(Filter(function thistype.show))
    endmethod
endstruct

    /***************************************************************************
	* Library Initiation
	***************************************************************************/
    private function init takes nothing returns nothing
        call Quests.create()
    endfunction

endlibrary
