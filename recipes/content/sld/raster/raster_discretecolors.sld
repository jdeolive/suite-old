<StyledLayerDescriptor version="1.0.0" xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd" xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> 
  <NamedLayer> 
    <Name>cookbook:sld_cookbook_raster</Name>
    <UserStyle> 
      <Title>SLD Cook Book: Raster Discrete colors</Title> 
      <FeatureTypeStyle>
         <Rule>
           <RasterSymbolizer>
             <ColorMap type="intervals">
               <ColorMapEntry color="#008000" quantity="150" />
               <ColorMapEntry color="#663333" quantity="256" />
             </ColorMap>
           </RasterSymbolizer>
         </Rule>
       </FeatureTypeStyle>
    </UserStyle> 
  </NamedLayer> 
</StyledLayerDescriptor>