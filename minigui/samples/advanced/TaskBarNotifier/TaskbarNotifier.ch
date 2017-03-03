/*
 TNS - TaskbarNotifier Status (TNS)
*/
#define UNDECLARED

#define TNS_HIDDEN       0
#define TNS_APPEARING    1
#define TNS_VISIBLE      2
#define TNS_DISAPPEARING 3


#xcommand INIT NOTIFIER <oPopup> <of: SKIN, FILE, BITMAP> <cBitmap> ;
            => ;
            <oPopup>:=TTaskbarNotifier():New(<"cBitmap">)

#xcommand KEEP VISIBLE <of: OF, NOTIFIER> <oPopup> ONMOUSEOVER <x:ON,OFF> ;
            => ;
            <oPopup>:KeepVisibleOnMouseOver(Upper(<(x)>) == "ON")

#xcommand KEEP VISIBLE <of: OF, NOTIFIER> <oPopup> ONMOUSEOVER ( <x> ) ;
            => ;
            <oPopup>:KeepVisibleOnMouseOver(<x>)

#xcommand RESHOW <of: OF, NOTIFIER> <oPopup> ONMOUSEOVER <x:ON,OFF> ;
            => ;
            <oPopup>:ReShowOnMouseOver(Upper(<(x)>) == "ON")

#xcommand RESHOW <of: OF, NOTIFIER> <oPopup> ONMOUSEOVER ( <x> ) ;
            => ;
            <oPopup>:ReShowOnMouseOver(<x>)

#xtranslate SET TITLE RECTANGE <of: OF, NOTIFIER> <oPopup> TO <r1>,<r2>,<r3>,<r4> ;
        =>;
            <oPopup>:TitleRect(<r1>,<r2>,<r3>,<r4>)

#xtranslate SET TITLE ONDBLCLICK [ ACTION <uAction> ] <of: OF, NOTIFIER> <oPopup> <x:ON,OFF> ;
        =>;
            <oPopup>:TitleOnClickEvent(Upper(<(x)>) == "ON", <{uAction}>)

#xtranslate SET TITLE ON DBLCLICK [ ACTION <uAction> ] <of: OF, NOTIFIER> <oPopup> <x:ON,OFF> ;
        =>;
            <oPopup>:TitleOnClickEvent(Upper(<(x)>) == "ON", <{uAction}>)

#xtranslate SET TITLE NORMAL COLOR <aColor> <of: OF, NOTIFIER> <oPopup> ;
        =>;
            <oPopup>:TitleNormalColor(<aColor>)

#xtranslate SET TITLE HOVER COLOR <aColor> <of: OF, NOTIFIER> <oPopup> ;
        =>;
            <oPopup>:TitleHoverColor(<aColor>)

#xtranslate SET CONTENT RECTANGE <of: OF, NOTIFIER> <oPopup> TO <r1>,<r2>,<r3>,<r4> ;
        =>;
            <oPopup>:ContentRect(<r1>,<r2>,<r3>,<r4>)

#xtranslate SET CONTENT ONDBLCLICK [ ACTION <uAction> ] <of: OF, NOTIFIER> <oPopup> <x:ON,OFF> ;
        =>;
            <oPopup>:ContentOnClickEvent(Upper(<(x)>) == "ON", <{uAction}>)

#xtranslate SET CONTENT ON DBLCLICK [ ACTION <uAction> ] <of: OF, NOTIFIER> <oPopup> <x:ON,OFF> ;
        =>;
            <oPopup>:ContentOnClickEvent(Upper(<(x)>) == "ON", <{uAction}>)

#xtranslate SET CONTENT NORMAL COLOR <aColor> <of: OF, NOTIFIER> <oPopup> ;
        =>;
            <oPopup>:ContentNormalColor(<aColor>)

#xtranslate SET CONTENT HOVER COLOR <aColor> <of: OF, NOTIFIER> <oPopup> ;
        =>;
            <oPopup>:ContentHoverColor(<aColor>)

#xcommand SHOW NOTIFIER <oPopup> [ TITLE <cTitle> ] CONTENT <cContent> ;
          DELAYS SHOWING <nTime1> STAYING <nTime2> HIDING <nTime3> ;
        => ;
            <oPopup>:Show(<cTitle>,<cContent>,<nTime1>,<nTime2>,<nTime3>)
