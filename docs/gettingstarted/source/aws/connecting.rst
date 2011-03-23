.. _aws.connecting:

Connecting to Amazon Web Services
=================================

You will first need an Amazon Web Services account.  You can register for an account at `<http://aws.amazon.com/>`_ if you don't have one.  If you already have an AWS account, you can skip this section and start at :ref:`aws.launch` instance using the AWS Management Console.

Once you have an AWS account you will need to generate a set of security credentials to manage your account and your AMIs. You will need the following credentials: 

* Access Credentials: Your Private Keys, X.509 Certificates, and Key Pairs for managing your AMIs
* Sign-In Credentials: Your E-mail Address, Password for managing your account
* Account Identifiers: Your AWS Account ID 

Install Command Line Tools
--------------------------

Configuring the OpenGeo Suite on AWS using the command line requires installing EC2 Tools from Amazon.  EC2 Tools is a collection of command line tools written in Java that run in Linux, OS X, and Windows. Download the Command Line Tools from the `Amazon EC2 Resource Center <http://developer.amazonwebservices.com/connect/entry.jspa?externalID=351&categoryID=88>`_

It is recommended that you create a directory named ``.ec`` and unzip the ``ec2-api-tools`` in that directory. Unzipping the file will create ``bin`` and ``lib`` directories. The command line tools use environment variables to locate libraries and executables.

On Linux, OS X and other UNIX operating systems, set the environmental variables:

.. code-block: bash

    $ export EC2_HOME=/home/opengeo/.ec2
    $ export PATH=$PATH:$EC2_HOME/.ec2/bin

On Windows, set the environment variables:

.. code-block: batch

    C:\>set EC2_HOME=C:\Documents and Settings\OpenGeo\.ec2
    C:\>set PATH=%PATH%:%EC2_HOME%\bin


Creating a X.509 certificate and a Private Key
----------------------------------------------

The X.509 Certificate and Private Key are used by the command line tools and SOAP.  The X.509 certificate and Private Key are used when starting or stopping instances and when creating new AMIs. You can download the private key file once. If you lose it, you will need to create a new certificate. Up to two certificates can be active at any time.

#. Log into the AWS Web Site.
#. Click on Your Account and select Security Credentials
#. Click the X.509 Certificates tab

   .. figure:: images/create-x509-cert.png
      :align: center

      *X.509 Certificates tab*

   
#. Click Create a New Certificate and download the certificate and private key files.

   .. figure:: images/x509-download.png
      :align: center

      *New certificate and Private Key file*
      
#. If you haven't created a ``.ec2`` directory in your home directory, create it and save these files to it with the filenames offered by your browser.


Generate a Key Pair using the AWS Management Console
----------------------------------------------------

A key pair is used when logging into an Amazon EC2 instance.

#. Log into the AWS Management Console and click on the Amazon EC2 tab
#. Click on Key Pairs in the Navigation pane on the left.

   .. figure:: images/aws-console-keypair.png
      :align: center

      *Key pairs*

#. Click on Create Key Pair, enter a name, and click Create

   .. figure:: images/create-keypair.png
      :align: center

      *Creating a key pair*
   
#. The key pair will be downloaded automatically.  Keep the file in a safe place.

   .. figure:: images/download-keypair.png
      :align: center

      *Downloading a key pair*

#. If you are using Linux, OS X, or any UNIX-based OS, set the file permissions to be readable by you:

   .. code-block: bash

      $ chmod 600 my-keypair
        
Generate a Key Pair using EC2 Command Line Tools
------------------------------------------------

#. At the prompt type::

      ec2-add-keypair my-keypair

   EC2 will return a key pair::

      KEYPAIR  example-keypair  a8:c7:1b:fe:71:fb:93:b5:6b:21:ec:bc:12:22:fa:9c:66:96:53:85
      -----BEGIN RSA PRIVATE KEY-----
      MIIEowIBAAKCAQEAwgrhWS8CH8pWu9445lP7vzBvC9J1EAROQLUYr/nbEAbui+PAvakzHc4ykBqB
      ftlc6smydgD0vEaiCLuFAhFw6EzpUfe2ZgftIAfr6QV8orhOuhc1nP6JSID4ed5i+CEPjRRAkJh1
      9BIlVAQCjf34DKXqPD+DOli+omzN6IhAdpSNPuTsqdTQv0u1rWBBeQZFOH0JTf/afcoxcCi4emq6
      BOIFSXt3vyPSImVvxMgpk1Z5Ndh1li6aESxW33i67K5u71WvtFnyYjMhhjp3PBMiTMYCmkrbhLMu
      gCGBQMlIH54UdgO8wD+rLU7aja0SYkHEJGXW6rzAZ5dbm79gUIRqOs0wAhBKVoTQNFcpZVha7MCg
      YEA2ArzwCbll9TKVXQ4SdILzGvrCe3xPv08MmqXbzJti6I9MGC/QBHO4iZDUJ8hIz6HjxNHYse6p
      EauSauw2Vhlom3ki3kvUpa/hUBN1REKPo8d8WOzUNBw8EFN5jgJ0fpAhecbijFhEFdfXyNSM3Bxt
      fWmpC8CW+Nge0S/SPoNGI0CgYBKxgUPe67Jcqme7w70q0dUAmtRBZYU9k+5FEHJxYXCsc8ljhQS4
      7M6KOYJbVXJry6V7gZlAst5Sr+ntCdeQDpGqFUxNE718AavH6mFKxAL3BhSG8kwJ+N7BmRUVg+vo
      0AYW4JKNds2/tdCrhhwgqkrsvK5x6TMoLN8yhwAmnkG9K7NAODRP8tyDYwmYxKewdpGqEPwUz8Wm
      Mj1YnQjtcgnkvE1Yu4oA133Thp+CGNQxaGbzE1ZIsbJK7ABJklYwxBgbSvt/3rk26e84YSS6cH5X
      /+jBshC8tF2v7JaYUdv4DF1DwriLoySMyjhtPV0qRHKhSRda2dpeH3Sh7M5J0lsnneN2T9Csm+n0
      tgGIfHtmyZyr7G6hp+fIpRBmvOLOB0pkE+MZyP+YDUGy39qkYSPgmbPGXqhcL6rDQKHt3o5+YAY0
      gOE+4Azk5Qn1QdQnkOugpHIJZkCgYEA6teEMdPErPxqVkzrhVVDCtLmr6RUhI6A7KRnKJISIThBS
      f32EKkL7JKv7NH1BjW0CGDBLvpMaqaelwNNzIvH2/+2nWYcAgC9Kvq0QrIgmHyhdvjcjF7Uqv3jI
      29r4Xtq4oVaiPLb1SamMuKk7t7e40LFp65NHZlz1IDenxsIKZMCgYEA04ZaBZ28eqKON3aHVCTmA
      LUTDrtkxA98WWUEPT5DJz1EGX2EbLw45qz6Uvv1FUQjWL5dtGHhm/Xzz5rFYDUG7GikDCzx3Izyh
      IjiAdKaHDGX47Nt9CdRm2VXXdKtIbkc/t6cop9S6bFHe65EZ673HwIDAQABAoIBAHm6sNtXhPnpG
      LGiHMzQT5xew7xIsvf9I47c8OXM7SMAekXILU/vJ0GOGTkE3D25vHC+1EmywixjhXHddCpnmYO5D
      IaqmZTmJSACWSOlRdus3326DVY3K0exgaM2+LhwTCkpeZ5n2Wc5SpoOp5ADEyaUDVy7rQnMLoyGV
      1LqUtEXlAEdc4/2daYIBTP9YMfXw3zsv7LRMI11bVkYS45I5dYMBJ/bUlFm2v5k0b7V
      -----END RSA PRIVATE KEY-----

#. Create file with called ``my-keypair``, and copy the the text, starting from::

     -----BEGIN RSA PRIVATE KEY-----
     
   and ending with::
     
     -----END RSA PRIVATE KEY-----

   The file should look similar to this. Save the file::

      -----BEGIN RSA PRIVATE KEY-----
      MIIEowIBAAKCAQEAwgrhWS8CH8pWu9445lP7vzBvC9J1EAROQLUYr/nbEAbui+PAvakzHc4ykBqB
      ftlc6smydgD0vEaiCLuFAhFw6EzpUfe2ZgftIAfr6QV8orhOuhc1nP6JSID4ed5i+CEPjRRAkJh1
      9BIlVAQCjf34DKXqPD+DOli+omzN6IhAdpSNPuTsqdTQv0u1rWBBeQZFOH0JTf/afcoxcCi4emq6
      BOIFSXt3vyPSImVvxMgpk1Z5Ndh1li6aESxW33i67K5u71WvtFnyYjMhhjp3PBMiTMYCmkrbhLMu
      gCGBQMlIH54UdgO8wD+rLU7aja0SYkHEJGXW6rzAZ5dbm79gUIRqOs0wAhBKVoTQNFcpZVha7MCg
      YEA2ArzwCbll9TKVXQ4SdILzGvrCe3xPv08MmqXbzJti6I9MGC/QBHO4iZDUJ8hIz6HjxNHYse6p
      EauSauw2Vhlom3ki3kvUpa/hUBN1REKPo8d8WOzUNBw8EFN5jgJ0fpAhecbijFhEFdfXyNSM3Bxt
      fWmpC8CW+Nge0S/SPoNGI0CgYBKxgUPe67Jcqme7w70q0dUAmtRBZYU9k+5FEHJxYXCsc8ljhQS4
      7M6KOYJbVXJry6V7gZlAst5Sr+ntCdeQDpGqFUxNE718AavH6mFKxAL3BhSG8kwJ+N7BmRUVg+vo
      0AYW4JKNds2/tdCrhhwgqkrsvK5x6TMoLN8yhwAmnkG9K7NAODRP8tyDYwmYxKewdpGqEPwUz8Wm
      Mj1YnQjtcgnkvE1Yu4oA133Thp+CGNQxaGbzE1ZIsbJK7ABJklYwxBgbSvt/3rk26e84YSS6cH5X
      /+jBshC8tF2v7JaYUdv4DF1DwriLoySMyjhtPV0qRHKhSRda2dpeH3Sh7M5J0lsnneN2T9Csm+n0
      tgGIfHtmyZyr7G6hp+fIpRBmvOLOB0pkE+MZyP+YDUGy39qkYSPgmbPGXqhcL6rDQKHt3o5+YAY0
      gOE+4Azk5Qn1QdQnkOugpHIJZkCgYEA6teEMdPErPxqVkzrhVVDCtLmr6RUhI6A7KRnKJISIThBS
      f32EKkL7JKv7NH1BjW0CGDBLvpMaqaelwNNzIvH2/+2nWYcAgC9Kvq0QrIgmHyhdvjcjF7Uqv3jI
      29r4Xtq4oVaiPLb1SamMuKk7t7e40LFp65NHZlz1IDenxsIKZMCgYEA04ZaBZ28eqKON3aHVCTmA
      LUTDrtkxA98WWUEPT5DJz1EGX2EbLw45qz6Uvv1FUQjWL5dtGHhm/Xzz5rFYDUG7GikDCzx3Izyh
      IjiAdKaHDGX47Nt9CdRm2VXXdKtIbkc/t6cop9S6bFHe65EZ673HwIDAQABAoIBAHm6sNtXhPnpG
      LGiHMzQT5xew7xIsvf9I47c8OXM7SMAekXILU/vJ0GOGTkE3D25vHC+1EmywixjhXHddCpnmYO5D
      IaqmZTmJSACWSOlRdus3326DVY3K0exgaM2+LhwTCkpeZ5n2Wc5SpoOp5ADEyaUDVy7rQnMLoyGV
      1LqUtEXlAEdc4/2daYIBTP9YMfXw3zsv7LRMI11bVkYS45I5dYMBJ/bUlFm2v5k0b7V
      -----END RSA PRIVATE KEY-----

#. If you are using Linux, OS X, or any UNIX-based OS, set the file permissions to be readable by you:

   .. code-block: bash

      chmod 600 my-keypair

