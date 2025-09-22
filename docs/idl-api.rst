IDL API
=======

Interactive interface
---------------------

For working interactively at the IDL command line, the only routine needed is
``mlsoapi``. See the "Programmatic interace" section below for writing programs
that can be used in non-interactive programs.

``mlsoapi``
^^^^^^^^^^^

.. code-block:: IDL

    pro mlsoapi, instrument=instrument, $
                 product=product, $
                 wave_region=wave_region, $
                 start_date=start_date, $
                 end_date=end_date, $
                 carrington_rotation=carrington_rotation, $
                 download=download, $
                 output_dir=output_dir, $
                 username=username, $
                 base_url=base_url, $
                 api_version=api_version, $
                 verbose=verbose

Query the MLSO database for instruments, products, and files available. Files
can optionally be downloaded if the email username passed via the ``USERNAME``
keyword has been registered with the `HAO website`_.

.. _HAO website: https://registration.hao.ucar.edu

Keywords
""""""""

:instrument: ``in, required, type=string`` instrument ID to find the files of
:product: ``in, required, type=string`` product ID to find the files of
:wave_region: ``in, optional, type=string`` wave region of files to return
:start_date: ``in, optional, type=string`` start date to begin looking for files from
:end_date: ``in, optional, type=string`` end date to end looking for files to
:carrington_rotation: ``in, optional, type=integer`` Carrington Rotation number of files to return
:download: ``in, optional, type=boolean`` set to download files found if both `instrument` and `product` are specified
:output_dir: ``in, optional, type=string, default='.'`` location to place downloaded files, creates if it doesn't already exist
:username: ``in, optional, type=string`` username registered with HAO website, required if `/DOWNLOAD` set
:base_url: ``in, required, type=string, default="http://api.mlso.ucar.edu"`` base URL for the MLSO API server
:api_version: ``in, optional, type=string, default="v1"`` version of the API to use


Programmatic interface
----------------------

``mlso_instruments``
^^^^^^^^^^^^^^^^^^^^

.. code-block:: IDL

    function mlso_instruments, base_url=base_url, $
                               api_version=api_version, $
                               url_object=url_object, $
                               n_instruments=n_instruments

Retrieve list of instruments from the ``/instruments/{instrument}`` endpoint
with some of their properties.

Returns
"""""""

array of structures with fields "id", "name", "start_date", and "end_date", all
strings

Keywords
""""""""

:base_url: ``in, optional, type=string, default="http://api.mlso.ucar.edu"`` base URL for the API
:api_version: ``in, optional, type=string, default="v1"`` version of the API to use
:url_object: ``in, optional, type=IDLnetURL object`` existing `IDLnetURL` object if available
:n_instruments: ``out, optional, type=long`` set to a named variable to retrieve the number of instruments


``mlso_products``
^^^^^^^^^^^^^^^^^

.. code-block:: IDL

    function mlso_products, instrument, $
                            base_url=base_url, $
                            api_version=api_version, $
                            url_object=url_object, $
                            n_products=n_products

Retrieve information about the products available for a given instrument from
the ``/instruments/{instrument}/products`` endpoint.

Returns
"""""""
structure with field "products" which is an array of structures with fields
"id", "title", and "description"

Params
""""""

:instrument: ``in, required, type=string`` instrument ID to find the products of

Keywords
""""""""
:base_url: ``in, optional, type=string, default="http://api.mlso.ucar.edu"`` base URL for the API
:api_version: ``in, optional, type=string, default="v1"`` version of the API to use
:url_object: ``in, optional, type=IDLnetURL object`` existing `IDLnetURL` object if available
:n_products: ``out, optional, type=long`` set to a named variable to retrieve the number of products


``mlso_files``
^^^^^^^^^^^^^^

.. code-block:: IDL

    function mlso_files, instrument, product, $
                         n_files=n_files, $
                         wave_region=wave_region, $
                         start_date=start_date, $
                         end_date=end_date, $
                         carrington_rotation=carrington_rotation, $
                         every=every, $
                         client=client, $
                         base_url=base_url, $
                         api_version=api_version, $
                         url_object=url_object

Retrieve information about the files available for a given instrument and
product from the ``/instruments/{instrument}/products/{product}`` endpoint.

Returns
"""""""

array of structures with fields "filename" and "url"

Params
""""""

:instrument: ``in, required, type=string`` instrument ID to retrieve files for
:product: ``in, required, type=string`` product ID for instrument to retrieve files for

Keywords
""""""""

:n_files: ``out, optional, type=long`` set to a named variable to retrieve the number of files
:wave_region: ``in, optional, type=string`` wave region of files to return
:start_date: ``in, optional, type=string`` start date to begin looking for files from
:end_date: ``in, optional, type=string`` end date to end looking for files to
:carrington_rotation: ``in, optional, type=integer`` Carrington Rotation number of files to return
:every: ``in, optional, type=string`` time period to select 1 file from, e.g., "15minute" returns 1 file every 15 minutes; units are second, minute, hour, day, week, month, quarter, year
:client: ``in, optional, type=string, default="idl"`` client used, e.g., "idl", "forward"
:base_url: ``in, optional, type=string, default="http://api.mlso.ucar.edu"`` base URL for the APIå
:api_version: ``in, optional, type=string, default="v1"``` version of the API to use
:url_object: ``in, optional, type=IDLnetURL object`` existing `IDLnetURL` object if available


``mlso_download_file``
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: IDL

    pro mlso_download_file, basename, url, username, $
                            output_dir=output_dir, $
                            base_url=base_url, $
                            api_version=api_version, $
                            url_object=url_object, $
                            verbose=verbose

Download a file given its name, URL, and a valid username registered with the
HAO website.

Parameters
""""""""""

:basename: ``in, required, type=string`` file basename to use for downloaded file
:url: ``in, required, type=string`` URL of file to download
:username: ``in, required, type=string`` username registered with HAO website

Keywords
""""""""

:output_dir: ``in, optional, type=string, default='.'`` location to place downloaded file
:base_url: ``in, optional, type=string, default="http://api.mlso.ucar.edu"`` base URL for the API
:api_version: ``in, optional, type=string, default="v1"`` version of the API to use
:url_object: ``in, optional, type=IDLnetURL object`` existing `IDLnetURL` object if available
:verbose: ``in, optional, type=boolean`` set to print log messages to the console
