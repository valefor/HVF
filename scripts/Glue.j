library Glue /* v0.0.1 Xandria
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
    *
    *    Buildings    -    Animal    [IsUnitType(unit, UNIT_TYPE_STRUCTURE)]
    *        'h002'    :    SheepFold
    *        'h001'    :    Pigen
    *        'h00U'    :    SnakeHole
    *        'h00V'    :    Cage
    ***************************************************************************/

    /***************************************************************************
    * Globals
    ***************************************************************************/
    globals
        
        constant rect    CST_RCT_DefaultBirthPlace= Rect(- 6464.0, - 2464.0, - 5984.0, - 1952.0)
        //private location locHeroShop = Location(- 6240.0, - 2208.0)
        
        
        /***********************************************************************
        * UnitTypeId (UTI)
        ***********************************************************************/
        // *** Hunter
        constant integer CST_INT_MaxHunterHeroType  = 9
        constant integer CST_UTI_HunterHeroFirstcode='U002'// First Raw Code of Hunter Hero
        constant integer CST_UTI_HunterHeroLastcode ='U00D'// Last Raw Code of Hunter Hero
        
        // *** Farmer
        constant integer CST_UTI_FarmerHero ='H00P'
        
        // *** Animal
        constant integer CST_UTI_Sheep      ='nshe'
        constant integer CST_UTI_Pig        ='npig'
        constant integer CST_UTI_Snake      ='n000'
        constant integer CST_UTI_Chicken    ='nech'
        
        // *** BuildingTypeId (BTI)
        constant integer CST_BTI_SheepFold  ='h002'
        constant integer CST_BTI_Pigen      ='h001'
        constant integer CST_BTI_SnakeHole  ='h00U'
        constant integer CST_BTI_Cage       ='h00V'
        
    endglobals

endlibrary