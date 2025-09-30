#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import pytest

from mlso.api import client


def test_about(base_url, api_version, username):
    about_response = client.about(base_url=base_url, api_version=api_version)


def test_instruments(base_url, api_version, username):
    instruments_response = client.instruments(
        base_url=base_url, api_version=api_version
    )


def test_products(base_url, api_version, username):
    ucomp_products_response = client.products(
        "ucomp", base_url=base_url, api_version=api_version
    )
    ucomp_products = ucomp_products_response["products"]
    assert len(ucomp_products) == 9  # 8 UCoMP products + "all"
    for p in ucomp_products:
        assert "id" in p
        assert "title" in p
        assert "description" in p

    kcor_products_response = client.products(
        "kcor", base_url=base_url, api_version=api_version
    )
    kcor_products = kcor_products_response["products"]
    assert len(kcor_products) == 12  # 11 KCor products + "all"
    for p in kcor_products:
        assert "id" in p
        assert "title" in p
        assert "description" in p


def test_files(base_url, api_version, username):
    filters = {
        "wave-region": "789",
        "start-date": "2025-01-01",
        "end-date": "2025-03-25",
    }
    files_response = client.files(
        "ucomp", "l2", filters, base_url=base_url, api_version=api_version
    )
    assert len(files_response["files"]) == 2


def test_download_file(base_url, api_version, username):
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
