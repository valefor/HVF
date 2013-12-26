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
        private integer iMaxHunterHeroType  = 9
        private integer iFirstCodeHunterHero= 'U002'// First Raw Code of Hunter Hero
        private integer iLastCodeHunterHero = 'U00D'// Last Raw Code of Hunter Hero
        private rect    rctDefaultBirthPlace= Rect(- 6464.0, - 2464.0, - 5984.0, - 1952.0)
        //private location locHeroShop = Location(- 6240.0, - 2208.0)
    endglobals

endlibrary