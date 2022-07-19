%lang starknet
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.default_dict import default_dict_new, default_dict_finalize
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.dict import dict_write, dict_read
from contracts.twap.twap import (
    get_ticks_array,
    update_historical_ticks,
    get_historical_prices_len,
    twap,
    get_tick_at_index,
)
from starkware.cairo.common.cairo_builtins import HashBuiltin

const EMPIRIC_ORACLE_ADDRESS = 0x012fadd18ec1a23a160cc46981400160fbf4a7a5eed156c4669e39807265bcd4
const KEY = 28556963469423460  # str_to_felt("eth/usd")
const AGGREGATION_MODE = 120282243752302  # str_to_felt("median")
# Test tailored for MAX_TICKS=5

@external
func test_historical_ticks_updates_ticks_len{
    syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*
}():
    let (len) = get_historical_prices_len()
    assert len = 0

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1100,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    let (len) = get_historical_prices_len()
    assert len = 1
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1200,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    let (len) = get_historical_prices_len()

    assert len = 2

    # let res = test_array_sum()
    # %{ print(ids.res) %}
    # assert 1 = 1
    return ()
end

@external
func test_historical_ticks_updates_ticks_array{
    syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*
}():
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1100,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1200,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    let (_, ticks_array) = get_ticks_array()
    assert ticks_array[0].p = 1100
    assert ticks_array[1].p = 1200
    return ()
end

@external
func test_storage_map_doesnt_go_outside_max_ticks{
    syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*
}():
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1100,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1200,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1300,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1400,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1500,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1600,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1700,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1800,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1900,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[2000,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    let (p, t) = get_tick_at_index(5)
    assert p = 0
    assert t = 0
    let (p, t) = get_tick_at_index(6)
    assert p = 0
    assert t = 0

    return ()
end
@external
func test_larger_than_window_historical_ticks_update{
    syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*
}():
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1100,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1200,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1300,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1400,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1500,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1600,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1700,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1800,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1900,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[2000,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}

    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[2100,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    let (_, ticks_array) = get_ticks_array()

    let a0 = ticks_array[0].p
    let a1 = ticks_array[1].p
    let a2 = ticks_array[2].p
    let a3 = ticks_array[3].p
    let a4 = ticks_array[4].p
    %{ print(ids.a0, ids.a1, ids.a2, ids.a3, ids.a4) %}
    assert ticks_array[4].p = 2100
    assert ticks_array[3].p = 2000
    assert ticks_array[2].p = 1900
    assert ticks_array[1].p = 1800
    assert ticks_array[0].p = 1700

    return ()
end

@external
func test_twap{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}():
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1100,10, 1, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1200,10, 2, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1300,10, 3, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1400,10, 4, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1500,10, 5, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1600,10, 6, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    %{ stop_mock = mock_call(ids.EMPIRIC_ORACLE_ADDRESS,'get_value',[1700,10, 7, 1] ) %}
    update_historical_ticks()
    %{ stop_mock() %}
    let (twap_res) = twap()
    assert twap_res = (1700 + 1600 + 1500 + 1400) / 4
    return ()
end
