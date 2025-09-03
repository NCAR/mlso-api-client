#!/usr/bin/env python
# -*- coding: utf-8 -*-

from mlso.api import client


def test_about(base_url, api_version):
    about_response = client.about(base_url=base_url, api_version=api_version)


def test_instruments(base_url, api_version):
    instruments_response = client.instruments(
        base_url=base_url, api_version=api_version
    )


def test_products(base_url, api_version):
    ucomp_products_response = client.products(
        "ucomp", base_url=base_url, api_version=api_version
    )
    ucomp_products = ucomp_products_response["products"]
    assert len(ucomp_products) == 11  # 10 UCoMP products + "all"
    for p in ucomp_products:
        assert "id" in p
        assert "title" in p
        assert "description" in p

    kcor_products_response = client.products(
        "kcor", base_url=base_url, api_version=api_version
    )
    kcor_products = kcor_products_response["products"]
    assert len(kcor_products) == 13  # 12 KCor products + "all"
    for p in kcor_products:
        assert "id" in p
        assert "title" in p
        assert "description" in p


def test_download_file(base_url, api_version):
    pass


def test_download_files(base_url, api_version):
    pass


def test_files(base_url, api_version):
    filters = {
        "wave-region": "789",
        "start-date": "2025-01-01",
        "end-date": "2025-03-25",
    }
    files_response = client.files(
        "ucomp", "l2", filters, base_url=base_url, api_version=api_version
    )
    assert len(files_response["files"]) == 2
