.. _aws.launch:


Launching the OpenGeo Suite
===========================

Launching Using the AWS Management Console
------------------------------------------

#. Log in the AWS Management Console and click the Amazon EC2 tab
#. Click on AMIs in the Navigation side menu
#. In the Amazon Machine Images pane, select Public Images and All Platforms in the drop down menus.
#. Copy and paste the OpenGeo Suite image AMI ID into the text box and hit enter.

   * Windows AMI: ami-ea1cf683
   * Linux AMI: ami-041cf66d

   The selected instance is displayed below

   .. figure:: images/launching-ami.png
      :align: center
   
      *Launching AMI*
 
#. To start or launch the instance, select the check box and click on the Launch button.

   #. Enter 1 in the Number of Instances field.
   #. Select the m1.small Instance Type option.
   #. Select the Availability Zone, if desired.
   #. Select the key pair that you created from the Key Pair Name list box.
   #. Select default from the Security Groups list box.

   The instance(s) begin launching.

   .. figure:: images/pending-instance.png
      :align: center

      *Pending instance*

Launching the OpenGeo Suite Using the Command Line
--------------------------------------------------

#. Type in the ``ec2-run-instances`` command with your private key.

   * Windows AMI: ami-ea1cf683
   * Linux AMI: ami-041cf66d
   
   ::

      ec2-run-instances ami-ea1cf683 -K pk-xxxxxxxxxxxxxxxxxxxxx.pem

   Amazon EC2 will return::
   
      RESERVATION     r-6cbf9307     004891484588     default
      INSTANCE     i-f9da9993     ami-ea1cf683               pending          0          m1.small     2010-09-02T02:12:51+0000     
      us-east-1d               windows     monitoring-disabled                         instance-store 

#. Note the instance ID (i-f9da9993) and save it; you can use it control the instance.  For example you can check the status of an instance::
   
      ec2-describe-instances i-f9da9993

   Amazon EC2 will return::

      RESERVATION     r-6cbf9307     004891484588     default INSTANCE     i-f9da9993     ami-ea1cf683               pending          0          m1.small     2010-09-02T02:12:51+0000     us-east-1d               windows     monitoring-disabled                         instance-store 

   Or you can terminate an instance::

      ec2-terminate-instances i-f9da9993

   Amazon EC2 will return::

      INSTANCE     i-f9da9993     pending     shutting-down

