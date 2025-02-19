from script.make_merkle import DEFAULT_AMOUNT
from eth_account._utils.signing import sign_message_hash
from eth_keys.datatypes import PrivateKey
from eth_utils import to_bytes

# PROOF = [
#     bytes.fromhex("8ebcc963f0588d1ded1ebd0d349946755f27e95d1917f9427a207d8935e04d4b"),
#     bytes.fromhex("e5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576"),
# ]
PROOF = [
    bytes.fromhex("234e9ac828a90674c84e202cc740a1e27707f6ee40d9f7d7c8d0893d2dff3362"),
    bytes.fromhex("7ab5d5b38f3bc7ad1709df72ba4245e452e2ae92458f1b46ce39d384f4291126"),
    bytes.fromhex("fa202d18492a624961cc60575b54040b20e3a0ad215a59aeaee00cb0dd1ee016"),
]


def test_user_can_claim(merkle, token, user):
    starting_tokem_balance = token.balanceOf(user.address)

    message_hash = merkle.get_message_hash(user.address, DEFAULT_AMOUNT)
    v, r, s, _ = sign_message_hash(PrivateKey(user.key), message_hash)

    merkle.claim(user.address, DEFAULT_AMOUNT, PROOF, v, to_bytes(r), to_bytes(s))

    ending_tokem_balance = token.balanceOf(user.address)
    assert ending_tokem_balance == starting_tokem_balance + DEFAULT_AMOUNT
