.. _installation.linux.postgis-centos:

Installing PostGIS on CentOS
============================

The easiest way to install and set up PostGIS is by :ref:`installing the full OpenGeo Suite <installation.linux.suite>`.  The OpenGeo Suite comes complete with GeoServer as well as a full geospatial software stack, including utilities, data, and documentation.  That said, OpenGeo also provides individual packages for installing the components separately.

This page will describe how to install PostGIS on CentOS 5.  Earlier versions of Ubuntu are not supported at this time.

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

Now you can install PostGIS.  The name of the package is :guilabel:`opengeo-postgis`:

.. code-block:: bash

   yum install opengeo-postgis

After installation
------------------

When completed, PostGIS will be installed on your system as a service, running on port **5432**.  

.. note:: The username and password for the PostGIS administrator account is **opengeo** / **opengeo**

Testing connection
~~~~~~~~~~~~~~~~~~

To verify that PostGIS is installed properly, you can run the following command in a terminal (you will be prompted for a password):

.. code-block:: bash

   $ psql -Uopengeo -p5432 -c"SELECT postgis_full_version();" medford

If PostGIS is installed correctly, you should see information about the installed database.


pgAdmin III
~~~~~~~~~~~

The graphical management utility pgAdmin is included with the install.  To run pgAdmin, type :command:`pgadmin3` at a terminal, or navigate to :menuselection:`Applications --> Programming --> pgAdmin III`.



For more information about running PostGIS, please see the `PostGIS Documentation <http://suite.opengeo.org/docs/postgis/>`_

