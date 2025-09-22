=====
Usage
=====

---------------
Python bindings
---------------

The ``mlso.api.client`` module provides convenience routines to avoid the use of
low-level libraries dealing with formulating the URLs in the webservice
requests, making the requests, parsing JSON responses, etc.

.. code-block:: Python

    >>> from mlso.api import client
    >>> print(f"Using client version v{client.__version__}")
    Using client version v1.0.0

Instead of having to construct URLs and make the web requests, we can now use
routines provides by the client API. The ``about`` routine now gives information
about the API web server.

.. code-block:: Python

    >>> info = client.about()
    >>> print(f"Using mlsoapi v{info['version']}, see {info['documentation']} for more information.")
    Using mlsoapi v1.0.0, see https://mlso-api-client.readthedocs.io/en/latest/ for more information.

The ``instruments`` routine combines potentially many API calls to give basic
information about all the available instruments.

.. code-block:: Python

    >>> info = client.instruments()
    >>> import json
    >>> print(json.dumps(info, indent=4))
    [
        {
            "id": "kcor",
            "start-date": "2013-09-30T18:57:54",
            "end-date": "2025-03-24T21:04:20",
            "name": "COSMO K-Coronagraph (KCor)"
        },
        {
            "id": "ucomp",
            "start-date": "2021-07-15T17:31:43",
            "end-date": "2025-03-24T21:03:55",
            "name": "Upgraded Coronal Multi-Polarimeter (UCoMP)"
        }
    ]

Now we are ready to begin making requests from the API. To start, let's find
some basic information about the API server.

The ``products`` routine gives a list of products with basic information.

.. code-block:: Python

    >>> info = client.products("ucomp")["products"]
    >>> print(json.dumps(info, indent=4))
    [
        {
            "description": "IQUV and backgrounds for various wavelengths",
            "id": "l1",
            "title": "Level 1"
        },
        {
            "description": "intensity-only level 1",
            "id": "intensity",
            "title": "Level 1 intensity"
        },
        {
            "description": "mean of level 1 files",
            "id": "mean",
            "title": "Level 1 mean"
        },
        {
            "description": "median of level 1 files",
            "id": "median",
            "title": "Level 1 median"
        },
        {
            "description": "standard deviation of level 1 files",
            "id": "sigma",
            "title": "Level 1 sigma"
        },
        {
            "description": "level 2 products",
            "id": "l2",
            "title": "Level 2"
        },
        {
            "description": "mean, median, standard deviation of level 2 files",
            "id": "l2average",
            "title": "Level 2 average"
        },
        {
            "description": "density",
            "id": "density",
            "title": "Density"
        },
        {
            "description": "level 2 dynamics products",
            "id": "dynamics",
            "title": "Dynamics"
        },
        {
            "description": "level 2 polarization products",
            "id": "polarization",
            "title": "Polarization"
        },
        {
            "description": "all products",
            "id": "all",
            "title": "All"
        }
    ]

The ``files`` routine provides a list of files, with URLs to download them, that
match a set of filters.

.. code-block:: Python

    >>> info = client.files("ucomp", "l2", {"wave-region": "789", "start-date": "2025-03-23"})
    >>> print(json.dumps(info, indent=4))
    {
        "end-date": "2025-03-24T21:03:55",
        "files": [
            {
                "date-obs": "2025-03-23T19:03:36",
                "filename": "20250323.190336.ucomp.789.l2.fts",
                "filesize": 31501440,
                "instrument": "ucomp",
                "obs-plan": "synoptic-original-lines.cbk",
                "product": "l2",
                "url": "http://api.mlso.ucar.edu/v1/download?obsday-id=10136&client=python&instrument=ucomp&filename=20250323.190336.ucomp.789.l2.fts",
                "wave-region": "789",
                "wavelengths": 5
            },
            {
                "date-obs": "2025-03-24T20:06:52",
                "filename": "20250324.200652.ucomp.789.l2.fts",
                "filesize": 31501440,
                "instrument": "ucomp",
                "obs-plan": "synoptic-original-lines.cbk",
                "product": "l2",
                "url": "http://api.mlso.ucar.edu/v1/download?obsday-id=10137&client=python&instrument=ucomp&filename=20250324.200652.ucomp.789.l2.fts",
                "wave-region": "789",
                "wavelengths": 5
            }
        ],
        "instrument": "ucomp",
        "product": "l2",
        "start-date": "2025-03-23",
        "total_filesize": 63002880
    }

The files can be downloaded, though the ``authenticate`` routine must be called
before starting to download files. An email address must be registered with the
HAO website to download files. Use the `registration page`_ to register one.

.. _registration page: https://registration.hao.ucar.edu

.. code-block:: Python

    >>> client.authenticate("email@example.com")
    >>> import os
    >>> output_dir = "./data"
    >>> if not os.path.exists(output_dir):
    ...     os.mkdir(output_dir)
    ...
    >>> for file in info["files"]:
    ...     path = client.download_file(file, output_dir)
    ...     print(f"downloaded {file['filename']} to {path}")
    ...
    downloaded 20250323.190336.ucomp.789.l2.fts to data/20250323.190336.ucomp.789.l2.fts
    downloaded 20250324.200652.ucomp.789.l2.fts to data/20250324.200652.ucomp.789.l2.fts

----------------------
Command-line interface
----------------------

A Unix command-line interface is also provided:

.. code-block:: console

    $ mlsoapi --help
    usage: mlsoapi [-h] [-v] [-u BASE_URL] [--verbose] [-q] {instruments,products,files} ...

    MLSO API command line interface (mlso-api-client 0.3.2)

    positional arguments:
    {instruments,products,files}
                            sub-command help
        instruments         MLSO instruments
        products            MLSO instruments
        files               MLSO data files

    options:
    -h, --help            show this help message and exit
    -v, --version         show program's version number and exit
    -u BASE_URL, --base-url BASE_URL
                            base URL for MLSO API
    --verbose             output warnings
    -q, --quiet           surpress informational messages

To query for the available instruments and basic metadata about each one:

.. code-block:: console

    $ mlsoapi instruments
    ID       Instrument name                              Dates available
    -------- -------------------------------------------- -----------------------
    kcor     COSMO K-Coronagraph (KCor)                   2013-09-30...2025-03-24
    ucomp    Upgraded Coronal Multi-Polarimeter (UCoMP)   2021-07-15...2025-03-24

To show the product for a given instrument, use the "products" sub-command:

.. code-block:: console

    $ mlsoapi products --instrument ucomp
    ID            Title                  Description
    ------------- ---------------------- -------------------------------------------------------
    l1            Level 1                IQUV and backgrounds for various wavelengths
    intensity     Level 1 intensity      intensity-only level 1
    mean          Level 1 mean           mean of level 1 files
    median        Level 1 median         median of level 1 files
    sigma         Level 1 sigma          standard deviation of level 1 files
    l2            Level 2                level 2 products
    l2average     Level 2 average        mean, median, standard deviation of level 2 files
    density       Density                density
    dynamics      Dynamics               level 2 dynamics products
    polarization  Polarization           level 2 polarization products
    all           All                    all products

To list files matching a set of filters, use the "files" sub-command. To show
the available filters, use the ``--help`` option:

.. code-block:: console

    $ mlsoapi files --help
    usage: mlsoapi files [-h] [-i INSTRUMENT] [-p PRODUCT] [--wave-region WAVE_REGION]
                        [--obs-plan OBS_PLAN] [-s START_DATE] [-e END_DATE]
                        [-c CARRINGTON_ROTATION] [--every EVERY] [-d] [-u USERNAME]
                        [-o OUTPUT_DIR]

    options:
    -h, --help            show this help message and exit
    -i INSTRUMENT, --instrument INSTRUMENT
                            instrument
    -p PRODUCT, --product PRODUCT
                            product
    --wave-region WAVE_REGION
                            wave region, e.g., 1074, 1079, etc.
    --obs-plan OBS_PLAN   observing plan: synoptic or waves
    -s START_DATE, --start-date START_DATE
                            start date
    -e END_DATE, --end-date END_DATE
                            end date
    -c CARRINGTON_ROTATION, --carrington-rotation CARRINGTON_ROTATION
                            Carrington Rotation number
    --every EVERY         time to choose 1 file from
    -d, --download        download the displayed files
    -u USERNAME, --username USERNAME
                            email already registered at HAO website
    -o OUTPUT_DIR, --output-dir OUTPUT_DIR
                            output directory for downloaded files

For example, to show the UCoMP level 2 files in the 789 nm wave region after
2025-03-23, do:

.. code-block:: console

    $ mlsoapi files --instrument ucomp --product l2 --wave-region 789 --start-date 2025-03-23
    Date/time            Instrument Product       Filesize   Filename
    -------------------- ---------- ------------- ---------- --------------------------------
    2025-03-23T19:03:36  ucomp      l2               30.0 MB 20250323.190336.ucomp.789.l2.fts
    2025-03-24T20:06:52  ucomp      l2               30.0 MB 20250324.200652.ucomp.789.l2.fts
    -------------------- ---------- ------------- ---------- --------------------------------
    2 files                                          60.1 MB

To download the above files, use the ``--download`` option along with a
registered email address as the argument to ``--username``:

.. code-block:: console

    $ mlsoapi files --instrument ucomp --product l2 --wave-region 789 --start-date 2025-03-23 \
    > --download --username email@example.com
    100%|███████████████████████████████████████████████████████████████████████| 2/2 [00:01<00:00,  1.86it/s]


------------
IDL bindings
------------

``mlsoapi.pro`` (and library routines ``mlso_instruments``, ``mlso_products``,
``mlso_files``, and ``mlso_download_file``) provides convenience routines to
avoid the use of low-level libraries dealing with formulating the URLs in the
webservice requests, making the requests, parsing JSON responses, etc.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Basic interactive command-line usage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``mlsoapi`` routine provides basic features for interactive use. For
example, it is easy to list information about the instruments available such as
ID to use in the API, the full name of the instruments, and dates of the
available data.

.. code-block:: IDL

    IDL> mlsoapi
    ID       Instrument name                              Dates available
    -------- -------------------------------------------- -----------------------
    kcor     COSMO K-Coronagraph (KCor)                   2013-09-30...2025-03-24
    ucomp    Upgraded Coronal Multi-Polarimeter (UCoMP)   2021-07-15...2025-03-24

To list information about the products available for a particular instrument
such as the product ID, title, and description, simply set the `INSTRUMENT`
keyword:

.. code-block:: IDL

    IDL> mlsoapi, instrument='ucomp'
    ID            Title                  Description
    ------------- ---------------------- -------------------------------------------------------
    l1            Level 1                IQUV and backgrounds for various wavelengths
    intensity     Level 1 intensity      intensity-only level 1
    mean          Level 1 mean           mean of level 1 files
    median        Level 1 median         median of level 1 files
    sigma         Level 1 sigma          standard deviation of level 1 files
    l2            Level 2                level 2 products
    l2average     Level 2 average        mean, median, standard deviation of level 2 files
    density       Density                density
    dynamics      Dynamics               level 2 dynamics products
    polarization  Polarization           level 2 polarization products
    all           All                    all products

To list the files available for UCoMP instrument's level 2 product with wave
region 789 after 2025-01-1, specify both the ``INSTRUMENT`` and ``PRODUCT``
keywords, along with any other desired filters:

.. code-block:: IDL

    IDL> mlsoapi, instrument='ucomp', product='l2', wave_region='789', start_date='2025-03-23'
    Date/time            Instrument Product       Filesize   Filename
    -------------------- ---------- ------------- ---------- --------------------------------
    2025-03-23T19:03:36  ucomp      l2                30.0 M 20250323.190336.ucomp.789.l2.fts
    2025-03-24T20:06:52  ucomp      l2                30.0 M 20250324.200652.ucomp.789.l2.fts
    -------------------- ---------- ------------- ---------- --------------------------------
    2 files                                           60.1 M


To download the above listed files into the "data" directory set the
``DOWNLOAD`` keyword and specify a username with the ``USERNAME`` keyword. The
email username given here must be registered with the `HAO website`_.

.. _HAO website: https://registration.hao.ucar.edu

.. code-block:: IDL

    IDL> mlsoapi, instrument='ucomp', product='l2', $
    IDL>          wave_region='789', start_date='2025-03-23', $
    IDL>          username='email@example.com', /download, output_dir='data'


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
API for programmatically retrieving results
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is also a set of IDL routines to programmatically make queries and
download data via the API.

For example, to retrieve information about the available instruments, do:

.. code-block:: IDL

    IDL> instruments_info = mlso_instruments()
    IDL> print, strjoin(instruments_info.id, ', '), format='MLSO instruments: %s'
    MLSO instruments: kcor, ucomp

The fields available for each instrument:

.. code-block:: IDL

    IDL> help, instruments_info[0]
    ** Structure <27720578>, 4 tags, length=64, data length=64, refs=2:
       ID              STRING    'kcor'
       NAME            STRING    'COSMO K-Coronagraph (KCor)'
       START_DATE      STRING    '2013-09-30T18:57:54'
       END_DATE        STRING    '2025-03-24T21:04:20'

To retrieve information about the products available for UCoMP:

.. code-block:: IDL

    IDL> products_info = mlso_products('ucomp')
    IDL> print, strjoin(products_info.products.id, ', '), format='UCoMP products: %s'
    UCoMP products: l1, intensity, mean, median, sigma, l2, l2average, density, dynamics, polarization, all
    IDL> help, products_info.products[0]
    ** Structure <2e3e8>, 3 tags, length=48, data length=48, refs=2:
      DESCRIPTION     STRING    'IQUV and backgrounds for various wavelengths'
      ID              STRING    'l1'
      TITLE           STRING    'Level 1'
    IDL> files_info = mlso_files('ucomp', 'l2', wave_region='789', start_date='2025-03-23')
    IDL> files = files_info.files
    IDL> n_files = n_elements(files)
    IDL> .run
    - for f = 0L, n_files - 1L do begin
    -   print, f + 1, n_files, files[f].filename, format='%d/%d: %s'
    -   print, files[f].url, format='     %s'
    - endfor
    -
    - end
    1/2: 20250323.190336.ucomp.789.l2.fts
        http://api.mlso.ucar.edu/v1/download?obsday-id=10136&client=idl&instrument=ucomp&filename=20250323.190336.ucomp.789.l2.fts
    2/2: 20250324.200652.ucomp.789.l2.fts
        http://api.mlso.ucar.edu/v1/download?obsday-id=10137&client=idl&instrument=ucomp&filename=20250324.200652.ucomp.789.l2.fts

To download the above files, use ``MLSO_DOWNLOAD_FILE`` with a registered
username:

.. code-block:: IDL

    IDL> username = 'email@example.com'
    IDL> .run
    - for f = 0L, n_elements(files_info.files) - 1L do begin
    -   file = files_info.files[f]
    -   mlso_download_file, file.filename, file.url, username, output_dir='data'
    - endfor
    -
    - end
