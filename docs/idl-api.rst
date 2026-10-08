IDL API
=======

Interactive interface
---------------------

For working interactively at the IDL command line, the only routine needed is
``mlsoapi``. See the "Programmatic interface" section below for writing programs
that can be used in non-interactive programs.

``mlsoapi``
^^^^^^^^^^^

.. code-block:: IDL

    pro mlsoapi, instrument=instrument, $
                 dataset=dataset, $
                 product=product, $
                 wave_region=wave_region, $
                 start_date=start_date, $
                 end_date=end_date, $
                 carrington_rotation=carrington_rotation, $
                 every=every, $
                 event=event, $
                 filter_instrument=filter_instrument, $
                 download=download, $
                 output_dir=output_dir, $
                 username=username, $
                 local=local, $
                 base_url=base_url, $
                 api_version=api_version, $
                 verbose=verbose

Query the MLSO database for instruments, datasets, products, files, and data
available. Files can optionally be downloaded if the email username passed via
the ``USERNAME`` keyword has been registered with the `HAO website`_.

.. _HAO website: https://registration.hao.ucar.edu

If no arguments are provided, the available instruments and datasets are listed.
If an instrument or dataset is given, then the products for that instrument or
data set are listed. If a product is given, then the files for the given
instrument, or data for the given dataset, is listed, filtered by the various
other keywords. If listing files of an instrument, the files can be downloaded
with the `DOWNLOAD` keyword if the username has been set as above. There is no
equivalent required for datasets.

Keywords
""""""""

:instrument: ``in, optional, type=string`` instrument ID to find the products/files of
:dataset: ``in, optional, type=string`` dataset ID to find the products/data of
:product: ``in, optional, type=string`` product ID to find the files/data of
:wave_region: ``in, optional, type=string`` wave region of files to return, valid values are "637", "706", "789", 1074", "1079"
:start_date: ``in, optional, type=string`` start date to begin looking for files from
:end_date: ``in, optional, type=string`` end date to end looking for files to
:carrington_rotation: ``in, optional, type=integer`` Carrington Rotation number of files to return
:every: ``in, optional, type=string`` time period to select 1 file from, e.g., "15minute" returns 1 file every 15 minutes; units are second, minute, hour, day, week, month, quarter, year
:event: ``in, optional, type=string`` event type to return files during, currently only "cme"
:filter_instrument: ``in, optional, type=string`` filter datasets by instrument observed in
:download: ``in, optional, type=boolean`` set to download files found if both `instrument` and `product` are specified
:output_dir: ``in, optional, type=string, default='.'`` location to place downloaded files, creates if it doesn't already exist
:username: ``in, optional, type=string`` username registered with HAO website, required if `/DOWNLOAD` set
:local: ``in, optional, type=boolean`` set to use localhost as the API address
:base_url: ``in, optional, type=string, default="http://api.mlso.ucar.edu"`` base URL for the MLSO API server
:api_version: ``in, optional, type=string, default="v1"`` version of the API to use
:verbose: ``in, optional, type=boolean`` set to print queried URLs and raw JSON responses

Programmatic interface
----------------------

``mlso_about``
^^^^^^^^^^^^^^

.. code-block:: IDL

    function mlso_about, base_url=base_url, $
                         api_version=api_version, $
                         url_object=url_object

Retrieve basic facts about the MLSO API server, i.e., the results of the
``/about`` endpoint. For example:

.. code-block:: IDL

    IDL help, mlso_about()
    ** Structure <3060f828>, 4 tags, length=64, data length=64, refs=1:
    DOCUMENTATION   STRING    'https://mlso-api-client.readthedocs.io/en/latest/'
    HOMEPAGE        STRING    'https://www2.hao.ucar.edu/mlso'
    SUPPORT         STRING    'mlso_data_requests@ucar.edu'
    VERSION         STRING    '1.1.0'

Returns
"""""""

structure with fields "documentation", "homepage", "support", "version"

Keywords
""""""""

:base_url: ``in, optional, type=string, default="http://api.mlso.ucar.edu"`` base URL for the API
:api_version: ``in, optional, type=string, default="v1"`` version of the API to use
:url_object: ``in, optional, type=IDLnetURL object`` existing `IDLnetURL` object if available


``mlso_instruments``
^^^^^^^^^^^^^^^^^^^^

.. code-block:: IDL

    function mlso_instruments, base_url=base_url, $
                               api_version=api_version, $
                               url_object=url_object, $
                               n_instruments=n_instruments

Retrieve list of instruments from the ``/instruments`` endpoint and some of
their properties with the ``/instruments/{instrument}`` endpoint.

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


``mlso_datasets``
^^^^^^^^^^^^^^^^^

.. code-block:: IDL

    function mlso_datasets, base_url=base_url, $
                            api_version=api_version, $
                            url_object=url_object, $
                            n_datasets=n_datasets

Retrieve list of datasets from the ``/datasets`` endpoint and some of their
properties with the ``/datasets/{dataset}`` endpoint.

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
the ``/instruments/{instrument}/products`` endpoint or for a given dataset from
the ``/datasets/{dataset}/products`` endpoint..

Returns
"""""""
structure with field "products" which is an array of structures with fields
"id", "name", and "description"

Params
""""""

:instrument: ``in, required, type=string`` instrument or dataset ID to find the products of

Keywords
""""""""
:is_dataset: ``in, optional, type=boolean`` set to indicate that the `instrument` argument is actually a dataset
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
                         event=event, $
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
:wave_region: ``in, optional, type=string`` wave region of files to return, valid values are "637", "706", "789", 1074", "1079"
:start_date: ``in, optional, type=string`` start date to begin looking for files from
:end_date: ``in, optional, type=string`` end date to end looking for files to
:carrington_rotation: ``in, optional, type=integer`` Carrington Rotation number of files to return
:every: ``in, optional, type=string`` time period to select 1 file from, e.g., "15minute" returns 1 file every 15 minutes; units are second, minute, hour, day, week, month, quarter, year
:event: ``in, optional, type=string`` event type to return files during, currently only "cme"
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


``mlso_data``
^^^^^^^^^^^^^

.. code-block:: IDL

    function mlso_data, dataset, product, $
                         n_data=n_data, $
                         start_date=start_date, $
                         end_date=end_date, $
                         instrument=instrument, $
                         base_url=base_url, $
                         api_version=api_version, $
                         url_object=url_object

Retrieve information about the data available for a given dataset and product
from the ``/datasets/{dataset}/products/{product}`` endpoint.

Returns
"""""""

array of structures with fields "date_obs", "date_end", "instrument", "type",
"quadrant", and "comment"

Params
""""""

:dataset: ``in, required, type=string`` dataset ID to retrieve date for
:product: ``in, required, type=string`` product ID for instrument to retrieve data for

Keywords
""""""""

:n_data: ``out, optional, type=long`` set to a named variable to retrieve the number of files
:start_date: ``in, optional, type=string`` start date to begin looking for files from
:end_date: ``in, optional, type=string`` end date to end looking for files to
:instrument: ``in, optional, type=string`` filter datasets by instrument observed in
:base_url: ``in, optional, type=string, default="http://api.mlso.ucar.edu"`` base URL for the APIå
:api_version: ``in, optional, type=string, default="v1"``` version of the API to use
:url_object: ``in, optional, type=IDLnetURL object`` existing `IDLnetURL` object if available
