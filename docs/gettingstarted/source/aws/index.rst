.. _aws:

OpenGeo Suite on Amazon Web Services
====================================

The OpenGeo Suite Community Edition is available as public Amazon Machine Instances (AMIs) ready for deployment on Amazon Web Services.  AMIs are available for Linux (Ubuntu 9.10) and Windows (Server 2003).    The OpenGeo Suite AMIs simplify deploying web mapping applications by providing a complete environment. When an instance is launched the OpenGeo Suite is ready to serve maps and data on the web.  These AMIs are built on S3 boot images to provide a low cost of operation.

.. note:: AMIs based on S3 boot images will lose all data and changes you have made if the instance is terminated.  To ensure that data and applications are saved you can add an Elastic Block Storage (EBS) Volume to store your data. This is not included with the OpenGeo Suite Community Edition AMIs.  

The first section, :ref:`aws.connecting`, describes how to obtain security credentials if you are new to Amazon Web Services. If you are already an AWS customer, you can log into your AWS console and skip to :ref:`aws.launch`.

.. toctree::
   :maxdepth: 2

   connecting
   launch
   login

