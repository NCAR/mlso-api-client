# mlso-api-client

This package contains Python and IDL clients for accessing MLSO data via the
MLSO data web API.

[![Read the Docs](https://app.readthedocs.org/projects/mlso-api-client/badge/?version=latest)](https://mlso-api-client.readthedocs.io/en/latest/)
[![CircleCI](https://dl.circleci.com/status-badge/img/gh/NCAR/mlso-api-client/tree/main.svg?style=shield)](https://dl.circleci.com/status-badge/redirect/gh/NCAR/mlso-api-client/tree/main)

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

See the [documentation] for help on using the package, including the API
Endpoints, the bindings for Python and IDL, and the command-line interface.

[documentation]: https://mlso-api-client.readthedocs.io/en/latest/index.html
