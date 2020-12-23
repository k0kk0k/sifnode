import time

from test_utilities import amount_in_wei, test_integration_dir
from test_utilities import get_shell_output, SIF_ETH, ETHEREUM_ETH, get_sifchain_addr_balance, \
    advance_n_ethereum_blocks, n_wait_blocks, \
    user1_addr, send_ethereum_currency_to_sifchain_addr


def test_chain_rollback():
    print("########## test_chain_rollback")

    get_shell_output(f"{test_integration_dir}/snapshot_ganache_chain.sh")
    user_balance_before_tx = get_sifchain_addr_balance(user1_addr, SIF_ETH)
    send_ethereum_currency_to_sifchain_addr(user1_addr, ETHEREUM_ETH, amount_in_wei(1))

    advance_n_ethereum_blocks(n_wait_blocks / 2)

    # what we really want is to know that ebrelayer has done nothing,
    # but it's not clear how to get that, so we just wait a bit
    time.sleep(6)

    user_balance_before_required_wait = get_sifchain_addr_balance(user1_addr, SIF_ETH)

    print(f"Starting balance {user_balance_before_tx}, current balance {user_balance_before_required_wait} should be equal")


test_chain_rollback()