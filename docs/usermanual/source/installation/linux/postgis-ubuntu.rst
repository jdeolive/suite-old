.. _installation.linux.postgis-ubuntu:

Installing PostGIS on Ubuntu
============================

The easiest way to install and set up PostGIS is by :ref:`installing the full OpenGeo Suite <installation.linux.suite>`.  The OpenGeo Suite comes complete with GeoServer as well as a full geospatial software stack, including utilities, data, and documentation.  That said, OpenGeo also provides individual packages for installing the components separately.

This page will describe how to install PostGIS on Ubuntu 10.04 (Lucid).  Earlier versions of Ubuntu are not supported at this time.

Access the OpenGeo APT repository
---------------------------------

OpenGeo provides a repository for packages in APT (Debian) format.  To access this repository, you need to first import the OpenGeo GPG key in to your apt registry:

.. note:: You will need to run these commands on an account with root access.

.. code-block:: bash

   wget -qO- http://apt.opengeo.org/gpg.key | apt-key add -

Once added, you can add the OpenGeo APT repository (http://apt.opengeo.org) to your local list of repositories:

.. code-block:: bash

   echo "deb http://apt.opengeo.org/ubuntu lucid main" >> /etc/apt/sources.list
      
Now update APT to pull in your changes:

.. code-block:: bash

   apt-get update


Package management
------------------

Search for packages from OpenGeo:

.. code-block:: bash

   apt-cache search opengeo

If the search command does not return any results, the repository was not added properly. Examine the output of the ``apt`` commands for any errors or warnings.

Now you can install PostGIS.  The name of the package is :guilabel:`opengeo-postgis`:

.. code-block:: bash

   apt-get install opengeo-postgis


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

