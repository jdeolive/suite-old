Installing the OpenGeo Suite for Windows
========================================

This document will discuss how to install the OpenGeo Suite for Windows.

Prerequisites
-------------

The OpenGeo Suite has the following system requirements:

* **Operating System**: Windows XP, Windows Vista, Windows 7 (each 32 and 64 bit)
* **Memory**: 512MB minimum (1GB recommended)
* **Disk space**: 600MB minimum (plus extra space for any loaded data)
* **Browser**: Any modern web browser is supported (Internet Explorer 6+, Firefox 3+, Chrome 2+, Safari 3+)
* **Permissions**: Administrative rights

Installation
------------

#. Double click on the :file:`OpenGeoSuite.exe` file.

#. At the **Welcome** screen, click :guilabel:`Next`.

   .. figure:: img/welcome.png
      :align: center

      *Welcome screen*

#. Read the **License Agreement** then click :guilabel:`I Agree`.

   .. figure:: img/license.png
      :align: center

      *License Agreement*

#. Select the **Destination folder** where you would like to install the OpenGeo Suite, and click :guilabel:`Next`.

   .. figure:: img/directory.png
      :align: center

      *Destination folder for the installation*

#. Select the name and location of the **Start Menu folder** to be created, and click :guilabel:`Next`.

   .. figure:: img/startmenu.png
      :align: center

      *Start Menu folder to be created*

#. Select the components you wish to install, and click :guilabel:`Next`.

   .. figure:: img/components.png
      :align: center

      *Component selection*

   .. note::  All components will be installed by default except for optional ArcSDE and Oracle Spatial extensions.  If enabling these extensions, certain additional files will need to be manually copied to the installation directory.  For the ArcSDE extension, the files :file:`jsde*.jar` and :file:`jpe*.jar` are required.  For Oracle, the file :file:`ojdbc*.jar` is required.  These file(s) must be copied to the following path :file:`<installation_folder>\\webapps\\geoserver\\WEB-INF\\lib`.  

#. Click :guilabel:`Install` to perform the installation.

   .. figure:: img/ready.png
      :align: center

      *Ready to install*

#. Please wait while the installation proceeds.

   .. figure:: img/install.png
      :align: center

      *Installation*

#. After installation, click :guilabel:`Finish` to launch the OpenGeo Suite Dashboard, from which you can start the OpenGeo Suite.  If you would like to start the OpenGeo Suite Dashboard at a later time, uncheck the box and then click :guilabel:`Finish`.

   .. figure:: img/finish.png
      :align: center

      *The OpenGeo Suite successfully installed*

For more information, please see the document titled **Getting Started**, which is available through the Dashboard, or in the Start Menu at :menuselection:`Start Menu --> Programs --> OpenGeo Suite --> Documentation --> Getting Started`.

.. note:: The OpenGeo Suite must be online in order to view documentation from the Dashboard.  If you would like to view the documentation when the Suite is offline, please use the shortcuts in the Start Menu.

Upgrade
-------

You can upgrade from a previous version of the OpenGeo Suite, and your settings and data will be preserved.  To do this, follow the regular installation procedure, and if a previous version is detected, a notice will display saying so.

   .. figure:: img/upgrade.png
      :align: center

      *Upgrading from a previous version*

Uninstallation
--------------

.. note:: Please make sure that the Dashboard is closed and the OpenGeo Suite is offline before starting the uninstallation.

#. Navigate to :menuselection:`Start Menu --> Programs --> OpenGeo Suite --> Uninstall`

   .. note:: Uninstallation is also available via the standard Windows program removal workflow.  (**Add/Remove Programs** for Windows XP, **Installed Programs** for Windows Vista, etc.)

#. Click :guilabel:`Uninstall` to start the uninstallation process.

   .. figure:: img/uninstall.png
      :align: center

      *Ready to uninstall the OpenGeo Suite*

   .. note:: Uninstalling will not delete your settings and data.  Should you wish to delete this, you will need to do this manually.  The uninstallation process will display the location of your settings directory, typically :file:`<user_home_directory>\\.opengeo`.

#. When done, click :guilabel:`Close`.

   .. figure:: img/unfinish.png
      :align: center

      *The OpenGeo Suite is successfully uninstalled*


For More Information
--------------------

Please visit http://opengeo.org or see the documentation included with this software.