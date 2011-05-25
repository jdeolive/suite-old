.. _installation.aws:

Installing the OpenGeo Suite for Amazon EC2
===========================================

The OpenGeo Suite is available as a AMI for use with Amazon's EC2 service.  The OpenGeo Suite is available in five tiers:

.. list-table::
   :widths: 20 20 20 20 20
   :header-rows: 1

   * - Name
     - Instance Size
     - Setup Fee
     - Cost per hour
     - Cost per month
   * - Dev Small
     - Standard Small
     - N/A
     - $0.13
     - N/A
   * - Dev Large
     - Standard Medium
     - N/A
     - $0.45
     - N/A
   * - Production 1 Small
     - Standard Medium
     - $500
     - N/A
     - $600
   * - Production 2 Medium
     - High Memory Extra Large
     - $750
     - N/A
     - $800
   * - Production 3 Large
     - Standard Extra Large
     - $1000
     - N/A
     - $1,150

.. note:: Details about the Instance Size (number of CPUs, etc.) can be found on Amazon's `Amazon EC2 Instance Types <http://aws.amazon.com/ec2/instance-types/>`_ page.

The process for signing up for any of these tiers is exactly the same.  Only the features and pricing differ.

Signing up
----------

.. warning:: In order to use the OpenGeo Suite Cloud Edition for Amazon Web Services (AWS), you need to have an Amazon Web Services (AWS) account which has EC2 access enabled.  Amazon has detailed instructions on how to sign up for AWS/EC2 at http://aws.amazon.com/documentation/ec2/.

#. Navigate to the OpenGeo Suite Cloud page at http://opengeo.org/products/suite/cloud/. On the Amazon Web Services column, select the tier you wish to purchase by clicking the appropriate link.

#. You will be redirected to Amazon's site, and asked to log in to AWS.  Enter your AWS account name and password and click :guilabel:`Sign in using our secure server`.

   .. figure:: img/signin.png
      :align: center

      *Signing in to AWS*

#. You will see a description of the product, including all initial and recurring charges.  Please review the information, and then click :guilabel:`Place your order`.

   .. warning:: By clicking :guilabel:`Place your order`, you are committing to any charges associated with your purchase.

   .. figure:: img/placeyourorder.png
      :align: center

      *Reviewing order*

#. Once the sale is completed you will be redirected to an OpenGeo registration page.  Fill out the form to sign up for the OpenGeo support and to receive your instance ID.  This step is necessary in order to continue.  When done, click :guilabel:`Submit`.

   .. figure:: img/thankyouamazon.png
      :align: center

      *Please fill out this form to complete the sign up process*

#. You will soon receive an email from OpenGeo containing helpful information, links, and other details about your purchase.  Refer to this email below.

Logging in
----------

The next step is to launch your new OpenGeo Suite Cloud instance.  This is done through Amazon's AWS console.

#. Navigate to http://aws.amazon.com.

#. Click on the link on the top that says :guilabel:`Sign in to the AWS Management Console`.  To log in, use the same credentials you used when purchasing the OpenGeo Suite.

#. You will be redirected to your main AWS console.

   .. figure:: img/firstsignins3.png
      :align: center

      *Viewing the default AWS console*

#. Click on the EC2 tab.

   .. figure:: img/firstsigninec2.png
      :align: center

      *AWS EC2 console*

#. Click on :guilabel:`AMIs`.  

   .. figure:: img/amis.png
      :align: center

      *Viewing your list of AMIs*

#. You will need the AMI ID given to you when you registered.  Change the select box titled :guilabel:`Viewing` to read :guilabel:`All Public Images`.  Then enter your AMI ID in the box.  You should see an OpenGeo AMI show up in the list.

   .. note:: If you did not register, or never received an email with your AMI ID, please email inquiry@opengeo.org.

   .. figure:: img/foundami.png
      :align: center

      *Viewing the default AWS console*

#. Select the instance and then click the :guilabel:`Launch` button.  A dialog box will display asking for details.  Make sure that :guilabel:`Launch Instances` is selected, but you should not need to change any settings here.  Click :guilabel:`Continue`.

   .. figure:: img/requestinstance-instancetype.png
      :align: center

      *Launching an instance*

#. On the next page (Advanced Instance options), leave the default settings blank, and click :guilabel:`Continue`.

   .. figure:: img/requestinstance-advanced.png
      :align: center

      *Advanced instance details*

#. The next page allows for the creation of a tag for organization.  This step is optional.  Click :guilabel:`Continue`.

   .. figure:: img/requestinstance-tags.png
      :align: center

      *Tag creation page*

#. You will be asked to create a key pair.  This is used to be able to securely connect (via SSH) to the instance after it launches.  Enter a name for your key pair, then download it to your local machine, keeping it in a safe place.  When done, click :guilabel:`Continue`.

   .. warning:: Save this key pair!  Keys cannot be generated or retrieved at a later time.  If you have any plans to connect via SSH or SCP on this instance in the future, you will want to have a key pair already generated.

   .. figure:: img/requestinstance-keypair.png
      :align: center

      *Creating a keypair*

#. In order to open the proper ports for accessing the OpenGeo Suite, it is necessary to create a security group.  From this page, click on :guilabel:`Create a New Security Group`.

   .. figure:: img/requestinstance-security.png
      :align: center

      *Security Group page*

   .. figure:: img/requestinstance-newsecgroup.png
      :align: center

      *New Security Group page*

#. On the New Security Group page, enter a :guilabel:`Group Name` and `Group Description` ("Ports" for both is fine).  Create the following new rules, both :guilabel:`Custom TCP rules`.

   .. list-table::
      :widths: 30 30 40
      :header-rows: 1

      * - Port range
        - Source
        - Usage
      * - **80**
        - ``0.0.0.0/0``
        - Default port for web server
      * - **8080**
        - ``0.0.0.0/0``
        - Default port for web applications
      * - **22**
        - ``0.0.0.0/0``
        - Required for SSH access

   You may add other rules as desired.  When finished click :guilabel:`Continue`.

   .. figure:: img/requestinstance-newsecgroupfinal.png
      :align: center

      *Creating a new Security Group*

#. Verify that the setting are correct, then click :guilabel:`Launch`.

   .. figure:: img/requestinstance-review.png
      :align: center

      *Reviewing settings*

#. Now close out of the dialog box and click on the :guilabel:`Instances` link on the left hand column.  You should see your instance in the process of being generated.

   .. figure:: img/instancepending.png
      :align: center

      *New instance pending*

#. When the instance is fully generated, click on it to see the instance details.  

   .. figure:: img/instancedetails.png
      :align: center

      *New instance pending*

#.  Note the :guilabel:`Public DNS` entry.  Use this to connect to the OpenGeo Suite Dashboard and begin using the OpenGeo Suite.  In a new browser window, type the following URL::

       http://<Public DNS>:8080/dashboard/

    For example::

       http://ec2-174-129-64-92.compute-1.amazonaws.com:8080/dashboard/

   This will launch the Dashboard.

   .. figure:: img/dashboard.png
      :align: center

      *OpenGeo Suite Dashboard, showing a successful installation*

You are now set up and ready to go!

SSH Access
----------

.. note:: This step requires that port 22 was opened in the Security Group created during the launching of your instance and that a key pair was generated.

Linux / Mac OS X
~~~~~~~~~~~~~~~~

You may connect to this instance via SSH using the ``ssh`` command::

   ssh -i yourkey.pem ubuntu@<Public DNS>

For example::

   ssh -i yourkey.pem ubuntu@ec2-174-129-64-92.compute-1.amazonaws.com

where :file:`yourkey.pem` is the name of the downloaded key file.

Windows
~~~~~~~

You may connect to this instance via SSH using `PuTTY <http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html>`_, but you will need to convert your key to a format that PuTTY understands.  This is done with `PuTTYgen <http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html>`_:

#. Run PuTTYgen.

#. Click :guilabel:`Load` ("Load an existing private key").

#. Select the key file.

#. After loading, click :guilabel:`Save private key`.  This is the key to use when connecting with PuTTY.  it will have a ``.ppk`` file extension.

To connect with PuTTY, make sure to load the ``.ppk`` file under :menuselection:`Connection --> SSH --> Auth` in the box titled :guilabel:`Private key file for authentication`. Once done, enter the host name, and connect as user ``ubuntu``.

To connect with PuTTY using the command line::

  putty -i yourkey.ppk -ssh ubuntu@<Public DNS>

For example::

  putty -i yourkey.ppk -ssh ubuntu@ec2-174-129-64-92.compute-1.amazonaws.com

where :file:`yourkey.ppk` is the name of the key file created by PuTTYgen.

For More Information
--------------------

Full documentation is available at the following URL from your instance::

  http://<Public DNS>:8080/docs/

Please contact inquiry@opengeo.org for more information.