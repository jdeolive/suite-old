<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0"
    xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <NamedLayer>
    <Name>Simple point</Name>
    <UserStyle>
      <Title>GeoServer SLD Cook Book: Simple point</Title>
      <FeatureTypeStyle>
        <Rule>
	  <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#eaeab5</CssParameter>
            </Fill>
	  </PolygonSymbolizer>
        </Rule>
       <TextSymbolizer>
         <Label>
           <ogc:PropertyName>NAME</ogc:PropertyName>
         </Label>
         <Font>
           <CssParameter name="font-family">SansSerif</CssParameter>
           <CssParameter name="font-family">Arial</CssParameter>
           <CssParameter name="font-size">12</CssParameter>
           <CssParameter name="font-style">normal</CssParameter>
           <CssParameter name="font-weight">bold</CssParameter>
         </Font>
         <LabelPlacement/>
         <Fill>
           <CssParameter name="fill">#000000</CssParameter>
         </Fill>
       </TextSymbolizer>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
