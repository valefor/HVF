//==============================================================================
//                       BONUS PLUGINS -- v1.3
//==============================================================================
//
//  AUTHOR:
//       * Cohadar
//
//  PURPOSE:
//       * Bonus plugins are used for creating abilities needed by Bonus system
//       * Bonus plugins should be disabled by default
//
//  HOW TO USE PLUGINS:
//       * Enable plugin trigger, save the map, close the map, open the map, disable plugin trigger
//       * You must do this for every plugin trigger
//
//  WARNING:
//       * Plugin triggers create lots abilities that start with 'A8'
//         Check your map to make sure rawcodes don't collide with something you already have
//         or your existing abilities may get overwritten.
//       * Some linear abilities use skillbook with Base Order ID: attributemodskill
//         Make sure you do not use this order ID for your custom skillbooks
//       * Ability generation can take a very long time (up to 10 min), be patient.
//         I also noticed it sometimes bugs if you alt-tab during generation.
//
//  CONVENTIONS:
//       * All rawcodes start with 'A8'
//       * Binary bonus rawcodes start from zero  // 'A8L0', 'A8L1', 'A8L2', ...
//         Linear bonus rawcodes start from one   // 'A8e1', 'A8e2', 'A8e3', ...
//       * Binary bonuses use uppercase letter on 3-rd digit
//         Linear bonuses use lowercase letter on 3-rd digit
//         Spellbooks use uppercase letter on 3-rd digit (same as their linear bonus ability) 'A8e1' -> 'A8E1'
//       
//  THANKS TO:
//       * PitzerMike - for making grimex
//
//  NOTE: 
//       * You should probably preload bonus abilities to prevent first cast lag
//  
//==============================================================================

//==============================================================================
//  BONUS Plugin: Life and Mana 
//==============================================================================
//  This trigger should be disabled by default
//==============================================================================
//  To generate bonus abilities:
//  Enable this trigger, save the map, close the map, open the map, disable this trigger
//==============================================================================

//---------------------------------< LIFE >-----------------------------------//
//! external ObjectMerger w3a AIl2 A8L0 anam "Bonus Life" Ilif 1 100   ansf "(binary 0)"
//! external ObjectMerger w3a AIl2 A8L1 anam "Bonus Life" Ilif 1 200   ansf "(binary 1)"
//! external ObjectMerger w3a AIl2 A8L2 anam "Bonus Life" Ilif 1 400   ansf "(binary 2)"
//! external ObjectMerger w3a AIl2 A8L3 anam "Bonus Life" Ilif 1 800   ansf "(binary 3)"
//! external ObjectMerger w3a AIl2 A8L4 anam "Bonus Life" Ilif 1 1600  ansf "(binary 4)"
//! external ObjectMerger w3a AIl2 A8L5 anam "Bonus Life" Ilif 1 3200  ansf "(binary 5)"
//! external ObjectMerger w3a AIl2 A8L6 anam "Bonus Life" Ilif 1 6400  ansf "(binary 6)"
//! external ObjectMerger w3a AIl2 A8L7 anam "Bonus Life" Ilif 1 12800 ansf "(binary 7)"

//---------------------------------< MANA >-----------------------------------//
//! external ObjectMerger w3a AImz A8M0 anam "Bonus Mana" Iman 1 100   ansf "(binary 0)"
//! external ObjectMerger w3a AImz A8M1 anam "Bonus Mana" Iman 1 200   ansf "(binary 1)"
//! external ObjectMerger w3a AImz A8M2 anam "Bonus Mana" Iman 1 400   ansf "(binary 2)"
//! external ObjectMerger w3a AImz A8M3 anam "Bonus Mana" Iman 1 800   ansf "(binary 3)"
//! external ObjectMerger w3a AImz A8M4 anam "Bonus Mana" Iman 1 1600  ansf "(binary 4)"
//! external ObjectMerger w3a AImz A8M5 anam "Bonus Mana" Iman 1 3200  ansf "(binary 5)"
//! external ObjectMerger w3a AImz A8M6 anam "Bonus Mana" Iman 1 6400  ansf "(binary 6)"
//! external ObjectMerger w3a AImz A8M7 anam "Bonus Mana" Iman 1 12800 ansf "(binary 7)"

//==============================================================================

//==============================================================================
//  BONUS Plugin: Armor and Damage
//==============================================================================
//  This trigger should be disabled by default
//==============================================================================
//  To generate bonus abilities:
//  Enable this trigger, save the map, close the map, open the map, disable this trigger
//==============================================================================

//---------------------------------< ARMOR >----------------------------------//
//! external ObjectMerger w3a AId2 A8D0 anam "Bonus Armor" Idef 1 1   ansf "(binary 0)"
//! external ObjectMerger w3a AId2 A8D1 anam "Bonus Armor" Idef 1 2   ansf "(binary 1)"
//! external ObjectMerger w3a AId2 A8D2 anam "Bonus Armor" Idef 1 4   ansf "(binary 2)"
//! external ObjectMerger w3a AId2 A8D3 anam "Bonus Armor" Idef 1 8   ansf "(binary 3)"
//! external ObjectMerger w3a AId2 A8D4 anam "Bonus Armor" Idef 1 16  ansf "(binary 4)"
//! external ObjectMerger w3a AId2 A8D5 anam "Bonus Armor" Idef 1 32  ansf "(binary 5)"
//! external ObjectMerger w3a AId2 A8D6 anam "Bonus Armor" Idef 1 64  ansf "(binary 6)"
//! external ObjectMerger w3a AId2 A8D7 anam "Bonus Armor" Idef 1 128 ansf "(binary 7)"

//---------------------------------< DAMAGE >---------------------------------//
//! external ObjectMerger w3a AItg A8T0 anam "Bonus Damage" Iatt 1 5   ansf "(binary 0)"
//! external ObjectMerger w3a AItg A8T1 anam "Bonus Damage" Iatt 1 10  ansf "(binary 1)"
//! external ObjectMerger w3a AItg A8T2 anam "Bonus Damage" Iatt 1 20  ansf "(binary 2)"
//! external ObjectMerger w3a AItg A8T3 anam "Bonus Damage" Iatt 1 40  ansf "(binary 3)"
//! external ObjectMerger w3a AItg A8T4 anam "Bonus Damage" Iatt 1 80  ansf "(binary 4)"
//! external ObjectMerger w3a AItg A8T5 anam "Bonus Damage" Iatt 1 160 ansf "(binary 5)"
//! external ObjectMerger w3a AItg A8T6 anam "Bonus Damage" Iatt 1 320 ansf "(binary 6)"
//! external ObjectMerger w3a AItg A8T7 anam "Bonus Damage" Iatt 1 640 ansf "(binary 7)"

//==============================================================================

//==============================================================================
//  BONUS Plugin: Strength, Agility and Intelligence
//==============================================================================
//  This trigger should be disabled by default
//==============================================================================
//  To generate bonus abilities:
//  Enable this trigger, save the map, close the map, open the map, disable this trigger
//==============================================================================

//---------------------------------< STR >-----------------------------------//
//! external ObjectMerger w3a AIs1 A8S0 anam "Bonus Strength" Istr 1 1   ansf "(binary 0)"
//! external ObjectMerger w3a AIs1 A8S1 anam "Bonus Strength" Istr 1 2   ansf "(binary 1)"
//! external ObjectMerger w3a AIs1 A8S2 anam "Bonus Strength" Istr 1 4   ansf "(binary 2)"
//! external ObjectMerger w3a AIs1 A8S3 anam "Bonus Strength" Istr 1 8   ansf "(binary 3)"
//! external ObjectMerger w3a AIs1 A8S4 anam "Bonus Strength" Istr 1 16  ansf "(binary 4)"
//! external ObjectMerger w3a AIs1 A8S5 anam "Bonus Strength" Istr 1 32  ansf "(binary 5)"
//! external ObjectMerger w3a AIs1 A8S6 anam "Bonus Strength" Istr 1 64  ansf "(binary 6)"
//! external ObjectMerger w3a AIs1 A8S7 anam "Bonus Strength" Istr 1 128 ansf "(binary 7)"

//---------------------------------< AGI >-----------------------------------//
//! external ObjectMerger w3a AIa1 A8A0 anam "Bonus Agility" Iagi 1 1   ansf "(binary 0)"
//! external ObjectMerger w3a AIa1 A8A1 anam "Bonus Agility" Iagi 1 2   ansf "(binary 1)"
//! external ObjectMerger w3a AIa1 A8A2 anam "Bonus Agility" Iagi 1 4   ansf "(binary 2)"
//! external ObjectMerger w3a AIa1 A8A3 anam "Bonus Agility" Iagi 1 8   ansf "(binary 3)"
//! external ObjectMerger w3a AIa1 A8A4 anam "Bonus Agility" Iagi 1 16  ansf "(binary 4)"
//! external ObjectMerger w3a AIa1 A8A5 anam "Bonus Agility" Iagi 1 32  ansf "(binary 5)"
//! external ObjectMerger w3a AIa1 A8A6 anam "Bonus Agility" Iagi 1 64  ansf "(binary 6)"
//! external ObjectMerger w3a AIa1 A8A7 anam "Bonus Agility" Iagi 1 128 ansf "(binary 7)"

//---------------------------------< INT >-----------------------------------//
//! external ObjectMerger w3a AIi1 A8I0 anam "Bonus Intelligence" Iint 1 1   ansf "(binary 0)"
//! external ObjectMerger w3a AIi1 A8I1 anam "Bonus Intelligence" Iint 1 2   ansf "(binary 1)"
//! external ObjectMerger w3a AIi1 A8I2 anam "Bonus Intelligence" Iint 1 4   ansf "(binary 2)"
//! external ObjectMerger w3a AIi1 A8I3 anam "Bonus Intelligence" Iint 1 8   ansf "(binary 3)"
//! external ObjectMerger w3a AIi1 A8I4 anam "Bonus Intelligence" Iint 1 16  ansf "(binary 4)"
//! external ObjectMerger w3a AIi1 A8I5 anam "Bonus Intelligence" Iint 1 32  ansf "(binary 5)"
//! external ObjectMerger w3a AIi1 A8I6 anam "Bonus Intelligence" Iint 1 64  ansf "(binary 6)"
//! external ObjectMerger w3a AIi1 A8I7 anam "Bonus Intelligence" Iint 1 128 ansf "(binary 7)"

//==============================================================================

//==============================================================================
//  BONUS Plugin: Attack and Move Speed
//==============================================================================
//  This trigger should be disabled by default
//==============================================================================
//  To generate bonus abilities:
//  Enable this trigger, save the map, close the map, open the map, disable this trigger
//==============================================================================

//---------------------------------< ATTS >----------------------------------//
//! external ObjectMerger w3a AIsx A8H0 anam "Bonus Attack Speed" Isx1 1 0.05 ansf "(binary 0)"
//! external ObjectMerger w3a AIsx A8H1 anam "Bonus Attack Speed" Isx1 1 0.10 ansf "(binary 1)"
//! external ObjectMerger w3a AIsx A8H2 anam "Bonus Attack Speed" Isx1 1 0.20 ansf "(binary 2)"
//! external ObjectMerger w3a AIsx A8H3 anam "Bonus Attack Speed" Isx1 1 0.40 ansf "(binary 3)"
//! external ObjectMerger w3a AIsx A8H4 anam "Bonus Attack Speed" Isx1 1 0.80 ansf "(binary 4)"
//! external ObjectMerger w3a AIsx A8H5 anam "Bonus Attack Speed" Isx1 1 1.60 ansf "(binary 5)"
//! external ObjectMerger w3a AIsx A8H6 anam "Bonus Attack Speed" Isx1 1 3.20 ansf "(binary 6)"

//---------------------------------< MOVE >----------------------------------//
//! external ObjectMerger w3a AIms A8P1 anam "Bonus Move Speed" Imvb 1 10  ansf "(linear 1)"
//! external ObjectMerger w3a AIms A8P2 anam "Bonus Move Speed" Imvb 1 20  ansf "(linear 2)"
//! external ObjectMerger w3a AIms A8P3 anam "Bonus Move Speed" Imvb 1 30  ansf "(linear 3)"
//! external ObjectMerger w3a AIms A8P4 anam "Bonus Move Speed" Imvb 1 40  ansf "(linear 4)"
//! external ObjectMerger w3a AIms A8P5 anam "Bonus Move Speed" Imvb 1 50  ansf "(linear 5)"
//! external ObjectMerger w3a AIms A8P6 anam "Bonus Move Speed" Imvb 1 60  ansf "(linear 6)"
//! external ObjectMerger w3a AIms A8P7 anam "Bonus Move Speed" Imvb 1 70  ansf "(linear 7)"
//! external ObjectMerger w3a AIms A8P8 anam "Bonus Move Speed" Imvb 1 80  ansf "(linear 8)"
//! external ObjectMerger w3a AIms A8P9 anam "Bonus Move Speed" Imvb 1 90  ansf "(linear 9)"
//! external ObjectMerger w3a AIms A8P: anam "Bonus Move Speed" Imvb 1 100 ansf "(linear :)"

//==============================================================================

//==============================================================================
//  BONUS Plugin: Evasion and Critical
//==============================================================================
//  This trigger should be disabled by default
//==============================================================================
//  To generate bonus abilities:
//  Enable this trigger, save the map, close the map, open the map, disable this trigger
//==============================================================================

//---------------------------------< EVASION >-------------------------------//
//! external ObjectMerger w3a AIev A8e1 anam "Bonus Evasion" Eev1 1 0.05 ansf "(linear 1)"
//! external ObjectMerger w3a AIev A8e2 anam "Bonus Evasion" Eev1 1 0.10 ansf "(linear 2)"
//! external ObjectMerger w3a AIev A8e3 anam "Bonus Evasion" Eev1 1 0.15 ansf "(linear 3)"
//! external ObjectMerger w3a AIev A8e4 anam "Bonus Evasion" Eev1 1 0.20 ansf "(linear 4)"
//! external ObjectMerger w3a AIev A8e5 anam "Bonus Evasion" Eev1 1 0.25 ansf "(linear 5)"
//! external ObjectMerger w3a AIev A8e6 anam "Bonus Evasion" Eev1 1 0.30 ansf "(linear 6)"
//! external ObjectMerger w3a AIev A8e7 anam "Bonus Evasion" Eev1 1 0.35 ansf "(linear 7)"
//! external ObjectMerger w3a AIev A8e8 anam "Bonus Evasion" Eev1 1 0.40 ansf "(linear 8)"
//-- spellbook
//! external ObjectMerger w3a Aspb A8E1 anam "Bonus Evasion" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8e1 ansf "(spellbook 1)" aart "ReplaceableTextures\CommandButtons\BTNEvasion.blp"
//! external ObjectMerger w3a Aspb A8E2 anam "Bonus Evasion" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8e2 ansf "(spellbook 2)" aart "ReplaceableTextures\CommandButtons\BTNEvasion.blp"
//! external ObjectMerger w3a Aspb A8E3 anam "Bonus Evasion" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8e3 ansf "(spellbook 3)" aart "ReplaceableTextures\CommandButtons\BTNEvasion.blp"
//! external ObjectMerger w3a Aspb A8E4 anam "Bonus Evasion" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8e4 ansf "(spellbook 4)" aart "ReplaceableTextures\CommandButtons\BTNEvasion.blp"
//! external ObjectMerger w3a Aspb A8E5 anam "Bonus Evasion" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8e5 ansf "(spellbook 5)" aart "ReplaceableTextures\CommandButtons\BTNEvasion.blp"
//! external ObjectMerger w3a Aspb A8E6 anam "Bonus Evasion" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8e6 ansf "(spellbook 6)" aart "ReplaceableTextures\CommandButtons\BTNEvasion.blp"
//! external ObjectMerger w3a Aspb A8E7 anam "Bonus Evasion" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8e7 ansf "(spellbook 7)" aart "ReplaceableTextures\CommandButtons\BTNEvasion.blp"
//! external ObjectMerger w3a Aspb A8E8 anam "Bonus Evasion" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8e8 ansf "(spellbook 8)" aart "ReplaceableTextures\CommandButtons\BTNEvasion.blp"

//---------------------------------< CRITICAL >-------------------------------//
//! external ObjectMerger w3a AIcs A8c1 anam "Bonus Critical" Ocr1 1 5  ansf "(linear 1)"
//! external ObjectMerger w3a AIcs A8c2 anam "Bonus Critical" Ocr1 1 10 ansf "(linear 2)"
//! external ObjectMerger w3a AIcs A8c3 anam "Bonus Critical" Ocr1 1 15 ansf "(linear 3)"
//! external ObjectMerger w3a AIcs A8c4 anam "Bonus Critical" Ocr1 1 20 ansf "(linear 4)"
//! external ObjectMerger w3a AIcs A8c5 anam "Bonus Critical" Ocr1 1 25 ansf "(linear 5)"
//! external ObjectMerger w3a AIcs A8c6 anam "Bonus Critical" Ocr1 1 30 ansf "(linear 6)"
//! external ObjectMerger w3a AIcs A8c7 anam "Bonus Critical" Ocr1 1 35 ansf "(linear 7)"
//! external ObjectMerger w3a AIcs A8c8 anam "Bonus Critical" Ocr1 1 40 ansf "(linear 8)"
//-- spellbook
//! external ObjectMerger w3a Aspb A8C1 anam "Bonus Critical" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8c1 ansf "(spellbook 1)" aart "ReplaceableTextures\CommandButtons\BTNCriticalStrike.blp"
//! external ObjectMerger w3a Aspb A8C2 anam "Bonus Critical" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8c2 ansf "(spellbook 2)" aart "ReplaceableTextures\CommandButtons\BTNCriticalStrike.blp"
//! external ObjectMerger w3a Aspb A8C3 anam "Bonus Critical" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8c3 ansf "(spellbook 3)" aart "ReplaceableTextures\CommandButtons\BTNCriticalStrike.blp"
//! external ObjectMerger w3a Aspb A8C4 anam "Bonus Critical" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8c4 ansf "(spellbook 4)" aart "ReplaceableTextures\CommandButtons\BTNCriticalStrike.blp"
//! external ObjectMerger w3a Aspb A8C5 anam "Bonus Critical" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8c5 ansf "(spellbook 5)" aart "ReplaceableTextures\CommandButtons\BTNCriticalStrike.blp"
//! external ObjectMerger w3a Aspb A8C6 anam "Bonus Critical" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8c6 ansf "(spellbook 6)" aart "ReplaceableTextures\CommandButtons\BTNCriticalStrike.blp"
//! external ObjectMerger w3a Aspb A8C7 anam "Bonus Critical" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8c7 ansf "(spellbook 7)" aart "ReplaceableTextures\CommandButtons\BTNCriticalStrike.blp"
//! external ObjectMerger w3a Aspb A8C8 anam "Bonus Critical" spb5 1 "attributemodskill" spb4 1 1 spb3 1 1 spb2 1 True spb1 1 A8c8 ansf "(spellbook 8)" aart "ReplaceableTextures\CommandButtons\BTNCriticalStrike.blp"

//==============================================================================