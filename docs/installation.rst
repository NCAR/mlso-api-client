.. highlight:: shell

============
Installation
============

Note: Downloading files requires an email address registered at the
`HAO website`_. Queries can be done without this email username.

.. _HAO website: https://registration.hao.ucar.edu


Python
------

Stable release
^^^^^^^^^^^^^^

To install mlso-api-client, run this command in your terminal:

.. code-block:: console

    $ pip install mlso-api-client

This is the preferred method to install mlso-api-client, as it will always install the most recent stable release.

If you don't have `pip`_ installed, this `Python installation guide`_ can guide
you through the process.

.. _pip: https://pip.pypa.io
.. _Python installation guide: http://docs.python-guide.org/en/latest/starting/installation/


From source
^^^^^^^^^^^

The sources for mlso-api-client can be downloaded from the `Github repo`_.

You can either clone the public repository:

.. code-block:: console

    $ git clone https://github.com/NCAR/mlso-api-client.git

Or download the `tarball`_:

.. code-block:: console

    $ curl -OL https://github.com/NCAR/mlso-api-client/archive/refs/heads/main.zip
    $ unzip main.zip

Either way, once you have a copy of the source, you can install it with:

.. code-block:: console

    $ cd mlso-api-client  # or mlso-api-client-main if the zip was downloaded
    $ pip install .


.. _Github repo: https://github.com/NCAR/mlso-api-client
.. _tarball: https://github.com/NCAR/mlso-api-client/tarball/master


IDL
---

Follow the instructions above for obtaining the source code, either the
``git clone`` or ``curl`` command, then put the ``idl`` subdirectory in your
IDL path via the Workbench or updating the ``IDL_PATH`` environment variable..
