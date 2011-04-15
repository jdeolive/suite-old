.. _installation.linux.suite:

Installing the OpenGeo Suite for Linux
======================================

This document describes how to install the OpenGeo Suite for Linux.  There are two editions of the OpenGeo Suite for Linux: Community Edition and Enterprise Edition.  The instructions differ depending on which version you have.  Each Edition is available for RPM-based systems and Debain (APT)-based systems.  Please see the section appropriate for your software.

The OpenGeo Suite has the following system requirements:

* Operating System: Ubuntu 10.04 and 10.10, CentOS 5
* Memory: 512MB minimum (1GB recommended)
* Disk space: 500MB minimum (plus extra space for any loaded data)
* Browser: Any modern web browser is supported (Internet Explorer 6+, Firefox 3+, Chrome 2+, Safari 3+)
* Permissions: Super user privileges are required for installation












.. _installation.linux.suite.community:

OpenGeo Suite Community Edition
-------------------------------

Packages for the OpenGeo Suite Community Edition are currently available in both :ref:`RPM <installation.linux.suite.community.rpm>` (CentOS/Red Hat/Fedora) and :ref:`APT <installation.linux.suite.community.apt>` (Ubuntu/Debian) formats. 

.. note:: The commands contained in the following installation instructions must be run as a user with root privileges, or prefixed with ``sudo``. 

.. _installation.linux.suite.community.rpm:

RPM Installation
~~~~~~~~~~~~~~~~

.. note:: If you are upgrading from a previous version, jump to the section entitled :ref:`installation.linux.suite.community.rpm_upgrade`.

.. warning:: The RPM packages are only compatible with CentOS 5 and above.

#. Begin by adding the OpenGeo YUM repository:

   For 32 bit systems:

   .. code-block:: bash

      cd /etc/yum.repos.d
      wget http://yum.opengeo.org/centos/5/i386/OpenGeo.repo

   For 64 bit systems:

   .. code-block:: bash

      cd /etc/yum.repos.d
      wget http://yum.opengeo.org/centos/5/x86_64/OpenGeo.repo

#. Update YUM:

   .. code-block:: bash

      yum update

#. Install the OpenGeo Suite package (``opengeo-suite``):

   .. code-block:: bash

      yum install opengeo-suite

#. If the previous command returns an error, the OpenGeo repository may not have been added properly. Examine the output of the ``yum`` command for any errors or warnings.

#. You can launch the OpenGeo Suite Dashboard (and verify the installation was successful) by navigating to the following URL::

      http://localhost:8080/dashboard/

Continue reading at the :ref:`installation.linux.suite.afterinstall` section.
 
.. _installation.linux.suite.community.rpm_upgrade:

RPM Upgrade
~~~~~~~~~~~

.. warning:: If upgrading from before 2.4.2, the "medford" PostGIS database will be deleted and recreated on upgrade. So if you have any data in that database that you would like to keep, please back it up prior to upgrading (using pg_dump is recommended).

#. Begin by updating YUM:

   .. code-block:: bash

      yum update

#. The relevant OpenGeo packages should be included in the upgrade list. If you do not wish to do a full update, cancel the upgrade and install the ``opengeo-suite`` package manually:

   .. code-block:: bash

      yum install opengeo-suite


.. _installation.linux.suite.community.apt:

APT Installation
~~~~~~~~~~~~~~~~

.. note:: If you are upgrading from a previous version, jump to the section entitled :ref:`installation.linux.suite.community.apt_upgrade`.

.. warning:: The APT packages are only available for Ubuntu 10.04 and above.

#. Begin by importing the OpenGeo GPG key:

   .. code-block:: bash

      wget -qO- http://apt.opengeo.org/gpg.key | apt-key add -

#. Add the OpenGeo APT repository:

   .. code-block:: bash

      echo "deb http://apt.opengeo.org/ubuntu lucid main" >> /etc/apt/sources.list
      
#. Update APT:

   .. code-block:: bash

      apt-get update

#. Install the OpenGeo Suite package (``opengeo-suite``):

   .. code-block:: bash

      apt-get install opengeo-suite

#. If the previous command returns an error, the OpenGeo repository may not have been added properly. Examine the output of the ``yum`` command for any errors or warnings.

#. You can launch the OpenGeo Suite Dashboard (and verify the installation was successful) by navigating to the following URL::

      http://localhost:8080/dashboard/

Continue reading at the :ref:`installation.linux.suite.afterinstall` section.

.. _installation.linux.suite.community.apt_upgrade:

APT Upgrade
~~~~~~~~~~~

#. Begin by updating APT:

   .. code-block:: bash

      apt-get update

#. Update the ``opengeo-suite`` package:

   .. code-block:: bash

      apt-get install opengeo-suite

Continue reading at the :ref:`installation.linux.suite.afterinstall` section.


















.. _installation.linux.suite.enterprise:

OpenGeo Sutie Enterprise Edition
-------------------------------- 

Packages for the OpenGeo Suite Enterprise Edition are currently available in both :ref:`RPM <installation.linux.suite.enterprise.rpm>` (CentOS/Red Hat/Fedora) and :ref:`APT <installation.linux.suite.enterprise.apt>` (Ubuntu/Debian) formats. 

.. note:: The commands contained in the following installation instructions must be run as a user with root privileges, or prefixed with ``sudo``. 

.. _installation.linux.suite.enterprise.rpm:

RPM Installation
~~~~~~~~~~~~~~~~

.. note:: If you are upgrading from a previous version, jump to the section entitled :ref:`installation.linux.suite.enterprise.rpm_upgrade`.

.. warning:: The RPM packages are only compatible with CentOS 5 and above.

#. Begin by adding the OpenGeo YUM repository:

   For 32 bit systems:

   .. code-block:: bash

      cd /etc/yum.repos.d
      wget http://yum.opengeo.org/centos/5/i386/OpenGeo.repo

   For 64 bit systems:

   .. code-block:: bash

      cd /etc/yum.repos.d
      wget http://yum.opengeo.org/centos/5/x86_64/OpenGeo.repo

#. Now add the OpenGeo Enterprise YUM repository.  This repository is password protected.  You will have received a username and password when you registered for the Enterprise Edition.  Add the following YUM repository using the commands below, making sure to substitute in your username for ``<username>`` and password for ``<password>``.

   For 32 bit systems:

   .. code-block:: bash

      cd /etc/yum.repos.d
      wget --user='<username>' --password='<password>' http://yum-ee.opengeo.org/centos/5/i386/OpenGeoEE.repo

   For 64 bit systems:

   .. code-block:: bash

      cd /etc/yum.repos.d
      wget --user='<username>' --password='<password>' http://yum-ee.opengeo.org/centos/5/x86_64/OpenGeoEE.repo

#. Edit the OpenGeoEE.repo file filling in your username and password.

#. Update YUM:

   .. code-block:: bash

      yum update

#. Install the ``opengeo-suite-ee`` package:

   .. code-block:: bash

      yum install opengeo-suite-ee

#. If the previous command returns an error, the OpenGeo repositories may not have been added properly. Examine the output of the ``yum`` command for any errors or warnings.

#. You can launch the OpenGeo Suite Dashboard (and verify the installation was successful) by navigating to the following URL::

      http://localhost:8080/dashboard/

Continue reading at the :ref:`installation.linux.suite.afterinstall` section.
 
.. _installation.linux.suite.enterprise.rpm_upgrade:

RPM Upgrade
~~~~~~~~~~~

.. warning:: If upgrading from before 2.4.2, the "medford" PostGIS database will be deleted and recreated on upgrade. So if you have any data in that database that you would like to keep, please back it up prior to upgrading (using pg_dump is recommended).

#. Begin by updating YUM:

   .. code-block:: bash

      yum update

#. The relevant OpenGeo packages should be included in the upgrade list. If you do not wish to do a full update, cancel the upgrade and install the ``opengeo-suite`` package manually:

   .. code-block:: bash

      yum install opengeo-suite-ee


.. _installation.linux.suite.enterprise.apt:

APT Installation
~~~~~~~~~~~~~~~~

.. note:: If you are upgrading from a previous version, jump to the section entitled :ref:`installation.linux.suite.enterprise.apt_upgrade`.

.. warning:: The APT packages are only available for Ubuntu 10.04 and above.

#. Begin by importing the OpenGeo GPG key:

   .. code-block:: bash

      wget -qO- http://apt.opengeo.org/gpg.key | apt-key add -

#. Add the OpenGeo APT repository:

   .. code-block:: bash

      echo "deb http://apt.opengeo.org/ubuntu lucid main" >> /etc/apt/sources.list

#. Now add the OpenGeo Enterprise APT repository.  This repository is password protected.  You will have received a username and password when you registered for the Enterprise Edition.  Add the following APT repository using the command below, making sure to substitute in your username for ``<username>`` and password for ``<password>``.

   .. code-block:: bash

      echo "deb http://<username>:<password>@apt-ee.opengeo.org/ubuntu lucid main" >> /etc/apt/sources.list

#. Update APT:

   .. code-block:: bash

      apt-get update

#. Install the OpenGeo Suite package (``opengeo-suite-ee``):

   .. code-block:: bash

      apt-get install opengeo-suite-ee

#. If the previous command returns an error, the OpenGeo repository may not have been added properly. Examine the output of the ``yum`` command for any errors or warnings.

#. You can launch the OpenGeo Suite Dashboard (and verify the installation was successful) by navigating to the following URL::

      http://localhost:8080/dashboard/

Continue reading at the :ref:`installation.linux.suite.afterinstall` section.

.. _installation.linux.suite.enterprise.apt_upgrade:

APT Upgrade
~~~~~~~~~~~

#. Begin by updating APT:

   .. code-block:: bash

      apt-get update

#. Update the ``opengeo-suite-ee`` package:

   .. code-block:: bash

      apt-get install opengeo-suite-ee

Continue reading at the :ref:`installation.linux.suite.afterinstall` section.





















.. _installation.linux.suite.afterinstall:

After installation
------------------

List of packages
~~~~~~~~~~~~~~~~

Once installed, you will have the following packages installed on your system:

.. list-table::
   :widths: 20 20 60 
   :header-rows: 1

   * - Package
     - Name
     - Description
   * - opengeo-suite
     - OpenGeo Suite
     - The full OpenGeo Suite and all its contents.  All packages listed below are installed as dependencies with this package.  Contains GeoExplorer, Styler, GeoEditor, Dashboard, Recipe Book, and more.
   * - opengeo-docs
     - OpenGeo Suite Documentation
     - Full documentation for the OpenGeo Suite.
   * - opengeo-geoserver
     - GeoServer
     - High performance, standards-compliant map and geospatial data server.
   * - opengeo-jai
     - Java Advanced Imaging (JAI)
     - Set of Java toolkits to provide enhanced image rendering abilities.
   * - opengeo-postgis
     - PostGIS
     - Robust, spatially-enabled object-relational database built on PostgreSQL.
   * - opengeo-suite-data
     - OpenGeo Suite Data
     - Sample data for use with the OpenGeo Suite.
   * - pgadmin3
     - pgAdmin III
     - Graphical client for interacting with PostgreSQL/PostGIS.
   * - opengeo-suite-ee (Enterprise Edition only)
     - OpenGeo Suite Enterprise Edition package
     - Enterprise Edition functions and libraries.  


Starting/Stopping the OpenGeo Suite
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

GeoServer, GeoExplorer, and all other web-based containers including the documentation are installed into the existing Tomcat instance on the machine. Starting and stopping these applications are therefore accomplished by managing them through the standard Tomcat instance.  Tomcat is installed as a service under the name of :command:`tomcat5`, and can be managed accordingly:

.. code-block:: bash

   /etc/init.d/tomcat5 start
   /etc/init.d/tomcat5 stop

PostGIS is also installed as a service, under the name of :command:`postgresql`, and can be managed in the same way as Tomcat:

.. code-block:: bash

   /etc/init.d/postgresql start
   /etc/init.d/postgresql stop

Both services are started and set to run automatically when the OpenGeo Suite is installed.


Accessing web applications
~~~~~~~~~~~~~~~~~~~~~~~~~~

The easiest way to launch the web-based applications contained in the OpenGeo Suite is via the Dashboard.  All web applications are linked from this application.  The Dashboard is accessible via the following URL::

  http://localhost:8080/dashboard/

.. note:: You will need to change the port number if your Tomcat installation is serving on a different port.

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - Application
     - URL
   * - OpenGeo Suite Dashboard
     - http://localhost:8080/dashboard/
   * - GeoServer
     - http://localhost:8080/geoserver/
   * - OpenGeo Suite Documentation
     - http://localhost:8080/docs/
   * - GeoExplorer
     - http://localhost:8080/geoexplorer/
   * - Styler
     - http://localhost:8080/styler/
   * - GeoEditor
     - http://localhost:8080/geoeditor/
   * - OpenGeo Recipe Book
     - http://localhost:8080/recipes/

Accessing PostGIS
~~~~~~~~~~~~~~~~~

You can access PostGIS in one of two ways:  via the command line will the :command:`psql` application, or via a graphical interface with the :command:`pgadmin3` application.  Both commands should be on the path and can be invoked from any Terminal window.  If unfamiliar with PostGIS, start with :command:`pgadmin3`.  

This version of PostGIS is running on port 5432, with administrator username and password **opengeo** / **opengeo**.





