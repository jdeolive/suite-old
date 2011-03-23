.. _workflow.style:

Step 4: Style Your Layers
=========================

.. note:: This section is also optional, although recommended.  If you don't wish to edit any layer styles, you can skip to the next section, :ref:`workflow.create`.

When data was imported via the **Layer Importer** in GeoServer (see :ref:`workflow.import`), a unique style was generated for each layer.  To alter and improve the styling of your layers, use the **Styler** application.

These example instructions will change the color of one of the default styles created during the import process.

#. Launch Styler.  Styler can be launched from the :guilabel:`Style Layers` link in the :ref:`dashboard`.

   .. figure:: img/styler.png
      :align: center

      *Styler*

#. A list of all the loaded layers will be displayed in the :guilabel:`Layers` column.  Select the layer you would like to style by clicking the radio button next to the layer name.

   .. note:: Only one layer can be styled at a time, although you can show or hide other layers for context by checking the boxes next to the layers.

   .. figure:: img/styler_selectlayer.png
      :align: center

      *Selecting a layer for styling*

#. The :guilabel:`Legend` panel displays the style rules associated with that layer.  Click on a rule to view and edit it.   An editor window is launched.  

   .. figure:: img/styler_editstyle.png
      :align: center

      *The style edit window*

#. Change the style as you see fit, selecting from symbol, size, color, opacity, external graphics, filters, and many other options.

   .. note:: Please see the Styler Documentation for more about what can be styled using Styler. 

   .. figure:: img/styler_editstyleform.png
      :align: center

      *Style parameters changed*

#. Click :guilabel:`Save` to apply and view your change on the main map.

   .. warning:: There is no "undo" for changes made through Styler.

   .. figure:: img/styler_editstylefinished.png
      :align: center

      *The newly restyled layer*

#. Repeat this process for every layer that you wish to style.

For more information on Styler, please see the Styler Documentation. You can access this by clicking the :guilabel:`Styler Documentation` link in the :ref:`dashboard`.