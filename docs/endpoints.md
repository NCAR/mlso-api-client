# API Endpoints

The endpoints for the MLSO data API are listed and discussed below.

The MLSO data API will be hosted at:

```
http://api.mlso.ucar.edu/
```

There could potentially be multiple API versions, starting with "v1", but currently that is the only API version. So the base URL for any of the following endpoints would be:

```
http://api.mlso.ucar.edu/v1
```

## API version v1

### `HTTP GET /about`

Basic information about the server can be found from the `about` endpoint:

``` shell
$ curl -s "http://api.mlso.ucar.edu/v1/about" | python -m json.tool
{
  "documentation": "https://mlso-api-client.readthedocs.io/en/latest/",
  "homepage": "https://www2.hao.ucar.edu/mlso",
  "support": "mlso_data_requests@ucar.edu",
  "version": "1.0.0"
}
```


### `HTTP GET /instruments`

Use this to list the available instruments. For example, the JSON response for

```
http://api.hao.ucar.edu/v1/instruments
```

would be:

``` shell
$ curl -s "http://api.hao.ucar.edu/v1/instruments" | python -m json.tool
[
    "ucomp",
    "kcor"
]
```

The names listed are the "instrument IDs" that are used in other endpoints to identify instruments. Data from more instruments will be made available in the future.

### `HTTP GET /instruments/<instrument-id>`

Tells you about the instrument corresponding to `instrument-id`. For example, the JSON response for

```
http://api.hao.ucar.edu/v1/instruments/kcor
```

would be:

``` shell
$ curl -sL "http://api.hao.ucar.edu/v1/instruments/kcor" | python -m json.tool
{
    "dates": {
        "end-date": "2025-03-24T21:04:20",
        "start-date": "2013-09-30T18:57:54"
    },
    "doi": "https://doi.org/10.5065/D69G5JV8",
    "landing-page": "https://www2.hao.ucar.edu/mlso/instruments/cosmo-k-coronagraph-k-cor",
    "name": "COSMO K-Coronagraph (KCor)"
}
```

### `HTTP GET /instruments/<instrument-id>/products`

Tells you about the products of the instrument corresponding to `instrument-id`. For example, the JSON response for

```
http://api.hao.ucar.edu/v1/instruments/kcor/products
```

would be:

``` shell
$ curl -sL "http://127.0.0.1:5000/v1/instruments/kcor/products" | python -m json.tool
{
    "products": [
        {"description": "polarized brightness image", "id": "pb", "title": "pB"},
        {"description": "Normalized Radially Graded Filtered image", "id": "nrgf", "title": "NRGF"},
        {"description": "NRGF average image", "id": "nrgfavg", "title": "NRGF avg"},
        {"description": "pB average image", "id": "pbavg", "title": "pB avg"},
        {"description": "daily pB average image", "id": "pbextavg", "title": "pB ext avg"},
        {"description": "NRGF extended average image", "id": "nrgfextavg", "title": "NRGF ext avg"},
        {"description": "enhanced average image", "id": "pbavgenh", "title": "pB avg enh"},
        {"description": "enhanced extended average image", "id": "pbextavgenh", "title": "pB ext avg enh"},
        {"description": "NRGF enhanced average image", "id": "nrgfavgenh", "title": "NRGF avg enh"},
        {"description": "NRGF enhanced extended average image", "id": "nrgfextavgenh", "title": "NRGF ext avg enh"},
        {"description": "pB difference image", "id": "pbdiff", "title": "pB diff"},
        {"description": "NRGF and difference image", "id": "nrgf+diff", "title": "NRGF + pB diff"},
        {"description": "all products", "id": "all", "title": "All"}
    ]
}
```

### `HTTP GET /instruments/<instrument-id>/products/<product-id>`

Returns files of the instrument corresponding to `instrument-id` of product type corresponding to `product-id`. For example, the JSON response for

```
http://api.hao.ucar.edu/v1/instruments/kcor/products/pb?start-date=2025-03-24T21:03:00&end-date=2025-03-24T21:04:00
```

would be:

``` shell
$ curl -sL "http://api.hao.ucar.edu/v1/instruments/kcor/products/pb?start-date=2025-03-24T21:03:00&end-date=2025-03-24T21:04:00" | python -m json.tool
{
    "end-date": "2025-03-24T21:04:00",
    "files": [
        {
            "date-obs": "2025-03-24T21:03:04",
            "filename": "20250324_210304_kcor_l2_pb.fts",
            "filesize": 0,
            "instrument": "kcor",
            "product": "pb",
            "url": "http://127.0.0.1:5000/v1/download?obsday-id=10136&instrument=kcor&filename=20250324_210304_kcor_l2_pb.fts.gz"
        },
        {
            "date-obs": "2025-03-24T21:03:19",
            "filename": "20250324_210319_kcor_l2_pb.fts",
            "filesize": 0,
            "instrument": "kcor",
            "product": "pb",
            "url": "http://127.0.0.1:5000/v1/download?obsday-id=10136&instrument=kcor&filename=20250324_210319_kcor_l2_pb.fts.gz"
        },
        {
            "date-obs": "2025-03-24T21:03:34",
            "filename": "20250324_210334_kcor_l2_pb.fts",
            "filesize": 0,
            "instrument": "kcor",
            "product": "pb",
            "url": "http://127.0.0.1:5000/v1/download?obsday-id=10136&instrument=kcor&filename=20250324_210334_kcor_l2_pb.fts.gz"
        },
        {
            "date-obs": "2025-03-24T21:03:50",
            "filename": "20250324_210350_kcor_l2_pb.fts",
            "filesize": 0,
            "instrument": "kcor",
            "product": "pb",
            "url": "http://127.0.0.1:5000/v1/download?obsday-id=10136&instrument=kcor&filename=20250324_210350_kcor_l2_pb.fts.gz"
        }
    ],
    "instrument": "kcor",
    "product": "pb",
    "start-date": "2025-03-24T21:03:00",
    "total_filesize": 0
}
```

| Parameter | Description |
| --------- | ----------- |
| `start‑date` | Return only files after the "start-date". |
| `end‑date` | Return only files before the "end-date". |
| `cr` | Return only files matching Carrington Rotation number "cr". |
| `every` | Return only a single file for every time period matching "every". The recognized time periods are second, minute, hour, day, week, month, quarter, or year (optionally ending in "s"). This parameter is an integer followed by one of these time periods, e.g., `every=2hours`, `every=1day`, or `every=12hours`. |
| `wave‑region` | Return only files for the given wave region (UCoMP only). |
| `obs‑plan` | Return only files matching the given observing plan, e.g., "waves" or "synoptic" (UCoMP only). |

The valid date formats are: "%Y-%m-%dT%H:%M:%S" or "%Y-%m-%d", e.g., "2025-01-01T10:30:00" or "2025-01-01". All date/times are in UT.

Use the "url" field of the file results to download the given file. You must call the `/authenticate` endpoint with a registered username (email) before downloading, though.

### `HTTP GET /authenticate`

Before downloading a file, you must authenticate with a valid username. If you haven't registered already, go to `https://registration.hao.ucar.edu` first to register your email address (username). Then call the `authenticate` endpoint, for example, with

```
http://api.hao.ucar.edu/v1/authenticate?username=user@domain.com
```

The JSON response for a registered username would be:

``` JSON
{
  "message": "found username user@domain.com"
}
```

Or if the username is not found, the response will be a 404 NOT FOUND with the following JSON response:

``` JSON
{
  "message": "username user@domain.com not found, sign up at https://registration.hao.ucar.edu"
}
```

The response contains a "session" cookie in the header that must be passed back in the download URL GET requests. The cookie should look something like:

```
Set-Cookie: session=FrFClgPOPeNZVR-r44Yn5jVTILVZ-2cfWRh5ilsLbRQ; Expires=Fri, 25 Jul 2025 15:51:18 GMT; HttpOnly; Path=/
```

And you should pass back this cookie in the download URL GET request with a line in the header of the request like:

```
Cookie: session=FrFClgPOPeNZVR-r44Yn5jVTILVZ-2cfWRh5ilsLbRQ
```
