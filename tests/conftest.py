import boa
from script.deploy_merkle import deploy_merkle
import pytest
from src import snek_token
from eth_account import Account
from constants import ANVIL_KEY


@pytest.fixture
def merkle():
    return deploy_merkle()


@pytest.fixture
def token(merkle):
    return snek_token.at(merkle.AIRDROP_TOKEN())


@pytest.fixture
def user():
    account = Account.from_key(ANVIL_KEY)
    with boa.env.prank(account.address):
        yield account
