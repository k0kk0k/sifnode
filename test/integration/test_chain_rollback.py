import time

from test_utilities import amount_in_wei, test_integration_dir, wait_for_sifchain_addr_balance, \
    transact_ethereum_currency_to_sifchain_addr, cd_smart_contracts_dir
from test_utilities import get_shell_output, SIF_ETH, ETHEREUM_ETH, get_sifchain_addr_balance, \
    advance_n_ethereum_blocks, n_wait_blocks, \
    user1_addr, send_ethereum_currency_to_sifchain_addr


def ganache_transactions_json():
    transaction_cmd = f"{cd_smart_contracts_dir} npx truffle exec scripts/getIntegrationTestTransactions.js  |" \
                      f" grep 'result:' | sed -e 's/.*result: //'"
    return get_shell_output(transaction_cmd)


def test_chain_rollback():
    print("########## test_chain_rollback")

    amount = amount_in_wei(1)
    print("beforesnapshot", ganache_transactions_json())
    snapshot = get_shell_output(f"{test_integration_dir}/snapshot_ganache_chain.sh")
    print(f"snapshot is {snapshot}")
    user_balance_before_tx = get_sifchain_addr_balance(user1_addr, SIF_ETH)
    print(f"user_balance_before_tx {user_balance_before_tx}")
    send_ethereum_currency_to_sifchain_addr(user1_addr, ETHEREUM_ETH, amount)

    advance_n_ethereum_blocks(n_wait_blocks / 2)

    print("afteradvancinghalf", ganache_transactions_json())

    # the transaction should not have happened on the sifchain side.
    # roll back ganache to the snapshot and try transfer #2, and only
    # transfer #2 should succeed.

    get_shell_output(f"{test_integration_dir}/apply_ganache_snapshot.sh {snapshot} 2>&1")

    print("afterapplysnapshot", ganache_transactions_json())

    print("snapshot applied")

    transact_ethereum_currency_to_sifchain_addr(user1_addr, ETHEREUM_ETH, amount)
    advance_n_ethereum_blocks(n_wait_blocks)

    # TODO we need to wait for ebrelayer directly
    time.sleep(10)
    
    print(f"balance after sleep is {get_sifchain_addr_balance(user1_addr, SIF_ETH)}")
    wait_for_sifchain_addr_balance(user1_addr, SIF_ETH, user_balance_before_tx + amount)

    print("test_chain_rollback complete, balance is correct")


test_chain_rollback()