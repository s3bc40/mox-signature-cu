# pragma version 0.4.0
"""
@license MIT
@title merkle_airdrop
"""

from snekmate.utils import merkle_proof_verification
from snekmate.utils import eip712_domain_separator as eip712
from snekmate.utils import ecdsa
from ethereum.ercs import IERC20

initializes: eip712

struct AirdropClaim:
    account: address
    amount: uint256

# Immutable
MERKLE_ROOT: public(immutable(bytes32))
AIRDROP_TOKEN: public(immutable(IERC20))


# Constants
PROOF_MAX_LENGTH: constant(uint8) = max_value(uint8) # 255
MESSAGE_TYPE_HASH: constant(bytes32) = keccak256("AirdropClaim(address account,uint256 amount)")
EIP712_NAME: constant(String[20]) = "Merkle Airdrop"
EIP712_VERSION: constant(String[20]) = "1"


# Storage
has_claimed: HashMap[address, bool]

# Events
event Claimed:
    account: indexed(address)
    amount: indexed(uint256)


@deploy
def __init__(_merkle_root: bytes32, _airdrop_token: address):
    eip712.__init__(EIP712_NAME, EIP712_VERSION)
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

    message_hash: bytes32 = self._get_message_hash(account, amount)
    assert self._is_valid_signature(account, message_hash, v, r, s), "merkle_airdrop: Invalid signature"
    
    leaf: bytes32 = keccak256(abi_encode(keccak256(abi_encode(account, amount))))
    assert merkle_proof_verification._verify(merkle_proof, MERKLE_ROOT, leaf), "merkle_airdrop: Invalid proof"

    self.has_claimed[account] = True
    log Claimed(account, amount)

    success: bool = extcall AIRDROP_TOKEN.transfer(account, amount)
    assert success, "merkle_airdrop: Transfer failed"


@view
@external
def get_message_hash(account: address, amount: uint256) -> bytes32:
    return self._get_message_hash(account, amount)


@view
@internal
def _get_message_hash(account: address, amount: uint256) -> bytes32:
    return eip712._hash_typed_data_v4(
        keccak256(abi_encode(MESSAGE_TYPE_HASH, AirdropClaim(account=account, amount=amount))))
    

@internal
def _is_valid_signature(account: address, message_hash: bytes32, v: uint8, r: bytes32, s: bytes32) -> bool:
    v_u: uint256 = convert(v, uint256)
    r_u: uint256 = convert(r, uint256)
    s_u: uint256 = convert(s, uint256)
    actual_signer: address = ecdsa._try_recover_vrs(message_hash, v_u, r_u, s_u)
    return actual_signer == account