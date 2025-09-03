import pytest

SERVER_URL = "http://api.mlso.ucar.edu:5000"
LOCAL_URL = "http://127.0.0.1:5000"


def pytest_addoption(parser):
    parser.addoption(
        "--local", action="store_true", default=False, help="set to run on localhost"
    )
    parser.addoption(
        "--api-version", type=str, default="v1", help="API version to test"
    )


@pytest.fixture()
def base_url(request):
    return LOCAL_URL if request.config.getoption("--local") else SERVER_URL


@pytest.fixture()
def api_version(request):
    return request.config.getoption("--api-version")
