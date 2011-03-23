Installing the OpenGeo Suite for Mac OS X
=========================================

This document will discuss how to install the OpenGeo Suite for Mac OS X.


Prerequisites
-------------

The OpenGeo Suite has the following system requirements:

* **Operating System**: 10.5 Leopard, 10.6 Snow Leopard
* **Memory**: 1GB minimum (higher recommended)
* **Disk space**: 600MB minimum (plus extra space for any loaded data)
* **Browser**: Any modern web browser is supported (Internet Explorer 6+, Firefox 3+, Chrome 2+, Safari 3+)
* **Permissions**: Administrative rights

Installation
------------

#. Double click to mount the :file:`OpenGeoSuite.dmg` file.  Inside the mounted image, double click on :file:`OpenGeo Suite.mpkg`

#. At the **Welcome** screen, click :guilabel:`Continue`.

    .. figure:: img/welcome.png
       :align: center

       *Welcome screen*

#. Read the **License Agreement**. To agree to the license, click :guilabel:`Continue` and then :guilabel:`Agree`.

      .. figure:: img/license.png
         :align: center

         *License Agreement*

#. To install the OpenGeo Suite on your hard drive click :guilabel:`Next`.  You will be prompted for your administrator password.  

    .. figure:: img/directory.png
       :align: center

       *Destination selection*

#. When ready to install, click :guilabel:`Install`.

    .. figure:: img/ready.png
       :align: center

       *Ready to Install*

#. Please wait while the installation proceeds.

    .. figure:: img/install.png
       :align: center

       *Installation*
      
#. You will receive confirmation that the installation was successful.  

    .. figure:: img/success.png
       :align: center

       *The OpenGeo Suite successfully installed*

After installation, the OpenGeo Dashboard will automatically start, allowing you to manage and launch the OpenGeo Suite.

For more information, please see the document titled **Getting Started**, which is available from the Dashboard.

.. note:: The OpenGeo Suite must be online in order to view documentation from the Dashboard.  If you would like to view the documentation when the Suite is offline, please paste the following link into your browser:

   .. code-block:: bash

      file:///opt/opengeo/suite/webapps/docs/gettingstarted/index.html

Upgrade
-------

You can upgrade from a previous version of the OpenGeo Suite, and your settings and data will be preserved.  To do this, follow the regular installation procedure, and if a previous version is detected, the software will be automatically upgraded.
 
Uninstallation
--------------

.. warning:: All data and settings will be deleted during the uninstallation process.  If you wish to retain your data nd settings, please make a backup of the directory :file:`~/.opengeo` before proceeding.

.. note:: Please make sure that the Dashboard is closed and the OpenGeo Suite is offline before starting the uninstallation.
  
To run the uninstaller, navigate to :menuselection:`Applications --> OpenGeo --> OpenGeo Suite Uninstaller`.  You can also uninstall the OpenGeo Suite from the Terminal by typing the following:

  .. code-block:: bash
       
     sudo sh /opt/opengeo/suite/suite-uninstall.sh

For More Information
--------------------

Please visit http://opengeo.org or see the documentation included with this software.
