#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import pytest

from mlso.api import client


def test_about(base_url: str, api_version: str, username: str):
    fields = ["documentation", "homepage", "support", "version"]
    about_response = client.about(base_url=base_url, api_version=api_version)
    assert type(about_response) == dict
    for f in fields:
        assert f in about_response


def test_instruments(base_url: str, api_version: str, username: str):
    instruments = ["kcor", "ucomp"]
    instruments_response = client.instruments(
        base_url=base_url, api_version=api_version
    )
    assert type(instruments_response) == list
    assert set(instruments) == set([i["id"] for i in instruments_response])


def test_instrument_info(base_url: str, api_version: str, username: str):
    instruments = ["kcor", "ucomp"]
    fields = ["dates", "doi", "landing-page", "name"]
    for i in instruments:
        info = client.instrument_info(i, base_url=base_url, api_version=api_version)
        assert set(fields) == set(info.keys())


UCOMP_STANDARD_PRODUCTS = ["mean", "median", "l2", "l2average", "density", "all"]


def test_ucomp_products(base_url: str, api_version: str, username: str):
    ucomp_products_response = client.products(
        "ucomp", base_url=base_url, api_version=api_version
    )
    ucomp_products = ucomp_products_response["products"]
    assert len(ucomp_products) == len(UCOMP_STANDARD_PRODUCTS)
    for p in ucomp_products:
        assert "id" in p
        assert "name" in p
        assert "description" in p

    assert set(UCOMP_STANDARD_PRODUCTS) == set([p["id"] for p in ucomp_products])


KCOR_STANDARD_PRODUCTS = [
    "pb",
    "nrgf",
    "pbavg",
    "nrgfavg",
    "pbextavg",
    "nrgfextavg",
    "pbavgenh",
    "pbextavgenh",
    "nrgfavgenh",
    "nrgfextavgenh",
    "pbdiff",
    "nrgf+diff",
    "all",
]


def test_kcor_products(base_url: str, api_version: str, username: str):
    kcor_products_response = client.products(
        "kcor", base_url=base_url, api_version=api_version
    )
    kcor_products = kcor_products_response["products"]
    assert len(kcor_products) == len(KCOR_STANDARD_PRODUCTS)  # 11 KCor products + "all"
    for p in kcor_products:
        assert "id" in p
        assert "name" in p
        assert "description" in p

    assert set(KCOR_STANDARD_PRODUCTS) == set([p["id"] for p in kcor_products])


def test_product_info(base_url: str, api_version: str, username: str):
    instruments = ["kcor", "ucomp"]
    products = {"kcor": KCOR_STANDARD_PRODUCTS, "ucomp": UCOMP_STANDARD_PRODUCTS}
    fields = {"description", "filters", "formats", "id", "name", "title"}
    for i in instruments:
        for p in products[i]:
            product_info = client.product_info(
                i, p, base_url=base_url, api_version=api_version
            )
            assert set(fields) == set(product_info.keys())


def test_files(base_url: str, api_version: str, username: str):
    filters = {
        "wave-region": "789",
        "start-date": "2025-01-01",
        "end-date": "2025-03-25",
    }
    files_response = client.files(
        "ucomp", "l2", filters, base_url=base_url, api_version=api_version
    )
    assert len(files_response["files"]) == 2


def test_download_file(base_url: str, api_version: str, username: str):
    if username is None:
        pytest.skip("specify username to test downloading")

    filters = {
        "wave-region": "789",
        "start-date": "2025-01-01",
        "end-date": "2025-03-25",
    }
    files_response = client.files(
        "ucomp", "l2", filters, base_url=base_url, api_version=api_version
    )
    client.authenticate(username, base_url, api_version=api_version)
    path = client.download_file(files_response["files"][0], ".")
    assert path.exists()
    os.remove(path)


def test_datasets(base_url: str, api_version: str, username: str):
    datasets = ["events"]
    datasets_response = client.datasets(base_url=base_url, api_version=api_version)
    assert type(datasets_response) == list
    assert set(datasets) == set([i["id"] for i in datasets_response])


def test_events_products(base_url: str, api_version: str, username: str):
    events_standard_products = ["cavity", "cme", "jet", "loop", "surge", "all"]
    products_response = client.products(
        "events",
        dataset=True,
        base_url=base_url,
        api_version=api_version,
    )
    events_products = products_response["products"]
    assert len(events_products) == len(events_standard_products)
    for p in events_products:
        assert "id" in p
        assert "name" in p
        assert "description" in p

    assert set(events_standard_products) == set([p["id"] for p in events_products])


def test_data(base_url: str, api_version: str, username: str):
    assert False
