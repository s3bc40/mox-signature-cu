from src import snek_token, merkle_airdrop
from eth_utils import to_wei
from script.make_merkle import generate_merkle_tree
from moccasin.boa_tools import VyperContract

# INITIAL_SUPPLY = to_wei(100, "ether")
INITIAL_SUPPLY = to_wei(200, "ether")


def deploy_merkle() -> VyperContract:
    token = snek_token.deploy(INITIAL_SUPPLY)
    _, root = generate_merkle_tree()
    airdrop_contract = merkle_airdrop.deploy(root, token.address)
    token.transfer(airdrop_contract.address, INITIAL_SUPPLY)
    print(f"Deployed Merkle Airdrop Contract: {airdrop_contract.address}")
    return airdrop_contract


def moccasin_main() -> VyperContract:
    return deploy_merkle()
