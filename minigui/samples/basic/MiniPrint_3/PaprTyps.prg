/*
   Build a paper types list (array)
*/

FUNCTION MakPaprArr()

    LOCAL cPapInfo := ;
        '66,A2 (420x594mm);8,A3 (297x420mm);63,A3 Extra (322x445mm);68,A3 Extra Transverse (322x445mm);76,A3 Rotated (420x297mm);'+;
        '67,A3 Transverse (297x420mm);9,A4 (210x297mm);53,A4 Extra (9.27x12.69");60,A4 Plus (210x330mm);77,A4 Rotated (297x210mm);'+;
        '10,A4 Small (210x297mm);55,A4 Transverse (210x297mm);11,A5 (148x210mm);64,A5 Extra (174x235mm);78,A5 Rotated (210x148mm);'+;
        '61,A5 Transverse (148x210mm);70,A6 (105x148mm);83,A6 Rotated (148x105mm);42,B4 (ISO) (250x353mm);12,B4 (JIS) (250x354mm);'+;
        '79,B4 (JIS) Rotated (364x257mm);65,B5 (ISO) Extra (201x276mm);13,B5 (JIS) (182x257mm);80,B5 (JIS) Rotated (257x182mm);'+;
        '62,B5 (JIS) Transverse (182x257mm);88,B6 (JIS) (128x182mm);89,B6 (JIS) Rotated (182x128mm);24,C size sheet (17x22");'+;
        '25,D size sheet (22x34");82,Double Japanese Postcard Rotated (148x200mm);26,E size sheet (34x44");20,Envelope #10 (4 1/8x9½");'+;
        '21,Envelope #11 (4 ½x10 3/8");22,Envelope #12 (4¾x11");23,Envelope #14 (5x11");19,Envelope #9 (3 7/8x8 7/8");33,Envelope B4 (250x353mm);'+;
        '34,Envelope B5 (176x250mm);35,Envelope B6 (176x125mm);29,Envelope C3 (324x458mm);30,Envelope C4 (229x324mm);32,Envelope C5 (114x229mm);'+;
        '28,Envelope C5 (162x229mm);31,Envelope C6 (114x162mm);27,Envelope DL (110x220mm);47,Envelope Invite (220x220mm);36,Envelope Italy (110x230mm);'+;
        '37,Envelope Monarch (3 7/8x7½");38,Envelope Personal (3 5/8x6½");7,Executive (7¼x10½");14,Folio (8½x13");41,German Legal Fanfold (8½x13");'+;
        '40,German Std Fanfold (8½x12");69,Japanese Double Postcard (200x148mm);73,Japanese Envelope Chou #3 (120x235mm);'+;
        '86,Japanese Envelope Chou #3 Rotated (235x120mm);74,Japanese Envelope Chou #4 (90x205mm);87,Japanese Envelope Chou #4 Rotated (205x90mm);'+;
        '71,Japanese Envelope Kaku #2 (240x332mm);84,Japanese Envelope Kaku #2 Rotated (332x240mm);72,Japanese Envelope Kaku #3 (216x277mm);'+;
        '85,Japanese Envelope Kaku #3 Rotated (277x216mm);91,Japanese Envelope You #4 (105x235mm);92,Japanese Envelope You #4 Rotated (235x105mm);'+;
        '43,Japanese Postcard (100x148mm);81,Japanese Postcard Rotated (148x100mm);4,Ledger  (17x11");5,Legal (8½x14");51,Legal Extra (9.275x15");'+;
        '1,Letter (8½x11");50,Letter Extra (9.275x12");56,Letter Extra Transverse (9.275x12");59,Letter Plus (8.5x12.69");75,Letter Rotated (11x8½");'+;
        '2,Letter Small (8½x11");54,Letter Transverse (8.275x11");18,Note (8½x11");93,PRC 16K (146x215mm);106,PRC 16K Rotated (215x146mm);'+;
        '94,PRC 32K (97x151mm);107,PRC 32K Rotated (151x97mm);95,PRC 32K(Big) (97x151mm);108,PRC 32K(Big) Rotated (151x97mm);'+;
        '96,PRC Envelope #1 (102x165mm);109,PRC Envelope #1 Rotated (165x102mm);105,PRC Envelope #10 (324x458mm);118,PRC Envelope #10 Rotated (458x324mm);'+;
        '97,PRC Envelope #2 (102x176mm);110,PRC Envelope #2 Rotated (176x102mm);98,PRC Envelope #3 (125x176mm);111,PRC Envelope #3 Rotated (176x125mm);'+;
        '99,PRC Envelope #4 (110x208mm);112,PRC Envelope #4 Rotated (208x110mm);100,PRC Envelope #5 (110x220mm);113,PRC Envelope #5 Rotated (220x110mm);'+;
        '101,PRC Envelope #6 (120x230mm);114,PRC Envelope #6 Rotated (230x120mm);102,PRC Envelope #7 (160x230mm);115,PRC Envelope #7 Rotated (230x160mm);'+;
        '103,PRC Envelope #8 (120x309mm);116,PRC Envelope #8 Rotated (309x120mm);104,PRC Envelope #9 (229x324mm);117,PRC Envelope #9 Rotated (324x229mm);'+;
        '15,Quarto (215x275mm);45,Sheet (10x11");46,Sheet (15x11");44,Sheet (9x11");16,Sheet 10x14 (10x14");17,Sheet 11x17 (11x17");'+;
        '90,Sheet 12x11 (12x11");6,Statement (5½x8½");57,SuperA/SuperA/A4 (227x356mm);58,SuperB/SuperB/A3 (305x487mm);3,Tabloid (11x17");'+;
        '52,Tabloid Extra (11.69x18");39,US Std Fanfold (14 7/8x11")'

    LOCAL aLines := HB_ATOKENS( cPapInfo, ';' ),;
           c1Line := ''
     
    LOCAL aRVal := { {}, {} }

    FOR EACH c1Line IN aLines
       AADD( aRVal[ 1 ], VAL( LEFT( c1Line, AT( ",", c1Line ) - 1 ) ) )
       AADD( aRVal[ 2 ], SUBSTR( c1Line, AT( ",", c1Line ) + 1 ) )
    NEXT c1Line
   
RETURN aRVal // MakPapArrs()