# mlso-api-client

This package contains Python and IDL clients for accessing MLSO data via the
MLSO data web API.

## Installation

### Installing from PyPI

The easiest way to install the MLSO API client is via the released versions on
PyPI. This is the recommended method for most users.

```console
pip install mlso-api-client
```

If you want to upgrade an existing installation, do:

```console
pip install -U mlso-api-client
```


### Installing from source

The source code can be found on the [repo's GitHub page]. Use git or download
a ZIP file with contents of the source.

[repo's GitHub page]: https://github.com/NCAR/mlso-api-client

Once you have the source code, install the Python portion of the package:

```console
cd mlso-api-client
pip install .
```

If you intend to make changes to the code, install the dev requirements and
allow changes to the code to automatically be used:

```console
pip install -e .[dev]
```

For IDL, simply put the `idl/` directory in your `IDL_PATH`.


## Usage

### Command-line interface

Installing the Python package, should install a command-line utility to query
and download MLSO data, the `mlsoapi` script.

```console
$ mlsoapi --help
usage: mlsoapi [-h] [-v] [-u BASE_URL] [--verbose] [-q] {instruments,products,files} ...

MLSO API command line interface (mlso-api-client 1.0.0)

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
```

To determine the instruments with data available via the API, use the
"instruments" sub-command:

```console
$ mlsoapi instruments
ID       Instrument name                              Dates available
-------- -------------------------------------------- -----------------------
kcor     COSMO K-Coronagraph (KCor)                   2013-09-30...2025-03-24
ucomp    Upgraded Coronal Multi-Polarimeter (UCoMP)   2021-07-15...2025-03-24
```

New data for existing and new instruments will be added to the API as possible.
Submit requests via the [Issues].

[Issues]: https://github.com/NCAR/mlso-api-client/issues

Each instrument has various products available:

```console
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
```

### Python API

TODO: example of using the Python API


### IDL API

TODO: example using the IDL routines


### API endpoints

To use the webservice API directly from any language, see the [API Endpoints] wiki
page.

[API Endpoints]: https://github.com/NCAR/mlso-api-client/wiki/API-endpoints
