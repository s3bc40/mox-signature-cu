# pragma version 0.4.0
"""
@license MIT
@title merkle_airdrop
"""

from snekmate.utils import merkle_proof_verification
from ethereum.ercs import IERC20

# Immutable
MERKLE_ROOT: public(immutable(bytes32))
AIRDROP_TOKEN: public(immutable(IERC20))


# Constants
PROOF_MAX_LENGTH: constant(uint8) = max_value(uint8) # 255


# Storage
has_claimed: HashMap[address, bool]

# Events
event Claimed:
    account: indexed(address)
    amount: indexed(uint256)


@deploy
def __init__(_merkle_root: bytes32, _airdrop_token: address):
    MERKLE_ROOT = _merkle_root
    AIRDROP_TOKEN = IERC20(_airdrop_token)


@external
def claim(
    account: address,
    amount: uint256,
    merkle_proof: DynArray[bytes32, PROOF_MAX_LENGTH], # list of other hashes from the merkle tree  
    v: uint8,
    r: bytes32,
    s: bytes32
):
    """ Allows a user to claim their airdrop. """
    assert not self.has_claimed[account], "merkle_airdrop: Account has already claimed"
    # TODO signature...
    leaf: bytes32 = keccak256(abi_encode(keccak256(abi_encode(account, amount))))
    assert merkle_proof_verification._verify(merkle_proof, MERKLE_ROOT, leaf), "merkle_airdrop: Invalid proof"

    self.has_claimed[account] = True
    log Claimed(account, amount)

    success: bool = extcall AIRDROP_TOKEN.transfer(account, amount)
    assert success, "merkle_airdrop: Transfer failed"
