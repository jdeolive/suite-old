<StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>cookbook:sld_cookbook_polygon</Name>
    <UserStyle>
      <Title>SLD Cook Book: Simple Polygon</Title>
      <FeatureTypeStyle>
         <Rule>
           <PolygonSymbolizer>
             <Fill>
               <CssParameter name="fill">#000080</CssParameter>
             </Fill>
           </PolygonSymbolizer>
         </Rule>
       </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
