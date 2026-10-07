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
    Using client version v1.1.0

Instead of having to construct URLs and make the web requests, we can now use
routines provides by the client API. The ``about`` routine now gives information
about the API web server.

.. code-block:: Python

    >>> info = client.about()
    >>> print(f"Using mlsoapi v{info['version']}, see {info['documentation']} for more information.")
    Using mlsoapi v1.1.0, see https://mlso-api-client.readthedocs.io/en/latest/ for more information.

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
            "end-date": "2026-10-03T23:39:55",
            "name": "COSMO K-Coronagraph (KCor)"
        },
        {
            "id": "ucomp",
            "start-date": "2021-07-15T17:31:43",
            "end-date": "2026-09-15T20:41:03",
            "name": "Upgraded Coronal Multi-Polarimeter (UCoMP)"
        }
    ]

Now we are ready to begin making requests from the API. To start, let's find
some basic information about the API server.

The ``instrument_info`` routine gives more detailed information about a given
instrument.

.. code-block:: Python

    >>> info = client.instrument_info("ucomp")
    >>> print(json.dumps(info, indent=4))
    {
        "dates": {
            "end-date": "2026-09-15T20:41:03",
            "start-date": "2021-07-15T17:31:43"
        },
        "description": "The Upgraded Coronal Multi-channel Polarimeter (UCoMP) is a 20-cm aperture Lyot coronagraph with a Stokes polarimeter and a narrow-band electro-optically tuned birefringent filter. It can image the intensity, full Stokes polarization, Doppler shift and line width across coronal emission lines in the visible and near-IR. The UCoMP is an upgrade of the Coronal Multi-channel Polarimeter (CoMP) instrument (Tomczyk, Card, Darnell et al., 2008); see Table 1 for performance comparison. The expanded capabilities of UCoMP provide polarization measurements over a wide range of coronal temperatures and out to greater coronal heights to explore the magneto-thermal structure of the corona in coronal holes, \"quiet\" corona and active regions. The evolution of CMEs from build-up to eruption can be explored and MHD wave observations can be viewed to much greater heights, and over a wide range of coronal conditions. The tunable filter allows UComp to combine the strengths of simultaneous 2-D imaging and high-resolution spectroscopy into a single instrument. UCoMP is located at the Mauna Loa Solar Observatory (MLSO) operated by HAO/NCAR. UCoMP was installed in the spring of 2021, began acquiring data May 26, 2021, and is currently completing commissioning.\nThe UCoMP demonstrates the technology of a large aperture (50 mm) tunable birefringent filter based on Lithium Niobate crystals and is a pathfinder instrument for the Coronal Solar Magnetism Observatory (COSMO) (Tomczyk et al., 2016) large coronagragh (LC). The LC will observe full Stokes polarimetry (intensity, linear and circular polarization) over a comparable wavelength range but with an aperture of 1.5 meters. COSMO consists of the LC, a chromospheric magnetometer (ChroMag) and the white light K-coronagraph (K-Cor). For more information on COSMO science and capabilities please see: Tomczyk et al. 2016 (https://www2.hao.ucar.edu/sites/default/files/2022-03/COSMO_science_objectives_ tomczyk_2016JA022871.pdf)\nBasic properties include field-of-view: 1.03 to 1.95 Rsun, spectral range: 530 to 1083 nm, and spatial resolution: 3 arcsec/pixel.",
        "doi": "https://doi.org/10.26024/g8p7-wy42",
        "landing-page": "https://www2.hao.ucar.edu/mlso/instruments/upgraded-coronal-multi-channel-polarimeter",
        "name": "Upgraded Coronal Multi-Polarimeter (UCoMP)"
    }


The ``products`` routine gives a list of products with basic information.

.. code-block:: Python

    >>> info = client.products("ucomp")["products"]
    >>> print(json.dumps(info, indent=4))
    [
        {
            "description": "mean of level 1 files",
            "id": "mean",
            "name": "Level 1 mean",
            "title": "Level 1 mean"
        },
        {
            "description": "median of level 1 files",
            "id": "median",
            "name": "Level 1 median",
            "title": "Level 1 median"
        },
        {
            "description": "level 2 products",
            "id": "l2",
            "name": "Level 2",
            "title": "Level 2"
        },
        {
            "description": "mean, median, standard deviation of level 2 files",
            "id": "l2average",
            "name": "Level 2 average",
            "title": "Level 2 average"
        },
        {
            "description": "Electron density",
            "id": "density",
            "name": "Density",
            "title": "Density"
        },
        {
            "description": "all products",
            "id": "all",
            "name": "All",
            "title": "All"
        }
    ]

More information about a given product can be found with ``product_info``:

.. code-block:: Python

    >>> info = client.product_info("ucomp", "density")
    >>> print(json.dumps(info, indent=4))
    {
        "description": "Electron density",
        "filters": [
            {
                "description": "date/time [UT] in the format 'YYYY-MM-DD' or 'YYYY-MM-DDTHH:MM:SS'",
                "name": "start-date"
            },
            {
                "description": "date/time [UT] in the format 'YYYY-MM-DD' or 'YYYY-MM-DDTHH:MM:SS'",
                "name": "end-date"
            },
            {
                "description": "Carrington rotation number",
                "name": "cr"
            },
            {
                "description": "return only a single file for every matching time period; the recognized time periods are second, minute, hour, day, week, month, quarter, or year (optionally ending in 's'); this parameter is an integer followed by one of these time periods, e.g., 'every=2hours', 'every=1day', or 'every=12hours'",
                "name": "every"
            }
        ],
        "formats": [
            {
                "description": "Flexible Image Transport System (FITS) files",
                "name": "fits"
            },
            {
                "description": "PNG, GIF files",
                "name": "quicklook"
            }
        ],
        "id": "density",
        "name": "Density",
        "title": "Density"
    }

The ``files`` routine provides a list of files, with URLs to download them, that
match a set of filters.

.. code-block:: Python

    >>> info = client.files(
    ...     "ucomp",
    ...     "l2",
    ...     {"wave-region": "789", "start-date": "2025-03-23", "end-date": "2025-03-25"}
    ... )
    >>> print(json.dumps(info, indent=4))
    {
        "end-date": "2025-03-25",
        "files": [
            {
                "date-obs": "2025-03-23T19:03:36",
                "filename": "20250323.190336.ucomp.789.l2.fts",
                "filesize": 31501440,
                "instrument": "ucomp",
                "obs-plan": "synoptic-original-lines.cbk",
                "product": "l2",
                "url": "http://api.mlso.ucar.edu/v1/download?obsday-id=10136&client=python&instrument=ucomp&filename=20250323.190336.ucomp.789.l2.fts&format=fits",
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
                "url": "http://api.mlso.ucar.edu/v1/download?obsday-id=10137&client=python&instrument=ucomp&filename=20250324.200652.ucomp.789.l2.fts&format=fits",
                "wave-region": "789",
                "wavelengths": 5
            }
        ],
        "instrument": "ucomp",
        "n_files": 2,
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

Retrieve the available datasets with the ``datasets`` function:

.. code-block:: Python

    >>> info = client.datasets()
    >>> print(json.dumps(info, indent=4))
    [
        {
            "id": "events",
            "start-date": "2002-02-27T00:00:00",
            "end-date": "2026-10-02T00:00:00",
            "name": "MLSO events"
        }
    ]

Currently, the only available dataset is the events dataset, the list of events
seen in MLSO data.

Find more information about a dataset with ``dataset_info``:

.. code-block:: Python

    >>> info = client.data_info("events")
    >>> print(json.dumps(info, indent=4))
    {
        "dates": {
            "end-date": "2026-10-02T00:00:00",
            "start-date": "2002-02-27T00:00:00"
        },
        "description": "The event dataset lists the CME, flares, prominence eruptions, filament eruptions, and other significant activity in MLSO observations. Events are found by automated process, observers, and later analysis, but validated and corrected by human analysts.",
        "doi": "",
        "landing-page": "https://mlso.hao.ucar.edu/mlso_solar_activity.php",
        "name": "MLSO events"
    }

Use ``product_info`` with ``dataset=True`` to find detailed information about
a dataset product:

.. code-block:: Python

    >>> info = client.product_info("events", "cme", dataset=True)
    >>> print(json.dumps(info, indent=4))
    {
        "description": "coronal mass ejections (CMEs)",
        "filters": [
            {
                "description": "date/time [UT] in the format 'YYYY-MM-DD' or 'YYYY-MM-DDTHH:MM:SS'",
                "name": "start-date"
            },
            {
                "description": "date/time [UT] in the format 'YYYY-MM-DD' or 'YYYY-MM-DDTHH:MM:SS'",
                "name": "end-date"
            },
            {
                "description": "instrument event as seen in, e.g., 'kcor'",
                "name": "instrument"
            }
        ],
        "formats": [
            {
                "description": "JavaScript Object Notation (JSON)",
                "name": "json"
            }
        ],
        "id": "cme",
        "name": "CME"
    }

Similar to the ``files`` function, use ``data`` to retrieve the data from a
dataset-product combination with a ``filters`` argument with various fields
filtering the needed data:

.. code-block:: Python

    >>> info = client.data("events", "cme", {"start-date": "2026-04-01", "end-date": "2026-04-03"})
    >>> print(json.dumps(info, indent=4))
    {
        "dataset": "events",
        "end-date": "2026-04-03",
        "events": [
            {
                "comment": "A wide, bulb CME with a bright core between PA 295-05.",
                "date-end": "2026-04-02T00:17:00",
                "date-obs": "2026-04-01T22:36:00",
                "instrument": "kcor",
                "quadrant": "N-NW limb",
                "type": "cme"
            }
        ],
        "start-date": "2026-04-01",
        "type": "cme"
    }

Unlike ``files``, there is no need to authenticate or use a registered email to
retrieve data from a dataset.

----------------------
Command-line interface
----------------------

A Unix command-line interface is also provided:

.. code-block:: console

    $ mlsoapi --help
    usage: mlsoapi [-h] [-v] [-u URL] [--local] [--api-version VERSION] [--verbose] [-q]
                   {about,instruments,products,info,files,datasets,data} ...

    MLSO API command line interface (mlso-api-client 1.1.0)

    options:
    -h, --help            show this help message and exit
    -v, --version         show program's version number and exit
    -u, --base-url URL    use given base URL for MLSO API instead of the production URL; default is
                          the production URL at http://api.mlso.ucar.edu
    --local               set base URL for MLSO API to localhost (http://127.0.0.1:5000) instead of
                          the production URL
    --api-version VERSION
                          API version to use; default is v1, the only version currently available
    --verbose             output all queries URLs and JSON responses
    -q, --quiet           surpress informational messages

    Valid subcommands:
      Use 'mlsoapi <subcommand> --help' for more detailed for any of the below subcommands

      {about,instruments,products,info,files,datasets,data}
                            Subcommand description
        about               Information about the MLSO API server
        instruments         MLSO datasets/instruments with data available through the API
        products            Products for a given instrument
        info                More detailed information about an instrument or product
        files               Data files for a given instrument and product
        datasets            List available datasets
        data                List matching events

    This commandline utility provides access to the data available at Mauna Loa Solar Observatory
    through the MLSO API. See the full documentation at https://mlso-api-
    client.readthedocs.io/en/latest/ for more information.

To query for the available instruments and basic metadata about each one, use
the ``instruments`` subcommand:

.. code-block:: console

    $ mlsoapi instruments
    ID       Instrument name                              Dates available
    -------- -------------------------------------------- -----------------------
    kcor     COSMO K-Coronagraph (KCor)                   2013-09-30...2026-10-03
    ucomp    Upgraded Coronal Multi-Polarimeter (UCoMP)   2021-07-15...2026-09-15

To show the product for a given instrument, use the ``products`` subcommand:

.. code-block:: console

    $ mlsoapi products --instrument ucomp
    ID            Name                   Description
    ------------- ---------------------- -------------------------------------------------------
    mean          Level 1 mean           mean of level 1 files
    median        Level 1 median         median of level 1 files
    l2            Level 2                level 2 products
    l2average     Level 2 average        mean, median, standard deviation of level 2 files
    density       Density                Electron density
    all           All                    all products

To list files matching a set of filters, use the ``files`` subcommand. To show
the available filters, use the ``--help`` option:

.. code-block:: console

    usage: mlsoapi files [-h] [-i INSTRUMENT] [-p PRODUCT] [--wave-region WAVE_REGION]
                         [--obs-plan OBS_PLAN] [-s DATE] [-e DATE] [-c CARRINGTON_ROTATION_NUMBER]
                         [--every EVERY] [--event-type TYPE] [-d] [-u USERNAME] [-o OUTPUT_DIR]
                         [-f FORMAT]

    options:
    -h, --help            show this help message and exit
    -i, --instrument INSTRUMENT
                          instrument
    -p, --product PRODUCT
                          product
    --wave-region WAVE_REGION
                          filter by wave region, e.g., "1074", "1079", etc.; only used by some
                          instruments
    --obs-plan OBS_PLAN   filter by observing plan: "synoptic", "waves", or other special program;
                          only used by some instruments
    -s, --start-date DATE
                          return files after this date, e.g., "2026-04-01" or "2026-04-01T22:36:15"
    -e, --end-date DATE   return files before this date, e.g., "2026-04-01" or "2026-04-01T22:36:15"
    -c, --carrington-rotation, --cr CARRINGTON_ROTATION_NUMBER
                          filter by files within the given Carrington Rotation
    --every EVERY         time to choose 1 file from, e.g., "1hr" to return a file from every hour
                          in the time period
    -d, --download        download the filtered files
    -u, --username USERNAME
                          email address already registered at HAO website
                          (https://registration.hao.ucar.edu)
    -o, --output-dir OUTPUT_DIR
                          output directory for downloaded files, will be created if it doesn't exist
    -f, --format FORMAT   filter by file format: "fits" or "quicklook"

For example, to show the UCoMP level 2 files in the 789 nm wave region after
2025-03-23, do:

.. code-block:: console

    $ mlsoapi files --instrument ucomp --product l2 --wave-region 789 --start-date 2025-03-23 \
    > --end-date 2025-03-25
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
    Downloading files... ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% 0:00:08

List the available datasets with the ``datasets`` subcommand:

.. code-block:: console

    $ mlsoapi datasets
    ID       Dataset name                                 Dates available
    -------- -------------------------------------------- -----------------------
    events   MLSO events                                  2002-02-27...2026-10-02

The ``products`` subcommand can display dataset products as well as instrument
products:

.. code-block:: console

    $ mlsoapi products --dataset events
    ID            Name                   Description
    ------------- ---------------------- -------------------------------------------------------
    cavity        Coronal cavity         coronal cavity
    cme           CME                    coronal mass ejections (CMEs)
    jet           Jet                    jet
    loop          Loop                   coronal loop
    surge         Surge                  surge
    all           All                    all event types

Use the ``info`` subcommand to retrieve detailed information about a dataset or
dataset product:

.. code-block:: console

    $ mlsoapi info --dataset events
    Name         : MLSO events
    DOI          :
    Landing page : https://mlso.hao.ucar.edu/mlso_solar_activity.php
    Start date   : 2002-02-27T00:00:00
    End date     : 2026-10-02T00:00:00
    Products     : cavity, cme, jet, loop, surge, all
    Description  : The event dataset lists the CME, flares, promince eruptions, filament eruptions, and
                   other significant activity in MLSO observations. Events are found by automated
                   process, observers, and later analysis, but validated and corrected by human
                   analysts.

or

.. code-block:: console

    $ mlsoapi info --product cme --dataset events
    Name         : CME
    ID           : cme
    Description  : coronal mass ejections (CMEs)
    Filters      : start-date, end-date, instrument
    Formats      : json

Use the ``data`` subcommand to retrieve the data for a given dataset and product,
filtered by `start-date`, `end-date`, or `instrument` where the event was seen.

.. code-block:: console

    $ mlsoapi data --product cme --dataset events --start-date 2026-04-01 --end-date 2026-04-03
    Start date/time       End date/time         Instrument Type    Quadrant   Comment
    --------------------- --------------------- ---------- ------- ---------- --------------------------
    2026-04-01T22:36:00   2026-04-02T00:17:00   kcor       cme     N-NW limb  A  wide, bulb CME with a
                                                                              bright core between PA
                                                                              295-05.

Use the ``help`` option for the ``data`` subcommand to determine the available
filters to narrows the data search:

.. code-block:: console

    $ mlsoapi data --help
    usage: mlsoapi data [-h] [-d DATASET] [-p PRODUCT] [-s DATE] [-e DATE] [-i INSTRUMENT]

    options:
    -h, --help            show this help message and exit
    -d, --dataset DATASET
                          dataset to retrieve, i.e., 'events'
    -p, --product PRODUCT
                          dataset product to return, e.g., "cavity", "cme", "jet", "loop", or
                          "surge"; default to "all"
    -s, --start-date DATE
                          return data after this date, e.g., "2026-04-01" or "2026-04-01T22:36:15"
    -e, --end-date DATE   return data before this date, e.g., "2026-04-01" or "2026-04-01T22:36:15"
    -i, --instrument INSTRUMENT
                          instrument

The ``-1`` option for the `instruments`, `datasets`, and `products` subcommands
can be useful when looping through instruments, datasets, or products:

.. code-block:: sh

    $ for d in $(mlsoapi datasets -1); do \
    >   mlsoapi info --dataset $d; \
    >   for p in $(mlsoapi products -1 --dataset $d); do \
    >     mlsoapi info --dataset $d --product $p; \
    >   done; \
    > done

------------
IDL bindings
------------

``mlsoapi.pro`` (and library routines ``mlso_instruments``, ``mlso_datasets``,
``mlso_products``, ``mlso_files``, ``mlso_download_file``, and ``mlso_data``)
provides convenience routines to avoid the use of low-level libraries dealing
with formulating the URLs in the webservice requests, making the requests,
parsing JSON responses, etc.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Basic interactive command-line usage
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``mlsoapi`` routine provides basic features for interactive use. For
example, it is easy to list information about the instruments and datasets
available such as ID to use in the API, the full name of the instrument/dataset,
and dates of the available data.

.. code-block:: IDL

    IDL> mlsoapi
    ID       Instrument name                              Dates available
    -------- -------------------------------------------- -----------------------
    kcor     COSMO K-Coronagraph (KCor)                   2013-09-30...2026-10-05
    ucomp    Upgraded Coronal Multi-Polarimeter (UCoMP)   2021-07-15...2026-09-15

    ID       Dataset name                                 Dates available
    -------- -------------------------------------------- -----------------------
    events   MLSO events                                  2002-02-27...2026-10-05

To list information about the products available for a particular instrument
such as the product ID, title, and description, simply set the ``INSTRUMENT``
keyword:

.. code-block:: IDL

    IDL> mlsoapi, instrument='ucomp'
    ID            Name                   Description
    ------------- ---------------------- -------------------------------------------------------
    mean          Level 1 mean           mean of level 1 files
    median        Level 1 median         median of level 1 files
    l2            Level 2                level 2 products
    l2average     Level 2 average        mean, median, standard deviation of level 2 files
    density       Density                Electron density
    all           All                    all products

Similarly, setting ``DATASET`` can list the products for a dataset:

.. code-block:: IDL

    IDL> mlsoapi, dataset='events'
    ID            Name                   Description
    ------------- ---------------------- -------------------------------------------------------
    cavity        Coronal cavity         coronal cavity
    cme           CME                    coronal mass ejections (CMEs)
    jet           Jet                    jet
    loop          Loop                   coronal loop
    surge         Surge                  surge
    all           All                    all event types

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

To list data available for a dataset, set ``DATASET``, ``PRODUCT``, and any
filter keywords needed:

.. code-block:: IDL

    IDL> mlsoapi, dataset='events', product='cme', start_date='2026-04-01', end_date='2026-04-03'
    Start time          End time            Instrument Type    Quadrant   Comment
    ------------------- ------------------- ---------- ------- ---------- ------------------------------
    2026-04-01T22:36:00 2026-04-02T00:17:00 kcor       cme     N-NW limb  A  wide, bulb CME with a
                                                                          bright core between PA 295-05.
    ------------------- ------------------- ---------- ------- ---------- ------------------------------
    1 events

There is no need for authenticating with ``USERNAME`` because there is no
downloading files for datasets.

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
       END_DATE        STRING    '2026-10-05T21:11:06'

Similarly, to retrieve information about the available datasets, do:

.. code-block:: IDL

    IDL> datasets_info = mlso_datasets()
    IDL> print, strjoin(datasets_info.id, ', '), format='MLSO datasets: %s'
    MLSO datasets: events

The fields available for each dataset:

.. code-block:: IDL

    IDL> help, datasets_info[0]
    ** Structure <2d004a48>, 4 tags, length=64, data length=64, refs=2:
       ID              STRING    'events'
       NAME            STRING    'MLSO events'
       START_DATE      STRING    '2002-02-27T00:00:00'
       END_DATE        STRING    '2026-10-05T00:00:00'

To retrieve information about the products and files available for UCoMP:

.. code-block:: IDL

    IDL> products_info = mlso_products('ucomp')
    IDL> print, strjoin(products_info.products.id, ', '), format='UCoMP products: %s'
    UCoMP products: l1, mean, median, l2, l2average, density, all
    IDL> help, products_info.products[0]
    ** Structure <2e3e8>, 3 tags, length=48, data length=48, refs=2:
      DESCRIPTION     STRING    'IQUV and backgrounds for various wavelengths'
      ID              STRING    'l1'
      TITLE           STRING    'Level 1'
    IDL> files_info = mlso_files('ucomp', 'l2', wave_region='789', start_date='2025-03-23', end_date='2025-03-25')
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

Similarly for datasets, use the ``IS_DATASET`` keyword for ``mlso_products``
and then ``mlso_data`` to retrieve the data given the dataset and product
names.

.. code-block:: IDL

    IDL> products_info = mlso_products('events', /is_dataset)
    IDL> print, strjoin(products_info.products.id, ', '), format='Events products: %s'
    Events products: cavity, cme, jet, loop, surge, all
    IDL> help, products_info.products[0]
    ** Structure <3a3c388>, 3 tags, length=48, data length=48, refs=2:
       DESCRIPTION     STRING    'coronal cavity'
       ID              STRING    'cavity'
       NAME            STRING    'Coronal cavity'
    IDL> data_info = mlso_data('events', 'cme', start_date='2026-04-01', end_date='2026-04-03')
    IDL> events = data_info.events
    IDL> n_events = n_elements(events)
    IDL> .run
    - for e = 0L, n_events - 1L do begin
    -   print, e + 1, n_events, events[e].date_obs, events[e].date_end, format='%d/%d: %s-%s'
    - endfor
    -
    - end
    1/1: 2026-04-01T22:36:00-2026-04-02T00:17:00

There is no download, and hence no authentication, necessary for datasets.
