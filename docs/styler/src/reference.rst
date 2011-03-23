.. _styler.reference:

Reference
=========

.. |full| image:: images/tick.png
.. |passive| image:: images/error.png
.. |none| image:: images/cross.png

Styler provides a graphical interface for viewing styling information according to the `SLD 1.0 specification <http://www.opengeospatial.org/standards/sld>`_, along with the `OGC Filter spec <http://www.opengeospatial.org/standards/filter>`_.  Styler does not provide 100% feature parity with these specifications.  This section will detail the current functionality of Styler.

Functionality in Styler generally falls into one of three categories:

#. **Full support** |full| : The feature is implemented and rendered according to the specification.  Styler can read the functionality from an existing SLD, display the content properly in the graphical interface, and successfully save any changes made.
#. **Passive support** |passive| : The feature is implemented and rendered according to the specification.  Styler can read and persist the functionality from an existing SLD, but does not allow for editing.
#. **No support** |none| : The feature is not recognized, although it may be rendered initially. After any editing with Styler, the feature will be stripped from the SLD.


Metadata
--------

.. list-table::
   :header-rows: 1
   :widths: 35 25 40

   * - Tag
     - Support
     - Notes
   * - Rule/Name
     - |passive|
     -
   * - Rule/Title
     - |full|
     -
   * - Rule/Abstract
     - |passive|
     -
   * - FeatureTypeStyle/Name
     - |passive|
     -
   * - FeatureTypeStyle/Title
     - |passive|
     -
   * - FeatureTypeStyle/Abstract
     - |passive|
     -


PointSymbolizer
---------------

.. list-table::
   :header-rows: 1
   :widths: 35 25 40

   * - Tag
     - Support
     - Notes
   * - Geometry
     - |none|
     -
   * - Fill
     - |full|
     - 
   * - Fill/GraphicFill
     - |none|
     -
   * - Stroke
     - |full|
     - 
   * - Stroke/GraphicFill
     - |none|
     - 
   * - Stroke/GraphicStroke
     - |none|
     - 
   * - ExternalGraphic
     - |full|
     - Image preview will not display if a relative URL is used
   * - Format
     - |full|
     - Will only display browser-friendly image formats
   * - Size
     - |full|
     - 
   * - Rotation
     - |full|
     -
   * - Mark
     - |full|
     - Marks supported: square, circle, triangle, star, cross, x.  Hatching not supported.
   * - Opacity
     - |passive|
     - 


LineSymbolizer
--------------

.. list-table::
   :header-rows: 1
   :widths: 35 25 40

   * - Tag
     - Support
     - Notes
   * - Geometry
     - |none|
     -
   * - Stroke
     - |full|
     - 
   * - Stroke/GraphicFill
     - |none|
     - 
   * - Stroke/GraphicStroke
     - |none|
     - 

PolygonSymbolizer
-----------------

.. list-table::
   :header-rows: 1
   :widths: 35 25 40

   * - Tag
     - Support
     - Notes
   * - Geometry
     - |none|
     -
   * - Fill
     - |full|
     - 
   * - Fill/GraphicFill
     - |none|
     -
   * - Stroke
     - |full|
     - 
   * - Stroke/GraphicFill
     - |none|
     - 
   * - Stroke/GraphicStroke
     - |none|
     - 

TextSymbolizer
--------------

.. list-table::
   :header-rows: 1
   :widths: 35 25 40

   * - Tag
     - Support
     - Notes
   * - Geometry
     - |none|
     -
   * - Label
     - |full|
     - Support only for PropertyName
   * - font-family 
     - |full|
     -
   * - font-style
     - |full|
     - Passive support only for oblique
   * - font-weight
     - |full|
     -
   * - font-size
     - |full|
     -
   * - LabelPlacement
     - |none|
     - 
   * - PointPlacement
     - |none|
     - 
   * - LinePlacement
     - |none|
     - 
   * - Displacement
     - |none|
     - 
   * - AnchorPoint
     - |none|
     - 
   * - Halo
     - |full|
     -
   * - Fill
     - |full|
     -


RasterSymbolizer
----------------

Raster layers do not load or display in Styler, so it is not possible to edit the styles associated with those layers.

CssParameters
-------------

.. list-table::
   :header-rows: 1
   :widths: 35 25 40

   * - Parameter
     - Support
     - Notes
   * - stroke
     - |full|
     -
   * - stroke-opacity
     - |full|
     -
   * - stroke-width
     - |full|
     -
   * - stroke-linejoin
     - |none|
     -
   * - stroke-linecap
     - |passive|
     - 
   * - stroke-dasharray
     - (see notes)
     - Full support for three presets: solid, dash, dot.  Passive support for all others
   * - stroke-dashoffset
     - |none|
     -
   * - fill
     - |full|
     -
   * - fill-opacity
     - |full|
     -

Filters / Expressions
---------------------

.. list-table::
   :header-rows: 1
   :widths: 35 25 40

   * - Tag
     - Support
     - Notes
   * - PropertyName
     - |full|
     -
   * - Literal
     - |full|
     - String or constant only
   * - Add
     - |none|
     -
   * - Sub
     - |none|
     -
   * - Mult
     - |none|
     -
   * - Div
     - |none|
     -
   * - Function
     - |none|
     -

Miscellaneous
-------------

.. list-table::
   :header-rows: 1
   :widths: 35 25 40

   * - Tag
     - Support
     - Notes
   * - MaxScaleDenominator
     - |full|
     -
   * - MinScaleDenominator
     - |full|
     -
   * - VendorOption
     - |passive|
     -
   * - Priority
     - |passive|
     -
