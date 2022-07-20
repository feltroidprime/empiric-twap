# Empiric Computational Price Feeds - Starknet Hackhaton 19.07.2022

Empiric Network goes beyond price feeds. Advanced computational fields are needed in Defi, in a similar manner to what Traditional Finance already has. Thanks to Empiric, these computational fields can be built in a secure and verifiable manner.

The twap.cairo contract has two main parts : 

1. The function `update_historical_ticks` that accumulates Ticks struct in the storage mapping of the contract, that makes sure the mapping isn't holding more than `MAX_TICKS` values. In this project for demonstration, `MAX_TICKS` is set to 5.  
So a rolling window of 5 values is being built, and when it is full, the challenge is to remove the oldest value and add the newest value. If we want to keep the order, we would need to shift `MAX_TICKS-1` values to the left and replace the latest value with the newest tick, which would consist of `MAX_TICKS` operations. If `MAX_TICKS` starts to be large (for example 60 or 240 values), this is not desirable.  
We achieve only two operations per update by storing the MAX_TICKS values in a disordered manner by using another storage_var named `trailing index`. 

   To be more clear, imagine that the window W is full for the first time. We have     
 W = [t0, t1, t2, t3, t4], with ti = Tick_i  
 First update : we receive t5, and we want to get rid of t0. The window becomes  
 W <- [t1, t5, t2, t3, t4]  
 Seconde update : we receive t6, and we want to get rid of t1. W becomes  
 W <- [t2, t5, t6, t3, t4]  
 third update :  
 W <- [t3, t5, t6, t7, t4]    
 one more iteration and the storage mapp is back in an ordered order :  
 W <- [t4, t5, t6, t7, t8]  

2. The function `get_ticks_array` that always return an array of ticks in the cronological order by reading the storage map with the corrected index order. 

If you want to see python prints about it in "real time", you can run tests on twap_debug/test_twap_debug. There are two contracts folders, twap and twap_debug that are similar but twap_debug has hints to show what's happenning update per update. 

Once you have the rolling window array, it is quite simple to compute a TWAP over it using a recursive loop. See `twap` function. 
This rolling window principle stored in the storage map of the contract is useful to compute any kind of indicator without exploding the memory or having too much operations per update. 


### How to test it locally 
Install [Protostar](https://github.com/software-mansion/protostar).  Clone the repository. Use python 3.7. 
```bash
python -m venv env
source env/bin/activate
pip install -r requirements.txt
nile install
```

Launch the test files using
```bash
protostar test contracts/twap_debug/test_twap_debug.cairo
#or 
protostar test contracts/twap/test_twap.cairo
```


Next steps: In order to go beyond the hackhaton, the following actions can be taken:

*Automate the request in order to populate the array. This can be done by using:

https://yagi.fi/

The contract is deployed at the following address:

0x03d65b4d1baa11124b469d6bb6a4fa4d160efda1984fd9e384c07c81708f1126

https://goerli.voyager.online/contract/0x03d65b4d1baa11124b469d6bb6a4fa4d160efda1984fd9e384c07c81708f1126#readContract
