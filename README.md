Project Computational data feeds (extending the oracle & feeds)

Alternative aggregation:

A TWAP feed: Use keepers to regularly ping the oracle to get the most recent price and add that to the running sum: https://en.wikipedia.org/wiki/Time-weighted_average_price#:~:text=TWAP orders are a strategy,second half of the day or https://docs.uniswap.org/protocol/V2/concepts/core-concepts/oracles

Empiric Network goes beyond price feeds. Advanced computational fields are needed, similarly to what Traditional Finance already has. Thanks to Empiric, these computational fields can be built in a secure and verifiable manner.

Our project for this hackhaton is centered on providing TWAP feed. TWAP is a pricing methodology that calculates the mean price of an asset during a specified period of time. For example, a “one-day TWAP” means taking the average price over a defined day of time.

One of the most known protocols using TWAP is Uniswap. A common TWAP implementation used in Uniswap involves taking two snapshots at different points in time, tracking both the timestamp and historical sum of prices for each, and using this information to calculate a final TWAP data point.

In our project, we can define an array of arbitrary size and then compute the TWAP metric.

Last but not least, we compute the volatility based on the array we have.

Next steps: In order to go beyond the hackhaton, the following actions can be taken:

*Automate the request in order to populate the array. This can be done by using:

https://yagi.fi/

*Testing with large array sizes: Making sure the results are consistent and obtained in short time with large arrays

*Providing a front end for choosing the crypto pair for retrieving the feeds (i.e. BTC/USDT, BTC/ USD, etc.)
