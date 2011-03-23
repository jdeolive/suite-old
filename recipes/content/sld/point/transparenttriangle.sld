<StyledLayerDescriptor version="1.0.0" xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.0.0/StyledLayerDescriptor.xsd">
  <NamedLayer>
    <Name>cookbook:sld_cookbook_point</Name>
    <UserStyle>
      <Title>SLD Cook Book: Transparent Triangle</Title>
      <FeatureTypeStyle>
           <Rule>
             <PointSymbolizer>
               <Graphic>
                 <Mark>
                   <WellKnownName>triangle</WellKnownName>
                   <Fill>
                     <CssParameter name="fill">#009900</CssParameter>
                     <CssParameter name="fill-opacity">0.2</CssParameter>
                   </Fill>
                   <Stroke>
                     <CssParameter name="stroke-color">#000000</CssParameter>
                     <CssParameter name="stroke-width">2</CssParameter>                     
                   </Stroke>
                 </Mark>
                 <Size>12</Size>
               </Graphic>
             </PointSymbolizer>
           </Rule>
         </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
