from script.make_merkle import DEFAULT_AMOUNT
from eth_account._utils.signing import sign_message_hash
from eth_keys.datatypes import PrivateKey
from eth_utils import to_bytes

PROOF = [
    bytes.fromhex("8ebcc963f0588d1ded1ebd0d349946755f27e95d1917f9427a207d8935e04d4b"),
    bytes.fromhex("e5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576"),
]


def test_user_can_claim(merkle, token, user):
    starting_tokem_balance = token.balanceOf(user.address)

    message_hash = merkle.get_message_hash(user.address, DEFAULT_AMOUNT)
    v, r, s, _ = sign_message_hash(PrivateKey(user.key), message_hash)

    merkle.claim(user.address, DEFAULT_AMOUNT, PROOF, v, to_bytes(r), to_bytes(s))

    ending_tokem_balance = token.balanceOf(user.address)
    assert ending_tokem_balance == starting_tokem_balance + DEFAULT_AMOUNT