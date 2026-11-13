# -*- coding: utf-8 -*-

"""Module defining the Python and command-line client. The programmatic
interface is typically used like::

    >>> from mlso.api import client
    >>> client.about()
    {'documentation': 'https://mlso-api-client.readthedocs.io/en/latest/',
     'homepage': 'https://www2.hao.ucar.edu/mlso',
     'support': 'mlso_data_requests@ucar.edu',
     'version': '1.2.0'}
    >>> client.instruments()
    [{'id': 'events',
      'start-date': '2002-02-27T00:00:00',
      'end-date': '2026-09-14T00:00:00',
      'name': 'MLSO events'},
     {'id': 'kcor',
      'start-date': '2013-09-30T18:57:54',
      'end-date': '2026-09-22T20:07:18',
      'name': 'COSMO K-Coronagraph (KCor)'},
     {'id': 'ucomp',
      'start-date': '2021-07-15T17:31:43',
      'end-date': '2025-03-24T21:03:55',
      'name': 'Upgraded Coronal Multi-Polarimeter (UCoMP)'}]
    >>> client.files("ucomp", "l2", {"start-date": "2025-3-24", "wave-region": "789"})
    {'end-date': '2025-03-24T21:03:55',
     'files': [{'date-obs': '2025-03-24T20:06:52',
       'filename': '20250324.200652.ucomp.789.l2.fts',
       'filesize': 31501440,
       'instrument': 'ucomp',
       'obs-plan': 'synoptic-original-lines.cbk',
       'product': 'l2',
       'url': 'http://127.0.0.1:5000/v1/download?obsday-id=10137&client=python&instrument=ucomp&filename=20250324.200652.ucomp.789.l2.fts&format=fits',
       'wave-region': '789',
       'wavelengths': 5}],
     'instrument': 'ucomp',
     'n_files': 1,
     'product': 'l2',
     'start-date': '2025-3-24',
     'total_filesize': 31501440}

The Unix command-line interface, ``mlsoapi``, is also available and accessed
through the `main` routine in this module.

The command line utility exits with status code 0 for no error, 6 for user not
found when downloading a file, 7 for no connection (timeout, etc.), and
otherwise HTTP status code / 100, e.g., an HTTP 404 would exit with status code
4. So this makes the status codes:

- 0 -> no error
- 1 -> informational message
- 2 -> not used, 0 is a successful call
- 3 -> redirection
- 4 -> client error
- 5 -> server error
- 6 -> user not found
- 7 -> no connection, timeout, etc.
"""

import argparse
import datetime
import json
import logging
import math
import os
from pathlib import Path
from pprint import pformat
import sys
import textwrap
from typing import Iterable, Optional
import urllib3

import requests
from rich.progress import track

from . import __version__

BASE_URL = "http://api.mlso.ucar.edu"
LOCAL_BASE_URL = "http://127.0.0.1:5000"
API_VERSION = "v1"
SIGNUP_URL = "https://registration.hao.ucar.edu"
DOCS = "https://mlso-api-client.readthedocs.io/en/latest/"

# default width of the terminal
DEFAULT_WIDTH = 100

# chunk size for downloading files, 1-10M is probably the most efficient size
# for good speed and reasonable memory usage
CHUNK_SIZE = 1024 * 1024

session = requests.Session()

# setup default logging, users of this library can set this to their own logger
# or modify this one to suit their needs
logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.DEBUG)


# API


class UserNotFound(Exception):
    """Exception raised when a username is not found in the registration database."""

    pass


class ServerError(Exception):
    """Exception raised when there is a problem with the server not returning a
    valid result.

    Parameters
    ----------
    message : str
        Description of the error.
    status_code : int, optional
        HTTP status code of the server response, if any; ``None`` for errors
        such as connection failures where no response was received.
    """

    def __init__(self, message: str, status_code: Optional[int] = None):
        super().__init__(message)
        self.status_code = 700 if status_code is None else status_code


def get_terminal_width() -> int:
    """Retrieve the width of the terminal. Returns ``None`` if not running in an
    environment where the width can be retrieved.
    """
    try:
        columns = os.get_terminal_size().columns
    except OSError as e:
        columns = DEFAULT_WIDTH
    return columns


# Top-level Python API


def about(
    base_url: str = BASE_URL, api_version: str = API_VERSION, verbose: bool = False
):
    """Retrieve basic facts about the MLSO API server, i.e., the results of the
    ``/about`` endpoint. For example::

        >>> client.about()
        {'documentation': 'https://mlso-api-client.readthedocs.io/en/latest/',
        'homepage': 'https://www2.hao.ucar.edu/mlso',
        'support': 'mlso_data_requests@ucar.edu',
        'version': '1.2.0'}

    ``about`` can raise a ``ServerError`` if the server response is not valid.
    """
    url = f"{base_url}/{api_version}/about"
    if verbose:
        logger.debug(f"URL: {url}")

    try:
        r = requests.get(url)
    except requests.exceptions.ConnectionError as e:
        raise ServerError(f"Connection error reaching {url}", r.status_code)

    if not r.ok:
        j = r.json()
        msg = j["message"]
        raise ServerError(
            f"Server response: {r.status_code} {r.reason} ({msg})", r.status_code
        )

    j = r.json()

    if verbose:
        logger.debug(pformat(j))

    return j


def instruments(
    info: bool = True,
    base_url: str = BASE_URL,
    api_version: str = API_VERSION,
    verbose: bool = False,
):
    """Retrieve the list of instruments and, if `info` is `True`, some of their
    properties from the ``/instruments/{instrument}`` endpoint. For example::

        >>> from mlso.api import client
        >>> client.instruments()
        [{'id': 'kcor',
          'start-date': '2013-09-30T18:57:54',
          'end-date': '2026-10-06T19:51:27',
          'name': 'COSMO K-Coronagraph (KCor)'},
         {'id': 'ucomp',
          'start-date': '2021-07-15T17:31:43',
          'end-date': '2026-09-15T20:41:03',
          'name': 'Upgraded Coronal Multi-Polarimeter (UCoMP)'}]

    Or::

        >>> [i["id"] for i in client.instruments()]
        ['kcor', 'ucomp']

    ``instruments`` can raise a ``ServerError`` if there is a problem with the
    web request.
    """
    url = f"{base_url}/{api_version}/instruments"
    if verbose:
        logger.debug(f"URL: {url}")

    try:
        r = requests.get(url)
    except requests.exceptions.ConnectionError as e:
        raise ServerError(f"Connection error reaching {url}", r.status_code)

    if not r.ok:
        raise ServerError(f"Server response: {r.status_code} {r.reason}", r.status_code)

    instruments = r.json()
    if verbose:
        logger.debug(pformat(instruments))

    instruments = sorted(instruments)
    if not info:
        return instruments

    results = []

    for instrument in instruments:
        url = f"{base_url}/{api_version}/instruments/{instrument}/"
        if verbose:
            logger.debug(f"URL: {url}")

        try:
            r = requests.get(url)
        except requests.exceptions.ConnectionError as e:
            raise ServerError(f"Connection error reaching {url}", r.status_code)

        j = r.json()

        if verbose:
            logger.debug(pformat(j))

        dates = j["dates"]
        full_name = j["name"]
        start_date = dates["start-date"]
        end_date = dates["end-date"]

        i = {
            "id": instrument,
            "start-date": start_date,
            "end-date": end_date,
            "name": j["name"],
        }
        results.append(i)

    return results


def instrument_info(
    instrument: str,
    /,
    *,
    base_url: str = BASE_URL,
    api_version: str = API_VERSION,
    verbose: bool = False,
) -> dict:
    """Return info about an instrument's data available through the API."""
    url = f"{base_url}/{api_version}/instruments/{instrument}/"
    if verbose:
        logger.debug(f"URL: {url}")

    try:
        r = requests.get(url)
    except requests.exceptions.ConnectionError as e:
        raise ServerError(f"Connection error reaching {url}", r.status_code)

    j = r.json()

    if verbose:
        logger.debug(pformat(j))

    return j


def datasets(
    info: bool = True,
    base_url: str = BASE_URL,
    api_version: str = API_VERSION,
    verbose: bool = False,
):
    """Retrieve the datasets available, and if ``info`` is ``True`` some
    information about them. For example::

        >>> from mlso.api import client
        >>> client.datasets()
        [{'id': 'events',
          'start-date': '2010-01-02T00:00:00',
          'end-date': '2026-11-13T00:00:00',
          'name': 'MLSO events'}]

    Or::

        >>> [d["id"] for d in client.datasets()]
        ['events']

    ``datasets`` can raise a ``ServerError`` if there is a problem with the
    web request.
    """
    url = f"{base_url}/{api_version}/datasets"
    if verbose:
        logger.debug(f"URL: {url}")

    try:
        r = requests.get(url)
    except requests.exceptions.ConnectionError as e:
        raise ServerError(f"Connection error reaching {url}", r.status_code)

    if not r.ok:
        raise ServerError(f"Server response: {r.status_code} {r.reason}", r.status_code)

    datasets = r.json()
    if verbose:
        logger.debug(pformat(datasets))

    datasets = sorted(datasets)

    if not info:
        return datasets

    results = []

    for dataset in datasets:
        url = f"{base_url}/{api_version}/datasets/{dataset}/"
        if verbose:
            logger.debug(f"URL: {url}")

        try:
            r = requests.get(url)
        except requests.exceptions.ConnectionError as e:
            raise ServerError(f"Connection error reaching {url}", r.status_code)

        j = r.json()

        if verbose:
            logger.debug(pformat(j))

        dates = j["dates"]
        full_name = j["name"]
        start_date = dates["start-date"]
        end_date = dates["end-date"]

        i = {
            "id": dataset,
            "start-date": start_date,
            "end-date": end_date,
            "name": j["name"],
        }
        results.append(i)

    return results


def dataset_info(
    dataset: str,
    /,
    *,
    base_url: str = BASE_URL,
    api_version: str = API_VERSION,
    verbose: bool = False,
) -> dict:
    """Returns info about an dataset's data available through the API, i.e., the
    ``/datasets/<dataset-id>/`` endpoint.

        >>> client.dataset_info("events")
        {'dates': {'end-date': '2026-11-13T00:00:00',
          'start-date': '2010-01-02T00:00:00'},
         'description': 'The event dataset lists the CME, flares, prominence eruptions, filament eruptions, and other significant activity in MLSO observations. Events are found by automated process, observers, and later analysis, but validated and corrected by human analysts.',
         'doi': '',
         'landing-page': 'https://mlso.hao.ucar.edu/mlso_solar_activity.php',
         'name': 'MLSO events'}
    """
    url = f"{base_url}/{api_version}/datasets/{dataset}/"
    if verbose:
        logger.debug(f"URL: {url}")

    try:
        r = requests.get(url)
    except requests.exceptions.ConnectionError as e:
        raise ServerError(f"Connection error reaching {url}", r.status_code)

    j = r.json()

    if verbose:
        logger.debug(pformat(j))

    return j


def products(
    instrument,
    dataset: bool = False,
    base_url: str = BASE_URL,
    api_version: str = API_VERSION,
    verbose: bool = False,
):
    """Retrieve the available products for the given instruments, i.e.,
    retreive the results of the ``/instruments/{instrument}/products`` endpoint.
    For example::

        >>> from mlso.api import client
        >>> client.products("ucomp")
        {'products': [{'description': 'IQUV and backgrounds for various wavelengths',
        'id': 'l1',
        'title': 'Level 1'},
        {'description': 'mean of level 1 files',
        'id': 'mean',
        'title': 'Level 1 mean'},
        {'description': 'median of level 1 files',
        'id': 'median',
        'title': 'Level 1 median'},
        {'description': 'level 2 products', 'id': 'l2', 'title': 'Level 2'},
        {'description': 'mean, median, standard deviation of level 2 files',
        'id': 'l2average',
        'title': 'Level 2 average'},
        {'description': 'electron density', 'id': 'density', 'title': 'Density'},
        {'description': 'all products', 'id': 'all', 'title': 'All'}]}

    And::

        >>> [p["id"] for p in client.products("ucomp", base_url=base_url)["products"]]
        ['l1',
        'mean',
        'median',
        'l2',
        'l2average',
        'density',
        'all']

    ``products`` can raise a ``ServerError`` if there is a problem with the web
    request.
    """
    type_name = "datasets" if dataset else "instruments"
    url = f"{base_url}/{api_version}/{type_name}/{instrument}/products"
    if verbose:
        logger.debug(f"URL: {url}")

    try:
        r = requests.get(url)
    except requests.exceptions.ConnectionError as e:
        raise ServerError(f"Connection error reaching {url}")

    if not r.ok:
        try:
            j = r.json()
        except json.decoder.JSONDecodeError as e:
            j = {"message": r.text}
        if verbose:
            msg = f'({j["message"]})'
        else:
            msg = ""
        raise ServerError(
            f"Server response: {r.status_code} {r.reason} {msg}", r.status_code
        )

    j = r.json()

    if verbose:
        logger.debug(pformat(j))

    return j


def product_info(
    instrument: str,
    product: str,
    /,
    *,
    dataset: bool = False,
    base_url: str = BASE_URL,
    api_version: str = API_VERSION,
    verbose: bool = False,
) -> dict:
    """Return info about the data of a given product of instrument available
    through the API."""
    type_name = "datasets" if dataset else "instruments"
    url = f"{base_url}/{api_version}/{type_name}/{instrument}/products/{product}"
    if verbose:
        logger.debug(f"URL: {url}")

    try:
        r = requests.get(url)
    except requests.exceptions.ConnectionError as e:
        raise ServerError(f"Connection error reaching {url}")

    if not r.ok:
        try:
            j = r.json()
        except json.decoder.JSONDecodeError as e:
            j = {"message": r.text}
        if verbose:
            msg = f'({j["message"]})'
        else:
            msg = ""
        raise ServerError(
            f"Server response: {r.status_code} {r.reason} {msg}", r.status_code
        )

    j = r.json()

    if verbose:
        logger.debug(pformat(j))

    return j


def authenticate(
    username: str | None = None,
    base_url: str = BASE_URL,
    api_version: str = API_VERSION,
    verbose: bool = False,
):
    """Authenticate username within the session. The username is registered
    with the `MLSO website`_ first. Then `authenticate` must be called before
    calling ``download_file``. For example::

        >>> client.authenticate(my_email_address)

    You only need to call ``authenticate`` once *per session*.

    This routine can raise a ``UserNotFound`` exception if the ``username`` has
    not already been registered with the MLSO website or a ``ServerError``
    exception if there is a problem with the web request.

    .. _MLSO website: https://registration.hao.ucar.edu
    """
    if username is None:
        msg = f"username required, sign up at {SIGNUP_URL}"
        raise UserNotFound(msg)
    else:
        url = f"{base_url}/{api_version}/authenticate?username={username}"
        if verbose:
            logger.debug(pformat(f"URL: {url}"))
        try:
            r = session.get(url)
        except requests.exceptions.ConnectionError as e:
            raise ServerError(f"Connection error reaching {url}")

        if not r.ok:
            if r.status_code == 404:
                info = r.json()
                if verbose:
                    logger.debug(pformat(info))
                raise UserNotFound(info["message"])
            else:
                j = r.json()
                msg = j["message"]
                raise ServerError(
                    f"Server response: {r.status_code} {r.reason} ({msg})",
                    r.status_code,
                )


def download_file(
    file: dict, output_dir: Path | str = Path("."), use_cache: bool = False
) -> Path:
    """Download a single file to the given output directory. The ``file``
    argument is a dict with at least fields "url" and "filename". ``output_dir``
    is simply the directory to put the downloaded file. Return a pathlib.Path of
    the downloaded file.

        >>> from mlso.api import client
        >>> client.authenticate(my_email_address)
        >>> filters = {"start-date": "2025-3-24", "wave-region": "789"}
        >>> files_info = client.files("ucomp", "l2", filters=filters)
        >>> for f in files_info["files"]:
        ...     download_file(f, ".")

    Can raise ``ServerError`` if there is a problem with the web request.
    """
    url = file["url"]
    path = Path(output_dir) / file["filename"]

    # don't download if the file is already present and `use_cache` set
    if use_cache and os.path.exists(path):
        return path

    try:
        cookies = {k: v for k, v in session.cookies.get_dict().items() if v is not None}
        r = session.get(url, stream=True, cookies=cookies)
    except requests.exceptions.ConnectionError as e:
        raise ServerError(f"Connection error reaching {url}")

    if not r.ok:
        raise ServerError(
            f"Server response: {r.status_code} {r.reason} for {url}", r.status_code
        )

    with open(path, "wb") as handle:
        try:
            for data in r.iter_content(chunk_size=CHUNK_SIZE):
                handle.write(data)
        except urllib3.exceptions.ProtocolError as e:
            raise ServerError(
                f"Bad connection error (ProtocolError) for {url}", r.status_code
            )
        except urllib3.exceptions.IncompleteRead as e:
            raise ServerError(
                f"Bad connection error (IncompleteRead) for {url}", r.status_code
            )
        except requests.exceptions.ChunkedEncodingError as e:
            raise ServerError(
                f"Bad connection error (ChunkedEncodingError) for {url}", r.status_code
            )
    return path


def files(
    instrument: str,
    product: str,
    filters: dict[str, str] | None = None,
    /,
    *,
    base_url: str | None = BASE_URL,
    api_version: str | None = API_VERSION,
    verbose: bool = False,
    client: str | None = "python",
    page: int = 0,
):
    """Retrieve metadata about files from a given instrument/product and
    filtered by various optional filters, i.e., handle retrieving the results
    of the ``/instruments/{instrument}/products/{product}`` endpoint. For
    example::

        >>> from mlso.api import client
        >>> client.files("ucomp", "l2", filters={"start-date": "2025-3-24", "wave-region": "789"})
        {'end-date': '2026-09-16T00:01:03',
         'files': [{'date-obs': '2025-03-24T20:06:52',
           'filename': '20250324.200652.ucomp.789.l2.fts',
           'filesize': 31501440,
           'instrument': 'ucomp',
           'obs-plan': 'synoptic-original-lines.cbk',
           'product': 'l2',
           'url': 'http://127.0.0.1:5000/v1/download?obsday-id=10137&client=python&instrument=ucomp&filename=20250324.200652.ucomp.789.l2.fts',
           'wave-region': '789',
           'wavelengths': 5}],
         'instrument': 'ucomp',
         'n_files': 1,
         'product': 'l2',
         'start-date': '2025-3-24',
         'total_filesize': 31501440}

    Use ``download_file`` to download the file(s) returned with this routine.

    The available filters are listed below. Note that some filters are available
    only for certain instruments.

    =============== ===========================================================
    *Parameter*     *Description*
    =============== ===========================================================
    ``start‑date``  Return only files after the "start-date".
    ``end‑date``    Return only files before the "end-date".
    ``cr``          Return only files matching Carrington Rotation number "cr".
    ``every``       Return only a single file for every time period matching
                    "every". The recognized time periods are:

                    - second,
                    - minute,
                    - hour,
                    - day,
                    - week,
                    - month,
                    - quarter, or
                    - year

                    (optionally ending in "s"). This parameter is an integer
                    followed by one of these time periods, e.g.,

                    - ``every=2hours``,
                    - ``every=1day``, or
                    - ``every=12hours``.
    ``event``       Return only files that occur during events of the given
                    type, currently only "cavity", "cme", "jet", "loop", or
                    "surge".
    ``wave‑region`` Return only files for the given wave region (UCoMP only).
                    Valid values are "637", "706", "789", 1074", "1079".
    ``obs‑plan``    Return only files matching the given observing plan, e.g.:

                    - "waves"
                    - "synoptic"

                    (UCoMP only).
    =============== ===========================================================

    Can raise a ``ServerError`` if there is a problem with the web request.
    """
    url = f"{base_url}/{api_version}/instruments/{instrument}/products/{product}/files"

    if filters is not None and len(filters) > 0:
        url += (
            "?"
            + "&".join([f"{f}={filters[f]}" for f in filters])
            + f"&client={client}&page={page}"
        )
    else:
        url += f"?client={client}&page={page}"

    if verbose:
        logger.debug(f"URL: {url}")

    try:
        r = requests.get(url)
    except requests.exceptions.ConnectionError as e:
        raise ServerError(f"Connection error reaching {url}")

    if not r.ok:
        j = r.json()
        msg = j["message"]
        raise ServerError(
            f"Server response: {r.status_code} {r.reason} ({msg})", r.status_code
        )

    j = r.json()
    if verbose:
        logger.debug(pformat(j))

    return j


def data(
    dataset_id: str,
    product_id: str,
    filters: dict[str, str] | None = None,
    /,
    *,
    base_url: str | None = BASE_URL,
    api_version: str | None = API_VERSION,
    verbose: bool = False,
    client: str | None = "python",
    page: int = 0,
):
    """Retrieve metadata about data from a given dataset and
    filtered by various optional filters, i.e., handle retrieving the results
    of the ``/datasets/{dataset}/products/{type_id}`` endpoint. For
    example::

        >>> from mlso.api import client
        >>> client.data("events", "cme", {"start-date": "2026-04-01", "end-date": "2026-04-03"})
        {'dataset': 'events',
         'end-date': '2026-04-03',
         'events': [{'comment': 'A  wide, bulb CME with a bright core between PA 295-05.',
           'date-end': '2026-04-02T00:17:00',
           'date-obs': '2026-04-01T22:36:00',
           'instrument': 'kcor',
           'quadrant': 'N-NW limb',
           'type': 'cme'}],
         'n_events': 1,
         'page': 0,
         'results_per_page': 5000,
         'start-date': '2026-04-01',
         'type': 'cme'}

    =============== ===========================================================
    *Parameter*     *Description*
    =============== ===========================================================
    ``start‑date``  Return only events after the "start-date".
    ``end‑date``    Return only events before the "end-date".
    ``instrument``  Return only events that are seen in the data from the given
                    instrument.
    =============== ===========================================================

    Can raise a ``ServerError`` if there is a problem with the web request.
    """
    url = f"{base_url}/{api_version}/datasets/{dataset_id}/products/{product_id}/data"

    if filters is not None and len(filters) > 0:
        url += (
            "?"
            + "&".join([f"{f}={filters[f]}" for f in filters])
            + f"&client={client}&page={page}"
        )
    else:
        url += f"?client={client}&page={page}"

    if verbose:
        logger.debug(f"URL: {url}")

    try:
        r = requests.get(url)
    except requests.exceptions.ConnectionError as e:
        raise ServerError(f"Connection error reaching {url}")

    if not r.ok:
        j = r.json()
        msg = j["message"]
        raise ServerError(
            f"Server response: {r.status_code} {r.reason} ({msg})", r.status_code
        )

    j = r.json()
    if verbose:
        logger.debug(pformat(j))

    return j


# Command line interface subcommand handlers


def _about(args: argparse.Namespace):
    """Handle printing the ``/about`` endpoint results for the command line
    interface.
    """
    base_url = LOCAL_BASE_URL if args.local else args.base_url
    try:
        about_response = about(
            base_url, api_version=args.api_version, verbose=args.verbose
        )
        server_version = about_response["version"]
        documentation_url = about_response["documentation"]
        print(f"server version: {server_version}, client version: {__version__}")
        print(f"documentation: {documentation_url}")
    except ServerError as e:
        print(e)
        sys.exit(e.status_code // 100)


def _instruments(args: argparse.Namespace):
    """Handle printing the ``/instruments`` endpoint results for the command line
    interface.
    """
    base_url = LOCAL_BASE_URL if args.local else args.base_url
    info = not vars(args)["1"]
    try:
        instruments_response = instruments(
            info=info,
            base_url=base_url,
            api_version=args.api_version,
            verbose=args.verbose,
        )
    except ServerError as e:
        print(e)
        sys.exit(e.status_code // 100)

    if not info:
        print(" ".join(instruments_response))
    else:
        print(f"{'ID':8s} {'Instrument name':44s} Dates available")
        print(f"{'-' * 8} {'-' * 44} {'-' * 23}")
        for i in instruments_response:
            instrument = i["id"]
            instrument_name = i["name"]
            start_date = i["start-date"][:10]
            end_date = i["end-date"][:10]

            print(f"{instrument:8s} {instrument_name:44s} {start_date}...{end_date}")


def _datasets(args: argparse.Namespace):
    """Handle printing the ``/datasets`` endpoint results for the command line
    interface.
    """
    base_url = LOCAL_BASE_URL if args.local else args.base_url
    info = not vars(args)["1"]
    try:
        datasets_response = datasets(
            info=info,
            base_url=base_url,
            api_version=args.api_version,
            verbose=args.verbose,
        )
    except ServerError as e:
        print(e)
        sys.exit(e.status_code // 100)

    if not info:
        print(" ".join(datasets_response))
    else:
        print(f"{'ID':8s} {'Dataset name':44s} Dates available")
        print(f"{'-' * 8} {'-' * 44} {'-' * 23}")
        for i in datasets_response:
            dataset = i["id"]
            dataset_name = i["name"]
            start_date = i["start-date"][:10]
            end_date = i["end-date"][:10]

            print(f"{dataset:8s} {dataset_name:44s} {start_date}...{end_date}")


def _products(args: argparse.Namespace):
    """Handle printing the ``/instruments/{instrument}/products`` or
    ``/datasets/{dataset}/products`` endpoint for the commandline interface,
    depending on if ``--instrument`` or ``--dataset`` is present.
    """
    base_url = LOCAL_BASE_URL if args.local else args.base_url
    if (args.instrument is not None and args.dataset is not None) or (
        args.instrument is None and args.dataset is None
    ):
        args.parser.error("must specify exactly one of --instrument or --dataset")
    try:
        if args.instrument is not None:
            products_response = products(
                args.instrument,
                base_url=base_url,
                api_version=args.api_version,
                verbose=args.verbose,
            )
        else:
            products_response = products(
                args.dataset,
                dataset=True,
                base_url=base_url,
                api_version=args.api_version,
                verbose=args.verbose,
            )
    except ServerError as e:
        print(e)
        sys.exit(e.status_code // 100)

    if vars(args)["1"]:
        print(" ".join(p["id"] for p in products_response["products"]))
    else:
        print(f"{'ID':13s} {'Name':22s} {'Description'}")
        print(f"{'-' * 13} {'-' * 22} {'-' * 55}")
        for p in products_response["products"]:
            name = p["name"]
            product_id = p["id"]
            description = textwrap.wrap(p["description"], width=55)
            if len(description) == 0:
                description = [""]
            for description_line in description:
                print(f"{product_id:13s} {name:22s} {description_line}")
                product_id = ""
                title = ""
                name = ""


def _info(args):
    """Handle printing the ``/instruments/{instrument}/products/{product}``
    endpoint results for the command line interface.
    """
    n_columns = get_terminal_width()

    base_url = LOCAL_BASE_URL if args.local else args.base_url
    try:
        if args.product is not None:
            info = product_info(
                args.instrument if args.instrument is not None else args.dataset,
                args.product,
                dataset=args.dataset is not None,
                base_url=base_url,
                api_version=args.api_version,
                verbose=args.verbose,
            )
            key_width = 12
            print(f"{'Name':{key_width}s} : {info['name']}")
            print(f"{'ID':{key_width}s} : {info['id']}")
            print(f"{'Description':{key_width}s} : {info['description']}")
            filters_list = ", ".join([f["name"] for f in info["filters"]])
            formats_list = ", ".join([f["name"] for f in info["formats"]])
            print(f"{'Filters':{key_width}s} : {filters_list}")
            print(f"{'Formats':{key_width}s} : {formats_list}")
        else:
            if args.instrument is not None:
                info = instrument_info(
                    args.instrument,
                    base_url=base_url,
                    api_version=args.api_version,
                    verbose=args.verbose,
                )
                products_info = products(
                    args.instrument,
                    base_url=base_url,
                    api_version=args.api_version,
                    verbose=args.verbose,
                )
            else:
                info = dataset_info(
                    args.dataset,
                    base_url=base_url,
                    api_version=args.api_version,
                    verbose=args.verbose,
                )
                products_info = products(
                    args.dataset,
                    dataset=True,
                    base_url=base_url,
                    api_version=args.api_version,
                    verbose=args.verbose,
                )
            key_width = 12
            value_width = n_columns - key_width - 3

            indent = (key_width + 3) * " "
            description = "\n\n".join(
                [
                    "\n".join(
                        textwrap.wrap(
                            p,
                            width=n_columns,
                            initial_indent=(
                                f"{'Description':{key_width}s} : " if i == 0 else indent
                            ),
                            subsequent_indent=indent,
                        )
                    )
                    for i, p in enumerate(info["description"].splitlines())
                ]
            )
            print(f"{'Name':{key_width}s} : {info['name']}")
            print(f"{'DOI':{key_width}s} : {info['doi']}")
            print(f"{'Landing page':{key_width}s} : {info['landing-page']}")
            print(f"{'Start date':{key_width}s} : {info['dates']['start-date']}")
            print(f"{'End date':{key_width}s} : {info['dates']['end-date']}")
            products_list = ", ".join([p["id"] for p in products_info["products"]])
            print(f"{'Products':{key_width}s} : {products_list}")
            print(description)
    except ServerError as e:
        print(e)
        sys.exit(e.status_code // 100)


def _download_files(
    filelist: list[dict],
    format_name: str,
    base_url: str,
    api_version: str,
    output_dir: Path,
    username: str,
    verbose: bool = False,
    quiet: bool = False,
    force: bool = False,
):
    """Download the given files to an output directory. The ``filelist`` argument
    is a list of dicts with fields "url" and "filename".
    """
    if not output_dir.is_dir():
        if verbose:
            logger.debug(f"creating output path {output_dir}")
        os.makedirs(output_dir)

    if format_name == "fits":
        try:
            authenticate(
                username, base_url=base_url, api_version=api_version, verbose=verbose
            )
        except UserNotFound as e:
            print(e)
            sys.exit(6)
        except ServerError as e:
            print(e)
            sys.exit(e.status_code // 100)

    iterable_files: Iterable[dict]
    if quiet:
        iterable_files = filelist
        message = print
    else:
        iterable_files = track(filelist, description="Downloading files...")
        message = print

    n_failed = 0
    for f in iterable_files:
        try:
            filepath = download_file(f, output_dir, use_cache=not force)
        except ServerError as e:
            message(f"download failed: {e}")
            n_failed += 1

    if n_failed > 0:
        print(f"{n_failed} failed downloads")


unit_list = list(zip(["B", "KB", "MB", "GB", "TB", "PB"], [0, 0, 1, 2, 2, 2]))


def _sizeof_fmt(n_bytes: int) -> str:
    """Human friendly file size"""
    if n_bytes == 0:
        return "0 B"
    exponent = min(int(math.log(n_bytes, 1024)), len(unit_list) - 1)
    quotient = float(n_bytes) / 1024**exponent
    unit, num_decimals = unit_list[exponent]
    format_string = "{:.%sf} {}" % (num_decimals)
    return format_string.format(quotient, unit)


def _files_csv(filelist: list[dict], page: int = 0, verbose: bool = False):
    """Output files list to stdout in CSV format."""
    for f in filelist:
        instrument = f["instrument"]
        product_name = f["product"]
        filename = f["filename"]
        date_obs = f["date-obs"]
        filesize = _sizeof_fmt(f["filesize"]) if instrument != "events" else ""
        print(f"{date_obs},{instrument},{product_name},{filesize},{filename}")


def _files_columns(filelist: list[dict], page: int = 0, verbose: bool = False):
    """Output files list to stdout in columns format, e.g., just a table with
    fixed width columns.
    """
    n_columns = get_terminal_width()

    datetime_width = 21
    instrument_width = 10
    max_productname_width = 15
    filesize_width = 10
    max_filename_width = (
        n_columns
        - datetime_width
        - 1
        - instrument_width
        - 1
        - max_productname_width
        - 1
        - filesize_width
        - 1
    )

    product_sep = "-" * max_productname_width
    if len(filelist) > 0:
        if verbose:
            logger.debug("")
        print(
            f"{'Date/time':{datetime_width}s} {'Instrument':{instrument_width}s} {'Product':{max_productname_width}s} {'Filesize':{filesize_width}s} {'Filename':{max_filename_width}s}"
        )
        print(
            f"{'-' * datetime_width} {'-' * instrument_width} {product_sep} {'-' * filesize_width} {'-' * max_filename_width}"
        )
        total_filesize = 0
    for f in filelist:
        total_filesize += f["filesize"]
        instrument = f["instrument"]
        product_name = f["product"]
        product_name = (
            product_name
            if len(product_name) <= max_productname_width
            else f"{product_name[:max_productname_width-2]}.."
        )
        filename = f["filename"]
        filename = (
            filename
            if len(filename) <= max_filename_width
            else f"{filename[:max_filename_width-2]}.."
        )
        filesize = _sizeof_fmt(f["filesize"]) if instrument != "events" else ""
        print(
            f"{f['date-obs']:{datetime_width}s} {instrument:{instrument_width}s} {product_name:{max_productname_width}s} {filesize:>{filesize_width}s} {filename:{max_filename_width}s}"
        )
    if len(filelist) > 1:
        print(
            f"{'-' * datetime_width} {'-' * instrument_width} {product_sep} {'-' * filesize_width} {'-' * max_filename_width}"
        )
        page_info = f"(page {page})" if page > 0 else ""
        n_files = f"{len(filelist)} files {page_info}"
        files_width = datetime_width + 1 + instrument_width + 1 + max_productname_width
        print(
            f"{n_files:{files_width}s} {_sizeof_fmt(total_filesize):>{filesize_width}s} {''}"
        )


def _files(args: argparse.Namespace):
    """Handle printing the ``/instruments/{instrument}/products/{product}/files``
    endpoint results, optionally downloading the files.
    """
    filters = {}

    base_url = LOCAL_BASE_URL if args.local else args.base_url

    if args.wave_region is not None:
        filters["wave-region"] = args.wave_region

    if args.obs_plan is not None:
        filters["obs-plan"] = args.obs_plan

    if args.start_date is not None:
        filters["start-date"] = args.start_date

    if args.end_date is not None:
        filters["end-date"] = args.end_date

    if args.carrington_rotation is not None:
        filters["cr"] = args.carrington_rotation

    if args.every is not None:
        filters["every"] = args.every

    if args.event_type is not None:
        filters["event"] = args.event_type

    if args.format is not None:
        filters["format"] = args.format

    try:
        files_response = files(
            args.instrument,
            args.product,
            filters,
            base_url=base_url,
            api_version=args.api_version,
            verbose=args.verbose,
            client="cli",
            page=args.page,
        )
    except ServerError as e:
        print(e)
        sys.exit(e.status_code // 100)

    if args.verbose:
        instrument = files_response["instrument"]
        product = files_response["product"]
        start_date = files_response["start-date"]
        end_date = files_response["end-date"]
        filesize = _sizeof_fmt(files_response["total_filesize"])
        print(f"Instrument : {instrument}")
        print(f"Product    : {product}")
        print(f"Start date : {start_date}")
        print(f"End date   : {end_date}")
        print(f"Filesize   : {filesize}")

    filelist = files_response["files"]
    if args.download:
        _download_files(
            filelist,
            args.format,
            base_url,
            args.api_version,
            Path(args.output_dir),
            args.username,
            verbose=args.verbose,
            quiet=args.quiet,
            force=args.force,
        )
    else:
        if args.output_format.lower() == "columns":
            _files_columns(filelist, args.page, args.verbose)
        elif args.output_format.lower() == "csv":
            _files_csv(filelist, args.page, args.verbose)
        else:
            _files_columns(filelist, args.page, args.verbose)


def _eventdata_csv(eventlist: list[dict], page: int = 0, verbose: bool = False):
    """Output files list to stdout in CSV format."""
    for e in eventlist:
        start_date = e["date-obs"]
        end_date = e["date-end"]
        instrument = e["instrument"]
        event_type = e["type"]
        quadrant = e["quadrant"]
        comment = e["comment"]
        # [NOTE]: it is important to not have a space after the commas for the
        # quoted fields, which may have commas inside them, for various
        # CSV-readers to correctly parse them
        print(
            f'{start_date},{end_date},{instrument},{event_type},"{quadrant}","{comment}"'
        )


def _eventdata_columns(eventlist: list[dict], page: int = 0, verbose: bool = False):
    """Output event list to stdout in columns format, e.g., just a table with
    fixed width columns.
    """
    max_eventtype_width = 7
    instrument_width = 10
    n_columns = get_terminal_width()

    date_width = 21
    quadrant_width = 10
    comment_width = max(
        n_columns
        - date_width
        - 1
        - date_width
        - 1
        - instrument_width
        - 1
        - max_eventtype_width
        - 1
        - quadrant_width
        - 1,
        10,
    )

    if len(eventlist) > 0:
        if verbose:
            logger.debug("")
        print(
            f"{'Start date/time':{date_width}s} {'End date/time':{date_width}s} {'Instrument':{instrument_width}} {'Type':{max_eventtype_width}s} {'Quadrant':{quadrant_width}s} {'Comment':{comment_width}s}"
        )
        print(
            f"{'-' * date_width} {'-' * date_width} {'-' * instrument_width} {'-' * max_eventtype_width} {'-' * quadrant_width} {'-' * comment_width}"
        )
    for event in eventlist:
        instrument = event["instrument"]
        event_type = event["type"]
        quadrant = event["quadrant"]
        comments = textwrap.wrap(event["comment"], width=comment_width)
        start_date = event["date-obs"]
        end_date = event["date-end"]
        event_type = (
            event_type
            if len(event_type) <= max_eventtype_width
            else f"{event_type[:max_eventtype_width-2]}.."
        )
        print(
            f"{start_date:{date_width}s} {end_date:{date_width}s} {instrument:{instrument_width}s} {event_type:{max_eventtype_width}s} {quadrant:{quadrant_width}s} {comments[0] if len(comments) > 0 else '':{comment_width}s}"
        )
        for c in comments[1:]:
            print(
                f"{'':{date_width}s} {'':{date_width}s} {'':{instrument_width}s} {'':{max_eventtype_width}s} {'':{quadrant_width}s} {c:{comment_width}s}"
            )
    if len(eventlist) > 1:
        print(
            f"{'-' * date_width} {'-' * date_width} {'-' * instrument_width} {'-' * max_eventtype_width} {'-' * quadrant_width} {'-' * comment_width}"
        )
        page_info = f"(page {page})" if page > 0 else ""
        print(f"{len(eventlist):d} events {page_info}")


def _eventdata(args: argparse.Namespace):
    """Handle printing the ``/datasets/events/products/{event_type}/data``
    endpoint results.
    """
    filters = {}

    base_url = LOCAL_BASE_URL if args.local else args.base_url

    if args.start_date is not None:
        filters["start-date"] = args.start_date

    if args.end_date is not None:
        filters["end-date"] = args.end_date

    if args.instrument is not None:
        filters["instrument"] = args.instrument

    try:
        events_response = data(
            args.dataset,  # replace
            args.product,
            filters,
            base_url=base_url,
            api_version=args.api_version,
            verbose=args.verbose,
            client="cli",
            page=args.page,
        )
    except ServerError as e:
        print(e)
        sys.exit(e.status_code // 100)

    if args.verbose:
        instrument = events_response["instrument"]
        event_type = events_response["type"]
        start_date = events_response["start-date"]
        end_date = events_response["end-date"]
        logger.info(f"Instrument : {instrument}")
        logger.info(f"Event type : {event_type}")
        logger.info(f"Start date : {start_date}")
        logger.info(f"End date   : {end_date}")

    eventlist = events_response["events"]

    if args.output_format.lower() == "columns":
        _eventdata_columns(eventlist, args.page, args.verbose)
    elif args.output_format.lower() == "csv":
        _eventdata_csv(eventlist, args.page, args.verbose)
    else:
        _eventdata_columns(eventlist, args.page, args.verbose)


def _data(args: argparse.Namespace):
    if args.dataset == "events":
        _eventdata(args)


def _print_help(args):
    """Print the usage help for the command-line utility."""
    args.parser.print_help()


def main():
    """Entry point for MLSO API command-line utility.

    ::

        $ mlsoapi --help
        usage: mlsoapi [-h] [-v] [-u URL] [--local] [--api-version VERSION] [--verbose] [-q] [-w WIDTH]
                    {about,instruments,products,info,files,datasets,data} ...

        MLSO API command line interface (mlso-api-client 1.2.0)

        options:
        -h, --help            show this help message and exit
        -v, --version         show program's version number and exit
        -u, --base-url URL    use given base URL for MLSO API instead of the
                              production URL; default is the production URL at
                              http://api.mlso.ucar.edu
        --local               set base URL for MLSO API to localhost
                              (http://127.0.0.1:5000) instead of the production
                              URL
        --api-version VERSION
                              API version to use; default is v1, the only
                              version currently available
        --verbose             output all queries URLs and JSON responses
        -q, --quiet           surpress informational messages
        -w, --width WIDTH     line width to use

        Valid subcommands:
          Use 'mlsoapi <subcommand> --help' for more detailed for any of the
          below subcommands

          {about,instruments,products,info,files,datasets,data}
                                Subcommand description
            about               Information about the MLSO API server
            instruments         MLSO datasets/instruments with data available
                                through the API
            products            Products for a given instrument
            info                More detailed information about an instrument
                                or product
            files               Data files for a given instrument and product
            datasets            List available datasets
            data                List matching events

        This commandline utility provides access to the data available at Mauna
        Loa Solar Observatory through the MLSO API. See the full documentation
        at https://mlso-api-client.readthedocs.io/en/latest/ for more
        information.
    """
    name = f"MLSO API command line interface (mlso-api-client {__version__})"

    epilog = """This commandline utility provides access to the data
    available at Mauna Loa Solar Observatory through the MLSO API. See the full
    documentation at https://mlso-api-client.readthedocs.io/en/latest/ for more
    information.
"""
    parser = argparse.ArgumentParser(description=name, epilog=epilog)

    parser.add_argument("-v", "--version", action="version", version=name)

    # show help if no subcommand given
    parser.set_defaults(func=_print_help, parser=parser)

    parser.add_argument(
        "-u",
        "--base-url",
        metavar="URL",
        help=f"use given base URL for MLSO API instead of the production URL; default is the production URL at {BASE_URL}",
        default=BASE_URL,
    )
    parser.add_argument(
        "--local",
        help=f"set base URL for MLSO API to localhost ({LOCAL_BASE_URL}) instead of the production URL",
        action="store_true",
    )
    parser.add_argument(
        "--api-version",
        metavar="VERSION",
        help=f"API version to use; default is {API_VERSION}, the only version currently available",
        default=API_VERSION,
    )
    parser.add_argument(
        "--verbose",
        help="output all queries URLs and JSON responses",
        action="store_true",
    )
    parser.add_argument(
        "-q", "--quiet", help="surpress informational messages", action="store_true"
    )
    parser.add_argument(
        "-w",
        "--width",
        help="line width to use",
        type=int,
        default=None,
    )

    subparsers = parser.add_subparsers(
        title="Valid subcommands",
        description="Use 'mlsoapi <subcommand> --help' for more detailed for any of the below subcommands",
        help="Subcommand description",
    )

    about_parser = subparsers.add_parser(
        "about", help="Information about the MLSO API server"
    )
    about_parser.set_defaults(func=_about, parser=about_parser)

    instruments_parser = subparsers.add_parser(
        "instruments",
        help="MLSO datasets/instruments with data available through the API",
    )
    instruments_parser.add_argument(
        "-1", help="return only instrument IDs", action="store_true"
    )
    instruments_parser.set_defaults(func=_instruments, parser=instruments_parser)

    products_parser = subparsers.add_parser(
        "products", help="Products for a given instrument"
    )
    products_parser.add_argument("-i", "--instrument", help="instrument", default=None)
    products_parser.add_argument("-d", "--dataset", help="dataset", default=None)
    products_parser.add_argument(
        "-1", help="return only product IDs", action="store_true"
    )
    products_parser.set_defaults(func=_products, parser=products_parser)

    info_parser = subparsers.add_parser(
        "info", help="More detailed information about an instrument or product"
    )
    info_parser.add_argument("-i", "--instrument", help="instrument", default=None)
    info_parser.add_argument("-d", "--dataset", help="dataset", default=None)
    info_parser.add_argument("-p", "--product", help="product", default=None)
    info_parser.set_defaults(func=_info, parser=info_parser)

    files_parser = subparsers.add_parser(
        "files", help="Data files for a given instrument and product"
    )
    files_parser.add_argument("-i", "--instrument", help="instrument", default=None)
    files_parser.add_argument("-p", "--product", help="product", default=None)
    files_parser.add_argument(
        "--wave-region",
        help='filter by wave region, e.g., "1074", "1079", etc.; only used by some instruments',
        default=None,
    )
    files_parser.add_argument(
        "--obs-plan",
        help='filter by observing plan: "synoptic", "waves", or other special program; only used by some instruments',
        default=None,
    )
    files_parser.add_argument(
        "-s",
        "--start-date",
        metavar="DATE",
        help='return files after this date, e.g., "2026-04-01" or "2026-04-01T22:36:15"',
        default=None,
    )
    files_parser.add_argument(
        "-e",
        "--end-date",
        metavar="DATE",
        help='return files before this date, e.g., "2026-04-01" or "2026-04-01T22:36:15"',
        default=None,
    )
    files_parser.add_argument(
        "-c",
        "--carrington-rotation",
        "--cr",
        metavar="CARRINGTON_ROTATION_NUMBER",
        help="filter by files within the given Carrington Rotation",
        default=None,
    )
    files_parser.add_argument(
        "--every",
        help='time to choose 1 file from, e.g., "1hr" to return a file from every hour in the time period',
        default=None,
    )
    files_parser.add_argument(
        "--event-type",
        metavar="TYPE",
        help='event type to search for files within: "cavity", "cme", "jet", "loop", "surge" or "all"',
    )
    files_parser.add_argument(
        "-d", "--download", help="download the filtered files", action="store_true"
    )
    files_parser.add_argument(
        "--force", help="download files even if already present", action="store_true"
    )
    files_parser.add_argument(
        "-u",
        "--username",
        help=f"email address already registered at HAO website ({SIGNUP_URL})",
        default=None,
    )
    files_parser.add_argument(
        "-o",
        "--output-dir",
        help="output directory for downloaded files, will be created if it doesn't exist",
        default=".",
    )
    files_parser.add_argument(
        "-f",
        "--format",
        help='filter by file format: "fits" or "quicklook"',
        default="fits",
    )
    files_parser.add_argument(
        "--output-format",
        help='format to output the results in, e.g., "columns", "csv"',
        default="columns",
    )
    files_parser.add_argument("--page", help="page of results", type=int, default=0)
    files_parser.set_defaults(func=_files, parser=files_parser)

    datasets_parser = subparsers.add_parser("datasets", help="List available datasets")
    datasets_parser.add_argument(
        "-1", help="return only dataset IDs", action="store_true"
    )
    datasets_parser.set_defaults(func=_datasets, parser=datasets_parser)

    data_parser = subparsers.add_parser("data", help="List matching events")
    data_parser.add_argument(
        "-d",
        "--dataset",
        help="dataset to retrieve, i.e., 'events'",
        default="all",
    )
    data_parser.add_argument(
        "-p",
        "--product",
        help='dataset product to return, e.g., "cavity", "cme", "jet", "loop", or "surge"; default to "all"',
        default="all",
    )
    data_parser.add_argument(
        "-s",
        "--start-date",
        metavar="DATE",
        help='return data after this date, e.g., "2026-04-01" or "2026-04-01T22:36:15"',
        default=None,
    )
    data_parser.add_argument(
        "-e",
        "--end-date",
        metavar="DATE",
        help='return data before this date, e.g., "2026-04-01" or "2026-04-01T22:36:15"',
        default=None,
    )
    data_parser.add_argument("-i", "--instrument", help="instrument", default=None)
    data_parser.add_argument(
        "--output-format",
        help='format to output the results in, e.g., "columns", "csv"',
        default="columns",
    )
    data_parser.add_argument("--page", help="page of results", type=int, default=0)
    data_parser.set_defaults(func=_data, parser=data_parser)

    # parse args and call appropriate subcommand
    args = parser.parse_args()

    if args.width is not None:
        global DEFAULT_WIDTH
        DEFAULT_WIDTH = args.width

    # don't print "about" info, if the subcommand is "about" since it would be
    # printed twice in that case
    if args.verbose and args.func != _about:
        _about(args)
        logger.debug("")

    if parser.get_default("func"):
        try:
            args.func(args)
        except KeyboardInterrupt:
            print()
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
