/*
 * (c) Siri Rathinagiri, 2016 ( Adaptation for Draw in Bitmap )
 */

#xtranslate GRAPH BITMAP PIE ;
               SIZE        <nWidth>, <nHeight> ;
               SERIEVALUES <aSerieValues> ;
               SERIENAMES  <aSerieNames> ;
               SERIECOLORS <aSerieColors> ;
               PICTURE     <cPicture> ;
               TITLE       <cTitle> ;
               [ TITLECOLOR  <aTitleColor> ] ;
               DEPTH       <nDepth> ;
               3DVIEW      <l3DView> ;
               SHOWXVALUES <lShowXValues> ; 
               SHOWLEGENDS <lShowLegends> ; 
               [ <placement:RIGHT,BOTTOM> ] ;
               [ NOBORDER    <lNoBorder> ] ;
               STOREIN     <hBitmapVar> ;
   => ;
<hBitmapVar> := HMG_PieGraph( <nWidth>, <nHeight>, <aSerieValues>, <aSerieNames>, <aSerieColors>, <cTitle>, <aTitleColor>,;
                              <nDepth>, <l3DView>, <lShowXValues>, <lShowLegends>, <.lNoBorder.>, <cPicture>, <"placement"> )


#xtranslate GRAPH BITMAP <nGraphType> ; // constants BARS | LINES | POINTS
               SIZE        <nWidth>, <nHeight> ;
               SERIEVALUES <aSerieValues> ;
               SERIENAMES  <aSerieNames> ;
               SERIECOLORS <aSerieColors> ;
               SERIEYNAMES <aSerieYNames> ;
               PICTURE     <cPicture> ;
               TITLE       <cTitle> ;
               [ TITLECOLOR  <aTitleColor> ] ;
               HVALUES     <nHValues> ;
               BARDEPTH    <nBarDepth> ; 
               BARWIDTH    <nBarWidth> ;
               [ SEPARATION  <nSeparation> ] ;
               [ LEGENDWIDTH <nLegendWindth> ] ;
               [ 3DVIEW      <l3DView> ] ;
               SHOWGRID    <lShowGrid> ;
               [ SHOWXGRID   <lShowXGrid> ] ;
               [ SHOWYGRID   <lShowYGrid> ] ;
               SHOWVALUES  <lShowValues> ;
               SHOWXVALUES <lShowXValues> ;
               SHOWYVALUES <lShowYValues> ;
               SHOWLEGENDS <lShowLegends> ;
               [ NOBORDER    <lNoBorder> ] ;
               STOREIN     <hBitmapVar> ;
   => ;
<hBitmapVar> := HMG_Graph( <nWidth>, <nHeight>, <aSerieValues>, <cTitle>, <aSerieYNames>, <nBarDepth>, <nBarWidth>, <nSeparation>,;
                           <aTitleColor>, <nHValues>, <l3DView>, <lShowGrid>, <.lShowXGrid.>, <.lShowYGrid.>, <lShowXValues>,;
                           <lShowYValues>, <lShowLegends>, <aSerieNames>, <aSerieColors>, <nGraphType>, <lShowValues>,;
                           <cPicture>, <nLegendWindth> , <.lNoBorder.> )
