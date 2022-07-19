%lang starknet
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le, is_not_zero
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin

# Oracle Interface Definition
const EMPIRIC_ORACLE_ADDRESS = 0x012fadd18ec1a23a160cc46981400160fbf4a7a5eed156c4669e39807265bcd4
const KEY = 28556963469423460  # str_to_felt("eth/usd")
const AGGREGATION_MODE = 120282243752302  # str_to_felt("median")
const MAX_TICKS = 5

struct Tick:
    member t : felt
    member p : felt
end

@storage_var
func historical_prices(index : felt) -> (tick : Tick):
end

@storage_var
func historical_prices_len() -> (len : felt):
end
@storage_var
func historical_prices_break() -> (break : felt):
end

@contract_interface
namespace IEmpiricOracle:
    func get_value(key : felt, aggregation_mode : felt) -> (
        value : felt, decimals : felt, last_updated_timestamp : felt, num_sources_aggregated : felt
    ):
    end
end

@view
func get_historical_prices_len{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ) -> (res : felt):
    let (len) = historical_prices_len.read()
    return (res=len)
end
# Your function
@external
func update_historical_ticks{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}(
    ) -> (answer : felt):
    alloc_locals
    let (
        eth_price, decimals, last_updated_timestamp, num_sources_aggregated
    ) = IEmpiricOracle.get_value(EMPIRIC_ORACLE_ADDRESS, KEY, AGGREGATION_MODE)
    let (i) = historical_prices_len.read()
    let (inferior) = is_le(i, MAX_TICKS - 1)
    if inferior == 1:
        local new_tick : Tick
        assert new_tick.t = last_updated_timestamp
        assert new_tick.p = eth_price
        historical_prices.write(index=i, value=new_tick)

        historical_prices_len.write(value=i + 1)
    else:
        local new_tick : Tick
        assert new_tick.t = last_updated_timestamp
        assert new_tick.p = eth_price

        let (b) = historical_prices_break.read()
        let (local before_last_tick : Tick) = historical_prices.read(b + 1)
        historical_prices.write(index=0, value=before_last_tick)

        historical_prices.write(index=b + 1, value=new_tick)

        historical_prices_break.write(b + 1)
    end

    return (eth_price)
end

@external
func get_ticks_array{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}() -> (
    ticks_array_len : felt, ticks_array : Tick*
):
    alloc_locals
    let (ticks : Tick*) = alloc()
    let (ticks_array_len) = historical_prices_len.read()
    let (local first_tick : Tick) = historical_prices.read(0)
    assert ticks[0] = first_tick
    let (local break : felt) = historical_prices_break.read()
    with break:
        get_ticks_array_loop(ticks, ticks_array_len, 1)
    end
    return (ticks_array_len, ticks)
end

func get_ticks_array_loop{
    syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*, break : felt
}(ticks_array : Tick*, ticks_array_len : felt, index : felt):
    alloc_locals
    if index == ticks_array_len:
        return ()
    end
    let (q, corrected_index) = unsigned_div_rem(index + break, ticks_array_len)
    let (is_diffent_zero) = is_not_zero(q)
    if is_diffent_zero == 1:
        tempvar corrected_index = corrected_index + 1
    else:
        tempvar corrected_index = corrected_index
    end

    let (storage_map_0) = historical_prices.read(0)
    let map_0 = storage_map_0.p
    let (storage_map_1) = historical_prices.read(1)
    let map_1 = storage_map_1.p

    let (storage_map_2) = historical_prices.read(2)
    let map_2 = storage_map_2.p

    let (storage_map_3) = historical_prices.read(3)
    let map_3 = storage_map_3.p

    let (storage_map_4) = historical_prices.read(4)
    let map_4 = storage_map_4.p

    let (local current_tick : Tick) = historical_prices.read(corrected_index)

    assert ticks_array[index] = current_tick
    get_ticks_array_loop(ticks_array, ticks_array_len, index + 1)
    return ()
end

@view
func twap{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}() -> (
    twap_value : felt
):
    alloc_locals
    local ticks_array : Tick*
    let (ticks_array_len, ticks_array) = get_ticks_array()
    let sum_pi_ti = 0
    let sum_ti = 0
    with sum_pi_ti, sum_ti, ticks_array, ticks_array_len:
        twap_loop(0)
    end
    let twap = sum_pi_ti / sum_ti
    return (twap_value=twap)
end

func twap_loop{
    syscall_ptr : felt*,
    range_check_ptr,
    pedersen_ptr : HashBuiltin*,
    sum_pi_ti : felt,
    sum_ti : felt,
    ticks_array : Tick*,
    ticks_array_len : felt,
}(index : felt):
    alloc_locals
    if index == ticks_array_len - 1:
        return ()
    end
    let t0 : felt = ticks_array[index].t
    let t1 : felt = ticks_array[index + 1].t
    let delta_t : felt = t1 - t0
    # let (local p0:felt) = ticks_array[index].p
    let p1 : felt = ticks_array[index + 1].p
    let sum_pi_ti = sum_pi_ti + p1 * delta_t
    let sum_ti = sum_ti + delta_t
    twap_loop(index + 1)
    return ()
end

@view
func array_sum{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*}() -> (sum : felt):
    alloc_locals
    local ticks_array : Tick*
    let (_, ticks_array) = get_ticks_array()
    let (ticks_len) = historical_prices_len.read()

    let res = 0
    with res:
        array_sum_loop(ticks_array, ticks_len, 0)
    end
    return (sum=res)
end

func array_sum_loop{syscall_ptr : felt*, range_check_ptr, pedersen_ptr : HashBuiltin*, res : felt}(
    ticks_array : Tick*, ticks_array_len : felt, index : felt
):
    if index == ticks_array_len:
        return ()
    end
    let p = ticks_array[index].p
    let res = res + p
    array_sum_loop(ticks_array, ticks_array_len, index + 1)
    return ()
end
