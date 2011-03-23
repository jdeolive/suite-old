.. _installation.linux.geoserver-centos:

Installing GeoServer on CentOS
==============================

The easiest way to install and set up GeoServer is by :ref:`installing the full OpenGeo Suite <installation.linux.suite>`.  The OpenGeo Suite comes complete with GeoServer as well as a full geospatial software stack, including utilities, data, and documentation.  That said, OpenGeo also provides individual packages for installing the components separately.

This page will describe how to install GeoServer on CentOS 5.  Earlier versions of CentOS are not supported at this time.

Access the OpenGeo RPM repository
---------------------------------

OpenGeo provides a repository for packages in RPM format.  To access this repository, you need to first add the OpenGeo Yum repository to your local list of repositories:  These commands differ depending on whether your system is 32 or 64 bit.

.. note:: You will need to run these commands on an account with root access.

For 32 bit systems:

.. code-block:: bash

   cd /etc/yum.repos.d
   wget http://yum.opengeo.org/centos/5/i386/OpenGeo.repo

For 64 bit systems:

.. code-block:: bash

   cd /etc/yum.repos.d
   wget http://yum.opengeo.org/centos/5/x86_64/OpenGeo.repo


Package management
------------------

 Search for packages from OpenGeo:

.. code-block:: bash

   yum search opengeo

If the search command does not return any results, the repository was not added properly. Examine the output of the ``yum`` command for any errors or warnings.

Now you can install GeoServer.  The name of the package is :guilabel:`opengeo-geoserver`:

.. code-block:: bash

   yum install opengeo-geoserver


After installation
------------------

When completed, GeoServer will be installed as a servlet inside the local version of Tomcat.  Assuming that Tomcat is running on the default port 8080, you can verify that GeoServer is installed by navigating to the following URL::

   http://localhost:8080/geoserver/

This will load the Web Administration Interface.  Most management of GeoServer functionality can be done from this interface.

.. note:: The username and password for the GeoServer administrator account is **admin** / **geoserver**

For more information about running GeoServer, please see the `GeoServer Documentation <http://suite.opengeo.org/docs/geoserver/>`_
