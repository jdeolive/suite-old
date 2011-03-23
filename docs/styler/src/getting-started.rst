.. _styler.workflow:


Workflow
========

This section contains an quick overview of Styler and its workflow to get new users performing
common tasks quickly and easily.  

  .. note:: In order to use Styler, we recommend defining a unique SLD to the layer. To create a 
      unique SLD for a layer, see the GeoServer documentation for :guilabel:`Styling a Map`.

#.  You can access Styler one of two ways.  Either open up :guilabel:`Styler` in your
    browser or click a layer's :guilabel:`Styler` view from GeoServer's :guilabel:`
    Layer Preview` page.

    .. figure:: images/getting_started1.png
       :align: center
       
       *Selecting Styler from the Layer Preview page*

#.  :guilabel:`Styler` will load in your browser.

    .. figure:: images/getting_started2.png
       :align: center
       
       *View of Styler with a view of the medford:streets layer*

#.  You can show or hide layers by checking and un-checking the box next to the layer name.
    Any number of layers can be visible at one time. 
    
    .. figure:: images/getting_started3.png
       :align: center
       
       *Styler with multiple Medford layers active*
       
#.  The radio buttons are used to set the layer to be styled. Only a single layer can be
    styled at once. Click a radio button to set the layer to be styler.
    
    .. figure:: images/getting_started4.png
       :align: center
       
       *Selecting medford:streets for styling and viewing*
    
#.  To style a layer, click the style rule. 

    .. figure:: images/getting_started5.png
       :align: center
       
       *Opening the Style dialog*

#.  The resulting pop-up box provides easy :guilabel:`Basic`, :guilabel:`Label`, and
    :guilabel:`Advanced` styling.  See the :ref:`styler.styling` section for a more details 
    regarding these tabs. 
    
#.  To :guilabel:`Save` or :guilabel:`Cancel` your style rule, select the respective button, 
    on the bottom right corner of the style pop-up box. 
    
    .. figure:: images/getting_started6.png
       :align: center
       
       *Saving or canceling a style rule*
        
    .. warning:: Selecting :guilabel:`Save` will automatically overwrite the existing SLD for
       that layer, including any vendor options.

#.  To add or delete a style rule, select the :guilabel:`Add new` or :guilabel:`Delete Selected` 
    buttons on the bottom of the Layer Legend. 

    .. figure:: images/getting_started7.png
       :align: center
       
       *Adding or deleting a style rule*

    .. note:: Only one style rule can be deleted at a time.
    
#.  To review your revised style, return to the GeoServer :guilabel:`Style Editor`.  This can be 
    accessed by going to GeoServer and clicking on :guilabel:`Styles`, then selecting the style.  
  
  .. figure:: images/getting_started8.png
     :align: center
     
     *Viewing the Styler revised SLD in the GeoServer Style Editor*


