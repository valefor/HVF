library Glue initializer init /* v0.0.1 by Xandria
********************************************************************************
*     Glue : As its name says, this library is the under layout of system since 
*   it depends on predefined units buildings of map, that means if you update 
*   units/buildings rectangles, pls also update this library
*******************************************************************************/
    /***************************************************************************
    * Used Object Id:
    *    Hunter Heros:
    *        'U008'    :    Assaulter    (冲锋者)
    *        'U009'    :    Darter        (飞奔者)
    *        'U004'    :    Peeper        (窥视者)
    *        'U003'    :    Miner        (埋雷者)
    *        'U00A'    :    Balancer    (平衡者)
    *        'U007'    :    Sneaker        (偷袭者)
    *        'U006'    :    Pelter        (投雷者)
    *        'U00B'    :    Butcher        (屠宰者)
    *        'U005'    :    Dogger        (训犬者)
    *        'U00C'    :    RandomHero    (随机猎人)
    *        'U00D'    :    LastRawCodeIdx
    *        'U002'    :    FirstRawCodeIdx
    *        
    *    Farmer Heros:
    *        'H00P'    :    FarmerHero
    *
    *    Animals:
    *        'nshe'    :    Sheep
    *        'npig'    :    Pig
    *        'n000'    :    Snake
    *        'nech'    :    Chicken
    *
    *    Buildings    -    Animal    [IsUnitType(unit, UNIT_TYPE_STRUCTURE)]
    *        'h002'    :    SheepFold
    *        'h001'    :    Pigen
    *        'h00U'    :    SnakeHole
    *        'h00V'    :    Cage
    *    Buildings    -    Animal (No Spawn)
    *        'h010'    :    SheepFoldNS
    *        'h00Z'    :    PigenNS
    *        'h011'    :    SnakeHoleNS
    *        'h012'    :    CageNS
    *
    *    Items
    *        'I00J'    :    Seed
    *        'I00G'    :    PigenNS
    *        'I003'    :    SnakeHoleNS
    ***************************************************************************/

    /***************************************************************************
    * Globals
    ***************************************************************************/
    globals

        /***********************************************************************
        * UnitTypeId (UTI)
        ***********************************************************************/
        constant integer CST_UTI_SightDummy         ='e005'
        // *** Hunter
        constant integer CST_INT_MaxHunterHeroType  = 9
        constant integer CST_UTI_HunterHeroMiner    ='U003'
        constant integer CST_UTI_HunterHeroPeeper   ='U004'
        constant integer CST_UTI_HunterHeroDogger   ='U005'
        constant integer CST_UTI_HunterHeroPelter   ='U006'
        constant integer CST_UTI_HunterHeroSneaker  ='U007'
        constant integer CST_UTI_HunterHeroAssaulter='U008'
        constant integer CST_UTI_HunterHeroDarter   ='U009'
        constant integer CST_UTI_HunterHeroBalancer ='U00A'
        constant integer CST_UTI_HunterHeroButcher  ='U00B'
        constant integer CST_UTI_HunterHeroRandom   ='U00C'
        constant integer CST_UTI_HunterHeroFirstcode='U002'// First Raw Code of Hunter Hero
        constant integer CST_UTI_HunterHeroLastcode ='U00D'// Last Raw Code of Hunter Hero
        // Dead
        constant integer CST_UTI_HunterLGDHeroSyl   ='UH17'// Sylvanas
        // Legendary
        constant integer CST_UTI_HunterHeroSkeleton ='nskg'
        
        // Itembox
        constant integer CST_UTI_HunterItemBox  ='h00I'
        constant integer CST_UTI_HunterHeroBox  ='h01M'
        constant integer CST_UTI_HunterWorker   ='h00B'
        
        // *** Farmer
        constant integer CST_UTI_FarmerHero ='H00P'
        // Farmer army
        constant integer CST_UTI_ArmySuperTank  ='h006'
        constant integer CST_UTI_ArmyArchMage   ='n00H'
        constant integer CST_UTI_ArmyGnoll      ='n00S'
        constant integer CST_UTI_ArmyKnight     ='n003'
        constant integer CST_UTI_ArmyTank       ='h00N'
        constant integer CST_UTI_ArmyAxe        ='h007'
        constant integer CST_UTI_ArmySpear      ='n002'
        constant integer CST_UTI_ArmyDog        ='n00L'
        
        // *** Farming Animal
        constant integer CST_UTI_Sheep      ='nshe'
        constant integer CST_UTI_Pig        ='npig'
        constant integer CST_UTI_Snake      ='n000'
        constant integer CST_UTI_Chicken    ='nech'
        
        // *** Neutral Animal
        constant integer CST_UTI_Rabbit     ='n00K'
        constant integer CST_UTI_Deer       ='n00I'
        constant integer CST_UTI_Dog        ='n00J'
        constant integer CST_UTI_Vulture    ='nvul'
        
        /***********************************************************************
        * BuildingTypeId (BTI)
        ***********************************************************************/
        constant integer CST_BTI_SheepFold  ='h002'
        constant integer CST_BTI_Pigen      ='h001'
        constant integer CST_BTI_SnakeHole  ='h00U'
        constant integer CST_BTI_Cage       ='h00V'
        
        constant integer CST_BTI_SheepFoldNs='h010'
        constant integer CST_BTI_PigenNs    ='h00Z'
        constant integer CST_BTI_SnakeHoleNs='h011'
        constant integer CST_BTI_CageNs     ='h012'
        
        constant integer CST_BTI_SmallTree  ='h00O'
        constant integer CST_BTI_MagicTree  ='h00T'
        constant integer CST_BTI_TowerBase  ='h003'
        constant integer CST_BTI_Slaughterhouse = 'h00K'
        constant integer CST_BTI_ArmsRecycler   = 'h014'
        
        /***********************************************************************
        * AbilityId (ABI)
        ***********************************************************************/
        constant integer CST_ABI_Invulnerable ='Avul'
        
        constant integer CST_ABI_ButcherAll ='A011'
        constant integer CST_ABI_ButcherOne ='A00N'
        constant integer CST_ABI_AllAnimalSpawnOff ='A024'
        constant integer CST_ABI_AllAnimalSpawnOn  ='A025'
        constant integer CST_ABI_AnimalAutoLoad ='A03O'
        constant integer CST_ABI_AnimalLoadAll  ='A03M'
        constant integer CST_ABI_AnimalUnloadAll='A03N'
        constant integer CST_ABI_NightVision='A04B'
        
        // Hunters Abilities
        constant integer CST_ABI_PortableShop='A00X'
        constant integer CST_ABI_Hide='AHid'
        
        // Farmers Abilities
        constant integer CST_ABI_FReveal='A00R'
        
        /***********************************************************************
        * ItemTypeId (ITI)
        ***********************************************************************/
        constant integer CST_ITI_MagicSeed      ='I00J'
        constant integer CST_ITI_MythticGrass   ='I003'
        constant integer CST_ITI_MythticFlower  ='I00G'
        
        constant integer CST_ITI_TowerBase      ='I00Y'
        constant integer CST_ITI_RetrainBook    ='tret'
        constant integer CST_ITI_Invincible     ='pnvu'
        constant integer CST_ITI_InvincibleNoCD ='I014'
        constant integer CST_ITI_FarmerWood     ='I00P'
        
        constant integer CST_ITI_RabbitMeat     ='I00H'
        constant integer CST_ITI_Venision       ='I00X'
        constant integer CST_ITI_DogMeat        ='I00W'
        constant integer CST_ITI_VultureMeat    ='I018'
        
        constant integer CST_ITI_HunterMiniShop ='I000'
        constant integer CST_ITI_HewAxe         ='I005'
        constant integer CST_ITI_HunterWood     ='lmbr'
        
        /***********************************************************************
        * DestructableTypeId (DTI)
        ***********************************************************************/
        constant integer CST_DTI_MagicTree      ='ZTtc'
        constant integer CST_DTI_SummerTree     ='LTlt'
        constant integer CST_DTI_GateLever      ='DTlv'
        constant integer CST_DTI_Gate           ='LTg3'
        
        /***********************************************************************
        * TechID (TCI)
        ***********************************************************************/
        constant integer CST_TCI_Plague         ='Rupc'
        constant integer CST_TCI_Level1Upgrade  ='R00N'
        constant integer CST_TCI_HeroLifeUp     ='R005'
        constant integer CST_TCI_TowerLifeUp    ='R00G'
        constant integer CST_TCI_TowerHealing   ='R00L'
        constant integer CST_TCI_TowerVisionUp  ='R00R'
        
        // Hunters Tech
        constant integer CST_TCI_BodyGen    ='Ruex'
        constant integer CST_TCI_BackPack   ='Ropm'
        constant integer CST_TCI_BodyBomb   ='R00B'
        constant integer CST_TCI_HuntNet    ='Ruwb'
        constant integer CST_TCI_Vigor      ='R009'
        
        // Hunters Tech for locking legend hero
        constant integer CST_TCI_RankFirst      ='RH00'
        constant integer CST_TCI_RankGuard      ='RH03'
        constant integer CST_TCI_RankRanger     ='RH04'
        constant integer CST_TCI_RankGeneral    ='RH05'
        constant integer CST_TCI_RankCaptain    ='RH06'
        constant integer CST_TCI_RankMarshal    ='RH07'
        constant integer CST_TCI_RankEliteFirst ='RH10'
        constant integer CST_TCI_RankEliteGuard ='RH13'
        constant integer CST_TCI_RankEliteRanger='RH14'
        constant integer CST_TCI_RankGranGeneral='RH15'
        constant integer CST_TCI_RankGranCaptain='RH16'
        constant integer CST_TCI_RankGranMarshal='RH17'
        
        /***********************************************************************
        * Others
        ***********************************************************************/
        constant real CST_Facing_Building = 270.0
        constant real CST_Facing_Unit = 90.0
        
    endglobals

    /***************************************************************************
    * Preloading:
    *   To have better game experience, aka reducing in-game lag,
    *   we have to preload some units/abilities before game start
    ***************************************************************************/
    struct Preloading extends array
    
        private static group preloadUnits
        private static real invX = -99999.0
        private static real invY = -99999.0
        
        // This method must be called in struct's onInit method if other struct
        // wants to preload some units
        static method addUnit takes integer uti returns nothing
            if preloadUnits == null then
                return
            endif
            
            call GroupAddUnit( preloadUnits ,CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), uti, invX, invY, CST_Facing_Unit) )
        endmethod
        
        private static method filterRemoveUnit takes nothing returns nothing
            call RemoveUnit(GetFilterUnit())
        endmethod
        
        // Flush preloading units at beginning of game
        static method flush takes nothing returns nothing
            // Don't use GroupEnumUnitsOfPlayer since it'll iterate all units of PLAYER_NEUTRAL_PASSIVE
            // call GroupEnumUnitsOfPlayer(preloadUnits, Player(PLAYER_NEUTRAL_PASSIVE), Filter(function thistype.filterRemoveUnit))
            // Here we just want to clear the preloadUnits
            local unit u

            loop
                set u = FirstOfGroup(preloadUnits)
                exitwhen u == null
                call GroupRemoveUnit(preloadUnits,u)
                call RemoveUnit(u)
            endloop

            call DestroyGroup(preloadUnits)
        endmethod
        
        private static method onInit takes nothing returns nothing
            set preloadUnits = CreateGroup()
            
            call thistype.addUnit(CST_UTI_HunterHeroMiner)
            call thistype.addUnit(CST_UTI_HunterHeroPeeper)
            call thistype.addUnit(CST_UTI_HunterHeroDogger)
            call thistype.addUnit(CST_UTI_HunterHeroPelter)
            call thistype.addUnit(CST_UTI_HunterHeroSneaker)
            call thistype.addUnit(CST_UTI_HunterHeroAssaulter)
            call thistype.addUnit(CST_UTI_HunterHeroDarter)
            call thistype.addUnit(CST_UTI_HunterHeroBalancer)
            call thistype.addUnit(CST_UTI_HunterHeroButcher)
            call thistype.addUnit(CST_UTI_HunterHeroRandom)
            
            call thistype.addUnit(CST_UTI_FarmerHero)
            
            call thistype.addUnit(CST_UTI_Sheep)
            call thistype.addUnit(CST_UTI_Pig)
            call thistype.addUnit(CST_UTI_Snake)
            call thistype.addUnit(CST_UTI_Chicken)
        endmethod
    endstruct

    /***********************************************************************
    * Map struct:
    * contains map locations, settings, util functions
    ***********************************************************************/
    struct Map extends array
        /***********************************************************************
        * Region & location, little memory leakage, not big deal, let it be
        *   Note! Don't use bj_VARs like 'bj_mapInitialPlayableArea' since it's 
        *   blizzard var that wouldn't be available until 'InitBlizzard()' is 
        *   called, if you try to use these vars, you'll always get '0'
        ***********************************************************************/
        static rect regionHeroRevive
        static rect regionSecretGarden
        static rect regionWaterLand1
        static rect regionWaterLand2
        static rect regionWaterLand3
        
        static location heroReviveLoc
        
        /***********************************************************************
        * Settings & Parameters
        ***********************************************************************/
        static real array itemBoxXs[4]
        static real array itemBoxYs[4]
        static real array mapCenterXs[4]
        static real array mapCenterYs[4]
        static real array mapAlignXs[4]
        static real array mapAlignYs[4]
        static integer mapSize  = 3 // Full size(default)
        static real boundBase   = 8192.0
        static real baseX
        static real baseY
        static real marginX
        static real marginY
        static real mapMaxX
        static real mapMinX
        static real mapMaxY                
        static real mapMinY
        
        /***********************************************************************
        * Widegets
        ***********************************************************************/
        // static integer array iWidgets
        // static integer iWidgetsCount

        static method operator randomX takes nothing returns real
            call SetRandomSeed(GetRandomInt(0, 1000000))
            return GetRandomReal(thistype.mapMinX, thistype.mapMaxX)
        endmethod
        
        static method operator randomY takes nothing returns real
            call SetRandomSeed(GetRandomInt(0, 1000000))
            return GetRandomReal(thistype.mapMinY, thistype.mapMaxY)
        endmethod
        
        static method operator centerX takes nothing returns real
            return mapCenterXs[mapSize]
        endmethod
        
        static method operator centerY takes nothing returns real
            return mapCenterYs[mapSize]
        endmethod

        private static method enumMoveDest takes nothing returns nothing
            local destructable dest = GetEnumDestructable()
            call CreateDestructable(GetDestructableTypeId(dest), GetDestructableX(dest) + mapCenterXs[mapSize]-mapCenterXs[3], GetDestructableY(dest) + mapCenterYs[mapSize]-mapCenterYs[3], GetRandomReal(0, 360), GetRandomReal(0.80, 1.20), GetRandomInt(0, 9))
            call RemoveDestructable( dest )
            set dest = null
        endmethod
        
        private static method filterMoveUnit takes nothing returns boolean
            local unit u = GetFilterUnit()
            call SetUnitPosition(u, GetUnitX(u)+mapCenterXs[mapSize], GetUnitY(u)+mapCenterYs[mapSize])
            set u = null
            return false
        endmethod
        
        static method resize takes player p,integer n returns nothing
            local real minX
            local real minY
            local real maxX
            local real maxY
            local group dummyGroup = CreateGroup()
            local rect r = Rect(mapCenterXs[3]-boundBase, mapCenterYs[3]-boundBase, mapCenterXs[3]+boundBase, mapCenterYs[3]+boundBase)
            debug call BJDebugMsg("Map MinX:"+R2S(mapMinX)+", MinY:"+R2S(mapMinY)+", MaxX:"+R2S(mapMaxX)+", MaxY:"+R2S(mapMaxY))
            
            // If n is the default mapSize(3), pls don't do map rebuild!
            // Otherwise you will find that trees have no hight which means
            // We can see anything behide tree!!
            if n != mapSize then 
                // Here we go
                set mapSize = n
                // Rebuild trees/units...
                call EnumDestructablesInRect(r, null, function thistype.enumMoveDest)
                // Move preset unit/building to new position
                call GroupEnumUnitsInRect(dummyGroup, r, Filter(function thistype.filterMoveUnit))
            endif

            if (GetLocalPlayer() == p) then
                // The playerable area
                set mapMinX = mapCenterXs[mapSize] - baseX
                set mapMinY = mapCenterYs[mapSize] - baseY
                set mapMaxX = mapCenterXs[mapSize] + mapAlignXs[mapSize]
                set mapMaxY = mapCenterYs[mapSize] + mapAlignYs[mapSize]

                set minX = mapCenterXs[mapSize] - baseX
                set minY = mapCenterYs[mapSize] - baseY
                set maxX = mapCenterXs[mapSize] + baseX
                set maxY = mapCenterYs[mapSize] + baseY
                // Use only local code (no net traffic) within this block to avoid desyncs.
                //call SetCameraBounds(mapMinX+marginX, mapMinY+marginY, mapMinX+marginX, mapMaxY-marginY, mapMaxX-marginX, mapMaxY-marginY, mapMaxX-marginX, mapMinY+marginY)
                call SetCameraBounds(minX+marginX, minY+marginY, maxX-marginX, maxY-marginY, minX+marginX, maxY-marginY, maxX-marginX, minY+marginY)
            endif
            //call SetCameraBounds((0-baseX) + GetCameraMargin(CAMERA_MARGIN_LEFT),(0-baseY) + GetCameraMargin(CAMERA_MARGIN_BOTTOM),mapXs[n] - GetCameraMargin(CAMERA_MARGIN_RIGHT),mapYs[n] - GetCameraMargin(CAMERA_MARGIN_TOP),(0-baseX) + GetCameraMargin(CAMERA_MARGIN_LEFT),mapYs[n] - GetCameraMargin(CAMERA_MARGIN_TOP),mapXs[n] - GetCameraMargin(CAMERA_MARGIN_RIGHT),(0-baseY) + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
            
            // Reset/Init coordinates
            call thistype.initCoordinates()
            // Reset/Init widgets
            call thistype.initWidgets()
            
            call RemoveRect(r)
            call DestroyGroup(dummyGroup)
            set r = null
            set dummyGroup = null
        endmethod
        
        private static method getBoundPoints takes nothing returns nothing
            //call BJDebugMsg("Margin left:"+R2S(GetCameraMargin(CAMERA_MARGIN_LEFT))+", Margin bottom:"+R2S(GetCameraMargin(CAMERA_MARGIN_BOTTOM))+", Margin right:"+R2S(GetCameraMargin(CAMERA_MARGIN_RIGHT))+", Margin top:"+R2S(GetCameraMargin(CAMERA_MARGIN_TOP)))
            //set mapMinX = GetCameraBoundMinX()-GetCameraMargin(CAMERA_MARGIN_LEFT)
            //set mapMinY = GetCameraBoundMinY()-GetCameraMargin(CAMERA_MARGIN_BOTTOM)
            //set mapMaxX = GetCameraBoundMaxX()+GetCameraMargin(CAMERA_MARGIN_RIGHT)
            //set mapMaxY = GetCameraBoundMaxY()+GetCameraMargin(CAMERA_MARGIN_TOP)
            //call BJDebugMsg("Map MinX:"+R2S(mapMinX)+", MinY:"+R2S(mapMinY)+", MaxX:"+R2S(mapMaxX)+", MaxY:"+R2S(mapMaxY))
        endmethod
        
        // Init all map widgets which relies on map size, must be called on each map resizing
        private static method initWidgets takes nothing returns nothing
            call WGT_Gate.init()
        endmethod
        
        // Init all coordinates of rect, location, must be called on each map resizing
        private static method initCoordinates takes nothing returns nothing
            set regionHeroRevive=Rect(- 6464.0 + mapCenterXs[mapSize], - 2464.0 + mapCenterYs[mapSize], - 5984.0 + mapCenterXs[mapSize], - 1952.0 + mapCenterYs[mapSize])
            set regionSecretGarden=Rect(5888.0 + mapCenterXs[mapSize], - 3840.0 + mapCenterYs[mapSize], 6400.0 + mapCenterXs[mapSize], - 3328.0 + mapCenterYs[mapSize])
            set regionWaterLand1=Rect(3840.0 + mapCenterXs[mapSize], 4640.0 + mapCenterYs[mapSize], 6848.0 + mapCenterXs[mapSize], 6944.0 + mapCenterYs[mapSize])
            set regionWaterLand2=Rect(5376.0 + mapCenterXs[mapSize], 1408.0 + mapCenterYs[mapSize], 6560.0 + mapCenterXs[mapSize], 3584.0 + mapCenterYs[mapSize])
            set regionWaterLand3=Rect(- 7712.0 + mapCenterXs[mapSize], - 1600.0 + mapCenterYs[mapSize], - 7232.0 + mapCenterXs[mapSize], - 1248.0 + mapCenterYs[mapSize])
            set heroReviveLoc=Location(GetRectCenterX(regionHeroRevive), GetRectCenterY(regionHeroRevive))
            
            set itemBoxXs[0] = - 6976.0 + mapCenterXs[mapSize]
            set itemBoxXs[1] = - 6720.0 + mapCenterXs[mapSize]
            set itemBoxXs[2] = - 6976.0 + mapCenterXs[mapSize]
            set itemBoxXs[3] = - 6720.0 + mapCenterXs[mapSize]
            
            set itemBoxYs[0] = - 1472.0 + mapCenterYs[mapSize]
            set itemBoxYs[1] = - 1472.0 + mapCenterYs[mapSize]
            set itemBoxYs[2] = - 1728.0 + mapCenterYs[mapSize]
            set itemBoxYs[3] = - 1728.0 + mapCenterYs[mapSize]
        endmethod
        
        private static method onInit takes nothing returns nothing
            // minX = -7424.0, maxX = 7424.0, minY = -7680.0, maxY = 7680.0
            set baseX = boundBase - 256.0  // 8192-256
            set baseY = boundBase - 256.0  // 8192-256
            // marginX = 512, marginY = 256
            set marginX = 512.0 // up to your map setting
            set marginY = 256.0 // up to your map setting
            
            /*******************************************************************
            * Center position:
            *       0.0    -16384.0 (m1)
            *   16384.0    -16384.0 (m2)
            *   16384.0         0.0 (m3)
            *       0.0         0.0 (m4)
            *******************************************************************/
            set mapCenterXs[0] = 0.0
            set mapCenterXs[1] = boundBase * 2
            set mapCenterXs[2] = boundBase * 2
            set mapCenterXs[3] = 0.0
            
            set mapCenterYs[0] = 0.0 - boundBase * 2
            set mapCenterYs[1] = 0.0 - boundBase * 2
            set mapCenterYs[2] = 0.0
            set mapCenterYs[3] = 0.0
            
            /*******************************************************************
            * Align for different map size:
            *   128.0 * 7   128.0 * 3   (m1)
            *   128.0 * 62  128.0 * 3   (m2)
            *   128.0 * 40  128.0 * 48  (m3)
            *   128.0 * 62  128.0 * 62  (m4)
            *******************************************************************/
            set mapAlignXs[0]  = 128.0 * 7
            set mapAlignXs[1]  = 128.0 * 62
            set mapAlignXs[2]  = 128.0 * 40
            set mapAlignXs[3]  = 128.0 * 62
            
            set mapAlignYs[0]  = 128.0 * 5
            set mapAlignYs[1]  = 128.0 * 5
            set mapAlignYs[2]  = 128.0 * 48
            set mapAlignYs[3]  = 128.0 * 62
            
            //
            //      X1          Y1          X2          Y2          X3          Y3          X4          Y5
            //      XL          YB          XR          YT          XL          YT          XR          YB
            //   -7424.0     -7680.0      7424.0      7680.0     -7424.0      7680.0      7424.0      -7680.0    
            
            // The initial value
            set mapMinX = GetCameraBoundMinX()-GetCameraMargin(CAMERA_MARGIN_LEFT)
            set mapMinY = GetCameraBoundMinY()-GetCameraMargin(CAMERA_MARGIN_BOTTOM)
            set mapMaxX = GetCameraBoundMaxX()+GetCameraMargin(CAMERA_MARGIN_RIGHT)
            set mapMaxY = GetCameraBoundMaxY()+GetCameraMargin(CAMERA_MARGIN_TOP)
            debug call BJDebugMsg("Map MinX:"+R2S(mapMinX)+", MinY:"+R2S(mapMinY)+", MaxX:"+R2S(mapMaxX)+", MaxY:"+R2S(mapMaxY))
            
        endmethod
    endstruct
    
    /***********************************************************************
    * Widgets on map:
    *   1 - WGT_Gate, control gate of hunter base
    ***********************************************************************/
    struct WGT_Gate extends array
        private static destructable inUpLever
        private static destructable inDownLever
        private static destructable outUpLever
        private static destructable outDownLever
        private static destructable gate
        
        static method open takes nothing returns boolean
            if (GetDestructableLife(gate) > 0) then
                call KillDestructable(gate)
            endif
            call SetDestructableAnimation(gate, "death alternate")
            
            call SetDestructableLife(inUpLever, 0.00)
            call SetDestructableLife(outUpLever, 0.00)
            call SetDestructableLife(inDownLever, GetDestructableMaxLife(inDownLever))
            call SetDestructableLife(outDownLever, GetDestructableMaxLife(outDownLever))
            return false
        endmethod
        
        static method close takes nothing returns boolean
            
            if (GetDestructableLife(gate) <= 0) then
                call DestructableRestoreLife(gate, GetDestructableMaxLife(gate), true)
            endif
            call SetDestructableAnimation(gate, "stand")
            call SetDestructableLife(inDownLever, 0.00)
            call SetDestructableLife(outDownLever, 0.00)
            call SetDestructableLife(inUpLever, GetDestructableMaxLife(inUpLever))
            call SetDestructableLife(outUpLever, GetDestructableMaxLife(outUpLever))
            return false
        endmethod
        
        private static method onLeverDeath takes nothing returns boolean
            return false
        endmethod
        
        static method init takes nothing returns nothing
            local trigger trigGateOpen  = CreateTrigger()
            local trigger trigGateClose = CreateTrigger()
            set inUpLever   = CreateDeadDestructable(CST_DTI_GateLever, - 5088.0 + Map.centerX, - 2080.0 + Map.centerY, 39.000, 1.063, 0)
            set inDownLever = CreateDeadDestructable(CST_DTI_GateLever, - 5088.0 + Map.centerX, - 2528.0 + Map.centerY, 39.000, 1.063, 0)
            set outUpLever  = CreateDeadDestructable(CST_DTI_GateLever, - 4896.0 + Map.centerX, - 2080.0 + Map.centerY, 39.000, 1.063, 0)
            set outDownLever= CreateDeadDestructable(CST_DTI_GateLever, - 4896.0 + Map.centerX, - 2528.0 + Map.centerY, 39.000, 1.063, 0)
            set gate        = CreateDeadDestructable(CST_DTI_Gate, - 4992.0 + Map.centerX, - 2304.0 + Map.centerY, 39.000, 1.063, 0)
            
            call SetDestructableInvulnerable(gate, true)
            
            call TriggerAddCondition(trigGateOpen, Filter(function thistype.open) )
            call TriggerAddCondition(trigGateClose, Filter(function thistype.close) )
            call TriggerRegisterDeathEvent(trigGateOpen, inUpLever)
            call TriggerRegisterDeathEvent(trigGateOpen, outUpLever)
            call TriggerRegisterDeathEvent(trigGateClose, inDownLever)
            call TriggerRegisterDeathEvent(trigGateClose, outDownLever)
            
            call thistype.open()
        endmethod
    endstruct
    
    function IsUnitHunterHero takes unit u returns boolean
        return GetUnitTypeId(u) < CST_UTI_HunterHeroLastcode and GetUnitTypeId(u) > CST_UTI_HunterHeroFirstcode
    endfunction
    
    function IsUnitFarmerAnimal takes unit u returns boolean
        return GetUnitTypeId(u)==CST_UTI_Sheep or GetUnitTypeId(u)==CST_UTI_Pig or GetUnitTypeId(u)==CST_UTI_Snake or GetUnitTypeId(u)==CST_UTI_Chicken
    endfunction
    
    function IsUnitFarmerFarmingBuilding takes unit u returns boolean
        return GetUnitTypeId(u)==CST_BTI_SheepFold or GetUnitTypeId(u)==CST_BTI_Pigen or GetUnitTypeId(u)==CST_BTI_SnakeHole or GetUnitTypeId(u)==CST_BTI_Cage
    endfunction
    
    function CreateHunterBeginItems takes unit hero returns nothing
        call UnitAddItemToSlotById(hero, 'I005', 0)
        call UnitAddItemToSlotById(hero, 'shrs', 1)
        call UnitAddItemToSlotById(hero, 'pman', 2)
        call UnitAddItemToSlotById(hero, 'moon', 3)
        call UnitAddItemToSlotById(hero, 'dust', 4)
        call UnitAddItemToSlotById(hero, 'I000', 5)
    endfunction
    
    function CreateHunterBeginUnits takes player p, integer i returns nothing
        local unit u = CreateUnit(p, CST_UTI_HunterItemBox, Map.itemBoxXs[i], Map.itemBoxYs[i], CST_Facing_Building)
        //call UnitAddItemToSlotById(u, 'I005', 0)
        //call UnitAddItemToSlotById(u, 'shrs', 1)
        //call UnitAddItemToSlotById(u, 'pman', 2)
        //call UnitAddItemToSlotById(u, 'moon', 3)
        //call UnitAddItemToSlotById(u, 'dust', 4)
        //call UnitAddItemToSlotById(u, 'I000', 5)
        call CreateUnit(p, CST_UTI_HunterWorker, GetRandomReal(GetRectMinX(Map.regionHeroRevive), GetRectMaxX(Map.regionHeroRevive)), GetRandomReal(GetRectMinY(Map.regionHeroRevive), GetRectMaxY(Map.regionHeroRevive)), CST_Facing_Unit)
        // call PanCameraToTimedLocForPlayer(p, Map.heroReviveLoc, 0.50)
        set u = null
    endfunction
    
    function GetHeroAvatar takes unit u returns string
        local integer uti = GetUnitTypeId(u)
        if IsUnitType(u, UNIT_TYPE_DEAD) then
            if uti == CST_UTI_FarmerHero then
                return "Replaceabletextures\\Commandbuttonsdisabled\\DISBTNKobold.blp"
            elseif uti == CST_UTI_HunterHeroAssaulter or uti == CST_UTI_HunterHeroButcher then
                return "Replaceabletextures\\Commandbuttonsdisabled\\DISBTNBehemothRider.blp"
            elseif uti == CST_UTI_HunterHeroDarter or uti == CST_UTI_HunterHeroDogger then
                return "Replaceabletextures\\Commandbuttonsdisabled\\DISBTNTroll.blp"
            elseif uti == CST_UTI_HunterHeroPeeper or uti == CST_UTI_HunterHeroSneaker then
                return "Replaceabletextures\\Commandbuttonsdisabled\\DISBTNTrollBoarRiderVI.blp"
            elseif uti == CST_UTI_HunterHeroPelter or uti == CST_UTI_HunterHeroMiner or uti == CST_UTI_HunterHeroBalancer then
                return "Replaceabletextures\\Commandbuttonsdisabled\\DISBTNRaider.blp"
            elseif uti == CST_UTI_HunterLGDHeroSyl then
                return "ReplaceableTextures\\CommandButtonsDisabled\\DISBTNDarkSylvanas.blp"
            else
                
                return ""
            endif
        else
            if uti == CST_UTI_FarmerHero then
                return "ReplaceableTextures\\CommandButtons\\BTNKobold.blp"
            elseif uti == CST_UTI_HunterHeroAssaulter or uti == CST_UTI_HunterHeroButcher then
                return "ReplaceableTextures\\CommandButtons\\BTNBehemothRider.blp"
            elseif uti == CST_UTI_HunterHeroDarter or uti == CST_UTI_HunterHeroDogger then
                return "ReplaceableTextures\\CommandButtons\\BTNTroll.blp"
            elseif uti == CST_UTI_HunterHeroPeeper or uti == CST_UTI_HunterHeroSneaker then
                return "ReplaceableTextures\\CommandButtons\\BTNTrollBoarRiderVI.blp"
            elseif uti == CST_UTI_HunterHeroPelter or uti == CST_UTI_HunterHeroMiner or uti == CST_UTI_HunterHeroBalancer then
                return "ReplaceableTextures\\CommandButtons\\BTNRaider.blp"
            elseif uti == CST_UTI_HunterLGDHeroSyl then
                return "ReplaceableTextures\\CommandButtons\\BTNDarkSylvanas.blp"
            else
                return ""
            endif
        endif
        
    endfunction
    
    function GetRandomHeroUti takes nothing returns integer
        local integer randomInt = GetRandomInt(1, CST_INT_MaxHunterHeroType)
        if randomInt == 1 then
            return CST_UTI_HunterHeroMiner
        elseif randomInt == 2 then
            return CST_UTI_HunterHeroPeeper
        elseif randomInt == 3 then
            return CST_UTI_HunterHeroDogger
        elseif randomInt == 4 then
            return CST_UTI_HunterHeroPelter
        elseif randomInt == 5 then
            return CST_UTI_HunterHeroSneaker
        elseif randomInt == 6 then
            return CST_UTI_HunterHeroAssaulter
        elseif randomInt == 7 then
            return CST_UTI_HunterHeroDarter
        elseif randomInt == 8 then
            return CST_UTI_HunterHeroBalancer
        elseif randomInt == 9 then
            return CST_UTI_HunterHeroButcher
        endif
        
        return CST_UTI_HunterHeroBalancer
    endfunction
    
    /***************************************************************************
	* Library Initiation
	***************************************************************************/
    private function init takes nothing returns nothing
        call Preloading.flush()
    endfunction
endlibrary