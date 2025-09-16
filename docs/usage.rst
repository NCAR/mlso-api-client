=====
Usage
=====

The ``mlso.api.client`` module provides convenience routines to avoid the use of
low-level libraries dealing with formulating the URLs in the webservice
requests, making the requests, parsing JSON responses, etc.

.. code-block:: Python

    >>> from mlso.api import client
    >>> print(f"Using client version v{client.__version__}")
    Using client version v0.3.2

Instead of having to construct URLs and make the web requests, we can now use
routines provides by the client API. The ``about`` routine now gives information
about the API web server.

.. code-block:: Python

    >>> info = client.about()
    >>> print(f"Using mlsoapi v{info['version']}, see {info['documentation']} for more information.")
    Using mlsoapi v0.3.1, see https://mlso-api-client.readthedocs.io/en/latest/ for more information.

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
HAO website to download files. Use the `registration page`_ mentioned previously to
register one.

.. _registration page: https://registration.hao.ucar.edu

.. code-block:: Python

    >>> client.authenticate("mgalloy@ucar.edu")
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
