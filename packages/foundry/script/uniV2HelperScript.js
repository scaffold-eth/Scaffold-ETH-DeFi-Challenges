const { ethers } = require("ethers");
const { ChainId, Fetcher, Route, Trade, TokenAmount, TradeType, WETH, Percent } = require("@uniswap/sdk");

const chainId = ChainId.MAINNET;
const provider = new ethers.providers.JsonRpcProvider('');

// Function to get pair address
async function getPairAddress(tokenA, tokenB) {
    const pair = await Fetcher.fetchPairData(tokenA, tokenB, provider);
    return pair.liquidityToken.address;
}

// Function to get reserves and calculate prices
async function getReservesAndPrice(tokenA, tokenB) {
    const pair = await Fetcher.fetchPairData(tokenA, tokenB, provider);
    const reserves = await pair.getReserves();
    const route = new Route([pair], tokenA);
    const price = route.midPrice.toSignificant(6);
    return { reserves, price };
}

// Function to execute a swap
async function swapTokens(tokenIn, tokenOut, amountIn, slippage) {
    const pair = await Fetcher.fetchPairData(tokenIn, tokenOut, provider);
    const route = new Route([pair], tokenIn);
    const trade = new Trade(route, new TokenAmount(tokenIn, amountIn), TradeType.EXACT_INPUT);

    const slippageTolerance = new Percent(slippage, '10000'); // 50 bips, or 0.50%
    const amountOutMin = trade.minimumAmountOut(slippageTolerance).raw;
    const path = [tokenIn.address, tokenOut.address];
    const to = 'YOUR_ADDRESS'; // recipient of the output tokens
    const deadline = Math.floor(Date.now() / 1000) + 60 * 20; // 20 minutes from the current Unix time
    const value = trade.inputAmount.raw;

    const signer = new ethers.Wallet('YOUR_PRIVATE_KEY');
    const account = signer.connect(provider);
    const uniswap = new ethers.Contract(
        UniV2RouterAddress, // Uniswap V2 Router address
        ['function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)'],
        account
    );

    const tx = await uniswap.swapExactTokensForTokens(
        value,
        amountOutMin,
        path,
        to,
        deadline,
        { gasPrice: YOUR_GAS_PRICE, gasLimit: YOUR_GAS_LIMIT }
    );

    return tx;
}

// Example usage
async function main() {
    // Define tokens
    const tokenA = new Token(chainId, 'TOKEN_A_ADDRESS', 18);
    const tokenB = new Token(chainId, 'TOKEN_B_ADDRESS', 18);

    // Get pair address
    const pairAddress = await getPairAddress(tokenA, tokenB);
    console.log(`Pair Address: ${pairAddress}`);

    // Get reserves and price
    const { reserves, price } = await getReservesAndPrice(tokenA, tokenB);
    console.log(`Reserves: ${reserves}`);
    console.log(`Price: ${price}`);

    // Swap tokens
    const swapTx = await swapTokens(tokenA, tokenB, '1000000000000000000', '50'); // Swap 1 TokenA with a slippage of 0.50%
    console.log(`Swap Transaction: ${swapTx.hash}`);
}

main().catch(error => console.error(error));
