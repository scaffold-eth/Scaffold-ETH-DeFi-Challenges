# 🏗 scaffold-eth | 🏰 BuidlGuidl

## 🚩 **🐇 1.0 Challenge 1: Simple Yearn Strategy**

This challenge is focused on guiding students through the following:

- 💡 What a Yearn Strategy is
- 👀 The typical ins and outs of a Yearn strategy to be aware of that Yearn v2 Vaults take with their actual strategies
- 💪🏼 Writing this yearn strategy and getting experience dealing with some types of the basics.

**This is the first part of 2 challenges focused on writing Yearn strategies.**

1. 🙇🏻‍♂️ First challenge - create a super simple strategy to get used to the ins and outs of the `harvest` tx flow.
2. 🦍 Second challenge - create a strategy atop of Mellow Protocol && Gearbox Protocol w/ tests!

> TODO: 💬 Meet other builders in the [Challenge 1 Telegram!](insert LINK HERE)

---

### **🚨 1.1 DeFi Sub-Branch Context / Disclaimers**

💫 This challenge is part of the DeFi Sub-Branch, where students are invited into writing smart contracts that incorporate actual DeFi protocols. The sub-branch projects are ever-expanding since DeFi is too.

🦸🏼‍♀️ The goal of the Defi sub-branch projects/tutorials are to provide students tutorials that foster self-learning in actual DeFi protocols, guide you through some of the basics of integrating with specific protocols, and other useful tips to increase competence to be potentially hireable as an intermediate developer.

> ❗️ NOTE: **Students taking on this challenge will be expected to embrace self-learning AND it is recommended that they have completed all beginner SRE challenges or show competency elsewhere.**

<details markdown='1'><summary>👩🏽‍🏫 More Disclaimers </summary>

💡 The required competency is stated because tying into other protocols is powerful, and with that comes a lot of responsibility when deploying contracts that may end up holding people's actual funds. _These tutorials don't provide you that competency, but they start to show paths for people to become better educated. It is key to know what you are doing._

As well, self-learning is required because tying into DeFi protocols and actual professional crypto projects do not guide developers, step-by-step. If you are new to trying to actually plug into a professional project, no worries! 🤗

We'll touch on some helpful tips as you sort out what the 'norm' is when going through this process. These tips will be specific to each protocol that we are integrating into and learning about.

</details>

---

## 🧱🧱 **2.0 Actual Challenge && Repo Setup**

🚦 To start the challenge, clone the repo to your local machine using the following CLI commands:

TODO: add instructions from the foundry branch to combine scaffold eth v2 and foundry together.

1. Clone the repo onto your local machine and install the submodules: `git clone --recursive <repo link>`

   > NOTE: If you have not installed the submodules, probably because you ran `git clone <repo link>` instead of the CLI command in step 1, you may run into errors when running `forge build` since it is looking for the dependencies for the project. `git submodule update --init --recursive` can be used if you clone the repo without installing the submodules.

2. Install forge on your machine if you have not already: `forge install`

   > NOTE: If you need to download the latest version of foundry, just run `foundryup`

3. Build the project and make sure everything compiles: `forge build`

- TODO: test all steps.

---

### 🐇 **2.1 Yearn Context**

🎥👨🏻‍🏫 To kick things off, we'll start by going over the yearn strategy tutorial (using foundry testing framework) that Yearn core dev, @charlesndalton, has gone over in this [video](https://www.youtube.com/watch?v=z48R7dhAGP4&ab_channel=ETHGlobal).

This README will serve as a written tutorial / challenge on how to write the `Strategy.sol` described in this video.

> _If you are more of a visual learner, check out the video. That said, please do make sure to understand the function details if you are watching the video and seeing him type out the solutions._

If you have questions that are outside of the scope of this challenge's TG group chat then we recommend trying to ask a question in the Yearn Discord or the [Yearn General Telegram Group Chat](https://t.me/yearnfinance). If you can get into the gated YFI Boarding School, you'll have access to lots of great people with a lot of experience too.

🤓🤓 @charlesndalton covers making a yearn strategy where we pull DAI from the DAIVault in Yearn and deploy it in a lending pool in Compound. If you're not familiar with Compound, they are an OG lending protocol where users can be lenders and borrowers of whitelisted tokens (deemed legitimate through Compound governance).

This README and the `Solutions.sol` file are the additional solutions files for this strategy that will help educate people in tandem with the video mentioned.

Let's get into it! 👨🏻‍💻🧑🏻‍💻👩🏻‍💻

---

### **🏰🔍 2.2 General Architecture**

For each yVault there are multiple strategies. Example in the above image: DAI is distributed to different strategies where certain amounts have allocations to it.

![image](./images/HowYearnWorks.png)

💡 Recall: yVaults are secure entities that have ownership of the digital assets in question. Within Yearn, users interact with vaults mainly in their UI, and deposit or withdraw tokens into respective vaults that are isolated to specific a specific token.

That token is then added to the vault's pile of assets from all involved depositors and yearn will distribute the amount of assets to different yield-bearing strategies to earn the depositors APY.

---

### **💵🪙 2.3 Accounting VIP Details**

It's key to know that the strategies take on `debt` from the vaults. AKA some amount of DAI is given to the strategy from the vault. So the strategies below would have some `debt` w/ specified amounts.

Let's first touch on the `harvest` sequences for a typical strategy and then dive a bit deeper into them before coding:

#### **🧑🏽‍🌾🚜`harvest()` sequence**

Typically, yearn strategies have three asset flow scenarios:

1. **➕ Increase Debt Ratio (DR):**

   a. `vault` function `deposit()` is used to deposit funds to strategy. Newly deposited funds are not deployed into the Strategy implementation yet, this happens next time bot(typically a keep3r) calls `harvest()` which also acts as an accounting event.

   b. `harvest()` calls `prepareReturn()` and then calls `adjustPosition()` which then deposits `wantToken` into strategy assuming `_debtOutstanding = 0`.

2. **➖ Decrease DR:**

   a. `vault` function `withdraw()` is used to withdraw a specified `_debtOutstanding` from strategy.

   b. Strategy calls `prepareReturn(_debtOutstanding)` which then does the accounting to see if a profit was made or not in this harvest.

   c. From there it uses `liquidate(_debtOutstanding)` to exit the strategy with required amount of `wantToken`

3. **Keep DR and tend() yields: this is not used as much.**

---

### **🌊🔍 2.4 Strategy Flow #1 Detailed (follows video)**

_Don't worry about the bots, we use OP, a template pattern that extends from the template_

`harvest()` is called by a `keep3r` which does the following:

- `prepareReturn(debtOutstanding)` : decelaring accounting losses and gains since the last harvest. `debtOutstanding` is the amount of wantToken that the vault wants back. So within `prepareReturn()` there will be internal calls to liquidate, if needed, some wantToken to obtain the requested amount of `debt` back to the vault from the respective strategy. This is a function that exists in every strategy.
- `adjustPosition(debtOutstanding)` : the inverse of the above, investing any excess `wantToken` into the respective strategy. In this case DAI.

![image](./images/StrategyFlow1.png)

---

### **🌊🔍 2.5 Strategy Flow #2 Detailed (follows video)**

User withdraws from the vault which calls withdraw from the strategy. This further calls a function called `liquidatePosition(amountNeeded)`. If not enough funds then losses are declared (accounting side of things).

`withdraw()`

![image](./images/StrategyFlow2.png)

Hopefully the architecture makes more sense to you. Now that you understand that, we'll jump into the coding part of the challenge.

---

## 🏊🏻‍♀️🌊 **3.0 Diving into the Code**

Yearn vaults are written in vyper, and strategies are written in solidity. There is a brownie-mix and a foundry-mix for writing strategies. The foundry-mix suggested to be used as a template repo for new strategies is the foundry mix that @storming0x made [here](LINK).

The tutorial goes over the changes made that you will implement into your challenge! **As always, solutions are made but don't peek!!!**

---

### ⛳️ **Checkpoint 2: Dependencies** ⚖️

First code tasks will be to write `Strategy.sol` with appropriate dependendencies and imports needed for this compound focused strategy:

- import OZ library for math // make sure to use solidity v0.8 or greater
- import CDAI as a constant
  - import ICToken.sol because we are building a compound-DAI strategy.
    - CDAI will be the pool we're deploying into.

> `ICToken.sol` is provided in this tutorial, but it is important to be comfortable finding the appropriate interfaces and other dependencies when integrating with protocols. Compound has docs outlining how to integrate with their docs, but this interface is actually made by taking parts of the Compound interface code and extracting the parts that are actually needed for this strategy.

> It is important to check out the comments within the `ICToken.sol` to better understand how it works.

<details markdown='1'><summary>👩🏽‍🏫 Solution Code</summary>
Inside `Strategy.sol`

```
import "@openzeppelin/contracts/utils/math/Math.sol";

import "./interfaces/Compound/ICToken.sol";

// inside the contract itself (below)
ICToken internal constant cDAI = ICToken(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
```

</details>

---

### ⛳️ **Checkpoint 3: Approvals, StrategyName && estimatedTotalAssets()** ⚖️

**In the constructor:**

We need to first approve the amount of DAI that we are putting into this CDAI pool.

Write out the line of code within the `constructor` to ensure that we are giving the max approval for the `wantToken` in the strategy to the CDAI `pool` address.

<details markdown='1'><summary>👩🏽‍🏫 Solution Code</summary>

```
want.approve(address(cDAI), type(uint256).max)
```

</details>

Let's name the strategy. There is a typical convention as Facu from Yearn had pointed out in past strategy tutorial videos.

**Format:** <StrategyProtocolWantToken>

In this tutorial's case, the code you'll need in the `name()` function and the respective name will be:

`return "StrategyCompoundDAI";`

---

### ⛳️ **Checkpoint 3 Continued: estimatedTotalAssets() Implementation** ⚖️

This function is called throughout the general "flow" of a strategy, in particular for accounting purposes. We need to obtain an estimate of total assets in the form of `wantToken`.

**Write up the implementation for this function so it accounts for the `wantToken` within the strategy itself AND the value of the underlying `wantToken` within the strategy assets (cDAI).**

> 💡 _Hint:_ Don't forget to check if there are any scaling factors applied in your conversions.

<details markdown='1'><summary>👩🏽‍🏫 Solution Code</summary>

As you can see, the `exchangeRateStored()` is **scaled up** by a factor of 18, so we must normalize the exchange rate by a factor of 18. Here you can see the `estimatedTotalAssets` are the sum of: `wantToken` in the strategy, `assets` converted to `wantToken` and scaled down properly by `1e18`

```
function estimatedTotalAssets() public view override returns (uint256) {
        return want.balanceOf(address(this)) + cDAI.balanceOf(address(this)) * cDAI.exchangeRateStored() / 1e18;
    }
```

</details>

---

### ⛳️ **Checkpoint 4: prepareReturn() Implementation** 🗂

Great! Now we're going to look at the `prepareReturn()` function. It does two things:

1. Prepares `wantToken` to be returned
2. Takes care of accounting (profits and losses since last harvest), and specifies how much debt it can pay back of the `debtOutstanding` in the form of the return param `debtPayment`

The standard flow of things is to (where all will be in `wantToken`):

1. calculate total assets and total debt in this strategy. We'll use the previous `estimatedTotalAssets()` function for the former && we can use `totalDebt` function from yearn.
2. Write the implementation logic for this function such that it will return the proper params; `_profit, _loss, _debtPayment`
3. Add in a stubbed out function call to a helper function called `withdrawSome()`.
   - This helper function will eventually take care of liquidating enough `wantToken` already deployed in the strategy (CDAI pool) and attempt to get enough to repay the debt being requested. More on this helper function later though.

> 💡 _Hint:_ you'll want to write conditional logic for when there is a profit vs when there is not

<details markdown='1'><summary>👩🏽‍🏫 Solution Code</summary>

```
uint256 _totalAssets = estimatedTotalAssets();
uint256 _totalDebt = vault.strategies(address(this)).totalDebt;

if(_totalAssets >= _totalDebt) {
    _profit = _totalAssets - _totalDebt;
    _loss = 0;
} else {
    _profit =0;
    _loss = _totalDebt - _totalAssets;
}

withdrawSome(_debtOutstanding + _profit); // _profit needs to be liquid in wantToken, so `withdrawSome()` takes care of that

uint256 _liquidWant = want.balanceOf(address(this));

// enough to pay profit (partial or full) only
if(_liquidWant <= profit) {
    _profit = _liquidWant;
    _debtPayment = 0;
// enough to pay for all profit and _debtOutstanding (partial or full)

}
```

</details>

---

### ⛳️ **Checkpoint 5: adjustPosition() Implementation** 🤝

The focus of this function is to invest excess `wantToken` into the respective strategy. In this case we're investing any excess DAI into the CDAI pool.

Write the implementation logic such that it invests any excess DAI, based on the `debtOutstanding` param, into the CDAI pool.

💡 _Hint:_ make sure that there are checks implemented to ensure that the excess DAI was truly invested (see ICToken interface return values 😉)

<details markdown='1'><summary>👩🏽‍🏫 Solution Code</summary>

```
function adjustPosition(uint256 _debtOutstanding) internal override {
        uint256 _daiBal = want.balanceOf(address(this));

        if(_daiBal > _debtOutstanding) {
            uint256 _excessDai = _daiBal - _debtOutstanding;
        // cToken function mint() gives back a uint256 == 0 if it is successful.
            uint256 _status = cDAI.mint(_excessDai);
            assert(_status == 0);
        }
    }
```

</details>

---

### ⛳️ **Checkpoint 6: withdrawSome() Implementation** 😶‍🌫️

Recall from before that this was the stubbed out function to actually liquidate cDAI to DAI (`wantToken`) as needed.

<details markdown='1'><summary>👩🏽‍🏫 Solution Code</summary>

Recall: passed in param to this function is in DAI, and we need to convert that to cDAI because `redeem` takes a cDAI amount. So multiply by 1e18 and divide by the exchange rate!

```
function withdrawSome(uint256 _amountNeeded) internal {
    uint256 _cDaiToBurn = Math.min(
      (_amountNeeded * 1e18) / cDAI.exchangeRateStored(),
      cDAI.balanceOf(address(this))
    );
    uint256 _status = cDAI.redeem(_cDaiToBurn);
    assert(_status == 0);
  }
```
</details>

Nice, now we'll move onto `liquidatePosition()`!

---
### ⛳️ **Checkpoint 7: liquidatePosition() Implementation** 😶‍🌫️

Remember that this is called during "withdraw" flow.

First calculate how much DAIBal we have already. If we have enough DAIBal to pay things back then we'll return the `amountNeeded` accordingly - we'd report 0 loss then.

Otherwise we're going to call `withdrawSome()`, get more DAI from our strategy, and then check if we have enough.

<details markdown='1'><summary>👩🏽‍🏫 Solution Code</summary>

```
function liquidatePosition(uint256 _amountNeeded) internal override returns (uint256 _liquidateAmount, uint256 _loss) {
    uint256 _daiBal = want.balanceOf(address(this));

    if (_daiBal >= _amountNeeded) {
        return (_amountNeeded, 0);
    }

    withdrawSome(_amountNeeded);

    _daiBal = want.balanceOf(address(this));
    if (_amountNeeded > _daiBal) {
        _liquidatedAmount = _daiBal;
        _loss = _amountNeeded - _daiBal;
    } else {
        _liquidateAmount = _amountNeeded;
    }
}
```
</details>

---

### ⛳️ **Checkpoint 8: Running Forge Tests to Assess Integrations Setup w/ New Strategy** 🧪

At this point we have all the basic functions written out! Congrats!

Now we'll check that your code actually works. Luckily we're leveraging the working foundry mix from Yearn protocol themselves. Part of their developer relations side of things is to onboard new strategists easily by having them only need to worry about risk vectors associated to their strategy itself. They don't need to worry about the harvest flows, interactions with the vaults, etc. typically! So that means that running `make test` will run the typical integrations tests that are needed to ensure a good working strategy with the rest of the yearn v2 vaults architecture is sound!

_NOTE: `make test` is just a script that ultimately runs a series of `forge test` and you can dig into it more by investigating the yearn foundry mix repo itself with its `package.json`_

Before running your tests you'll need to prepare your `.env` if you haven't already.

> Prepare a `.env` file by copying the `.env.example` file from this repo && populate the necessary environment variables. **Make sure that `.env` is listed in your `.gitignore`!!! It should be by default if you cloned this repo but always make sure.**

Here's some notes on the environment variables you'll need to get:

1. `ETH_RPC_URL`: To deploy the code onto a persistent mainnet fork, you'll need the RPC URL, you can get one from infura or alchemy:

- `MAINNET_RPC = <insert ETH RPC URL here>`

2. `ETHERSCAN_API_KEY`: Etherscan is the leading block explorer, search, API, and analytics platform for Ethereum. Data from the blockchain can be queried using their avaiable APIs. Head to etherscan.io and set up your account to get your own API keys if you haven't done so already.

- `ETHERSCAN_API_KEY = <insert ETHERSCAN_API_KEY here>`

> Make sure you are using latest version of foundry, so that it auto-sources `.env`, otherwise run (while in the root directory): `source .env`

Now test your strategy and run `make test`

> At this point you should see that there are some errors actually. Using foundry, you can go through the terminal outputs to find out what went wrong with the code.

> There should be two errors that prompt up, and one more as we go along, you'll see 😉

---

### ⛳️ **Checkpoint 9: Troubleshooting Test Errors** 👨🏼‍🔬

The errors that should have arose at this point are due to the basic integrations tests that Yearn has written up. You can find them in the following directory path: `"./src/test"`

First there's one in `StrategyShutdown.t.sol`:

> All the way at the bottom, you'll see a line that states `assertGe(want.balanceOf(address(vault)), _amount); // The vault has all funds`

> Replace this with: `assertRelApproxEq(want.balanceOf(address(vault)), _amount, DELTA);`

💡 What you're doing here is replacing the previous line of code with a foundry cheat code that allows some leweigh in the minute losses seen when carrying out this test. It's not perfect, but sometimes losses occurring through several tx executions is bound to happen.

Moving on from the test code, we still have problems arising because we have two more functions to write implementation code for;  `liquidateAllPositions()` and `prepareMigration()`.

---
#### 1️⃣ **Error #1: `liquidateAllPositions()`**

This function's purpose is to liquidate all active positions in the strategy to obtain the `wantToken`, which in this case is DAI.

Your task is to:

- Liquidate any open strategy positions within the Compound DAI contracts
- Ensure that the liquidation was successful

Take a crack at it, and try not to look at the solutions as always.

> 💡 _hint:_ recall how you liquidated positions within `withdrawSome()`

<details markdown='1'><summary>👩🏽‍🏫 Solution Code</summary>

```
function liquidateAllPositions() internal override returns (uint256) {
        uint256 _status = cDAI.redeem(cDAI.balanceOf(address(this)));
        assert(_status == 0);
        return want.balanceOf(address(this));
    }
```

</details>

Now run `make test` and you should see that only two error remains. `testProfitableHarvest()` and  `testMigration(uint256)` are still failing. We'll focus on the latter first.

> BTW `liquidateAllPositions()` was causing errors in the `testRevokeStrategyFromStrategy()` and `testBasicShutdown()` because v2 vaults have a function, `_revokeStrategy()` that ultimately sets the DR to be 0 for a strategy and ultimately calls `liquidateAllPositions()`. Thus `liquidateAllPositions()` implementation is fully needed for these two tests. 😎

---

#### **2️⃣ Error #2: `prepareMigration()`**

This function's purpose is to migrate all tokens that are not the `wantToken` to a new strategy. This may happen because of several reasons including upgrades to the strategy itself. This could happen because the underlying protocol undergoes upgrades to newer versions and the older protocol contracts are deemed obsolete or less relevant for the respective strategy.

Now try writing the implementation. Your task is to write the function so it:

- transfers cDAI from this strategy to a new specified address of the new strategy.

> 💡 _hint:_ recall how you liquidated positions within `withdrawSome()`

<details markdown='1'><summary>👩🏽‍🏫 Solution Code</summary>

```
    function prepareMigration(address _newStrategy) internal override {
        cDAI.transfer(_newStrategy, cDAI.balanceOf(address(this)));
    }
```

</details>

> 🎉🎉 Awesome!!! Now if you run `make test` again you should only see one failing test, `testProfitableHarvest()`. Let's take a look at that one now. It is in the `StrategyOperation.t.sol` file though, and not in your `Strategy.sol` code itself.

Here's a great opportunity to get familiar a bit with how one writes tests with foundry. Foundry enables many functionalities, but a key one is that it keeps development all within Solidity (smart contracts and test writing). There are clear advantages to this when thinking about the nuances that arise when working with EthersJS alternatively. As well the speed of foundry testing is very fast for running things like fuzzing tests.

Open up `StrategyOperations.t.sol` and you should see some TODOs under `testProfitableHarvest(uint256 _amount)`. Here you'll need to write the test code to do the following:

> 🙊 'Fake' the simulation of accruing yield in the compound strategy through airdropping DAI into the cDAI contract. 

You might think that this should be associated to the user depositing into the yearn strategy, but since the yearn strategy already allocated DAI to the cDAI contract on behalf of the user, then the accounting within the yearn vaults should provide the user some yield with respect to when they entered the vault and the strategy.

<details markdown='1'><summary>👩🏽‍🏫 Solution Code</summary>

In `StrategyOperations.t.sol` and you should see some TODOs under `testProfitableHarvest(uint256 _amount)`. Here you'll need to write the test code to do the following:

```
    function testProfitableHarvest(uint256 _amount) public {
        vm.assume(_amount > minFuzzAmt && _amount < maxFuzzAmt);
        deal(address(want), user, _amount);

        // Deposit to the vault
        vm.prank(user);
        want.approve(address(vault), _amount);
        vm.prank(user);
        vault.deposit(_amount);
        assertRelApproxEq(want.balanceOf(address(vault)), _amount, DELTA);

        uint256 beforePps = vault.pricePerShare();

        // Harvest 1: Send funds through the strategy
        skip(1);
        vm.prank(strategist);
        strategy.harvest();
        assertRelApproxEq(strategy.estimatedTotalAssets(), _amount, DELTA);

        address cDAI = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
        uint256 daiBalOfPool = want.balanceOf(cDAI);
        uint256 amountToAirdrop = daiBalOfPool / 1000;
        deal(address(want), cDAI, daiBalOfPool + amountToAirdrop);

        // Harvest 2: Realize profit
        skip(1);
        vm.prank(strategist);
        strategy.harvest();
        skip(6 hours);

        uint256 profit = want.balanceOf(address(vault));
        assertGt(strategy.estimatedTotalAssets() + profit, _amount);
        assertGt(vault.pricePerShare(), beforePps);
    }
```

</details>

Now with all that done, run `make test` one more time.

> 😮‍💨🫠 Whew, at this point it should be passing the basic integrations yearn strategy tests though. Further diligence in writing more robust tests is needed followed by detailed peer reviews and audits if you want to see your strategy go to production in Yearn's testing grounds: www.ape.tax

###

**🎉🍾 Congratulations!!! You just finished writing your first simple yearn strategy!!!**

🚨 As mentioned, this is just a tutorial so don't go deploying this on mainnet yourself with the expectation that it is safe. This tutorial is meant to teach the basics, and there already is a compound strategy that Yearn uses for DAI!

---

## 📚References and Context for Those Interested in How this Tutorial was Made

The DeFi Level 3000 repo is always growing. If you are interested in contributing by writing tutorials that educating others in integrating with a different protocol please open an issue, or even fork the repo and submit a PR or draft PR!

For inspiration and/or reference, we've listed out how this strategy came to be, it was very organic! @steve0xp went through yearn's onboarding documentation and links, and got his hands dirty with the simple strategy tutorial shown in this sub-branch / challenge #1. From there he continued to work on an actual new strategy, which is discussed in Challenge #2.

### **💡🚶🏻‍♂️ Steps taken when Starting this Yearn Strategy Itself**

A typical professional crypto project will have developer docs to help onboard devs into the respective tech stack. The approach that was taken when writing this yearn strategy was to read through the docs, and jump in to the communication channels offered from the protocol.

@steve0xp simply wanted to learn how to write yearn strategies, and was fortunate enough to have met some yearn contributors at past conferences and throughout online async communications (being part of their discord, writing threads on their project, etc.).

In the case of getting involved with writing strategies, he simply went onto the Yearn Discord, chatted about building yearn strategies, and was pointed to the [Yearn General Telegram Group Chat](https://t.me/yearnfinance) && eventually the gated Telegram group chat, YFI Boarding School. Here he met other strategists, and core strategists who actually deployed strategies with real funds in them.

> **@steve0xp wrote threads outlining his journey writing this Yearn Strategy, we heavily recommend checking out the respective thread highlighted through different parts of this tutorial.**

> We'll list them out all here now though for easier reference. These offer a general landscape of this tutorial's contents. We will use his journey && strategy as the basis of this tutorial.

<details markdown='1'><summary>👩🏽‍🏫 DRAFT THREADS - TODO: finalize these links once the threads are posted. </summary>

1. [Getting started, conceptualization && initialization](https://typefully.com/t/X7kgQ4J)
2. [Troubleshooting with other devs && discussions](https://typefully.com/t/7viHbCb)
3. [Q/C through writing unit tests](tbd)
4. [Deployment && getting actual dollars into the strategy from yearn vaults](tbd)

</details>

---

### README from @storming0x foundry_strategy_mix

The following are the README details found typically in the foundry_strategy_mix. You would use this to start a brand new strategy (assuming you are building with foundry). The repo is updated periodically so make sure to pull the most recent ones and direct any questions to the Yearn team if you are having any troubles!

<details markdown='1'><summary>👩🏽‍🏫 README.md from @storming0x foundry_strategy_mix </summary>

# Yearn Strategy Foundry Mix

## What you'll find here

- Basic Solidity Smart Contract for creating your own Yearn Strategy ([`Strategy.sol`](src/Strategy.sol))

- Configured github template with Foundry framework for starting your yearn strategy project.

- Sample test suite. ([`tests`](src/test/))

## How does it work for the User

Let's say Alice holds 100 DAI and wants to start earning yield % on them.

For this Alice needs to `DAI.approve(vault.address, 100)`.

Then Alice will call `Vault.deposit(100)`.

Vault will then transfer 100 DAI from Alice to itself, and mint Alice the corresponding shares.

Alice can then redeem those shares using `Vault.withdrawAll()` for the corresponding DAI balance (exchanged at `Vault.pricePerShare()`).

## Installation and Setup

1. To install with [Foundry](https://github.com/gakonst/foundry).

2. Fork this repository (easier) or create a new repository using it as template. [Create from template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)

3. Clone your newly created repository recursively to include modules.

```sh
git clone --recursive https://github.com/myuser/foundry-yearn-strategy

cd foundry-yearn-strategy
```

NOTE: if you create from template you may need to run the following command to fetch the git submodules (.gitmodules for exact releases) `git submodule init && git submodule update`

4. Build the project.

```sh
make build
```

5. Sign up for [Infura](https://infura.io/) and generate an API key and copy your RPC url. Store it in the `ETH_RPC_URL` environment variable.
   NOTE: you can use other services.

6. Use .env file
7. Make a copy of `.env.example`
8. Add the values for `ETH_RPC_URL`, `ETHERSCAN_API_KEY` and other example vars
   NOTE: If you set up a global environment variable, that will take precedence.

9. Run tests

```sh
make test
```

## Basic Use

To deploy the demo Yearn Strategy in a development environment:

TODO

## Implementing Strategy Logic

[`src/Strategy.sol`](contracts/Strategy.sol) is where you implement your own logic for your strategy. In particular:

- Create a descriptive name for your strategy via `Strategy.name()`.
- Invest your want tokens via `Strategy.adjustPosition()`.
- Take profits and report losses via `Strategy.prepareReturn()`.
- Unwind enough of your position to payback withdrawals via `Strategy.liquidatePosition()`.
- Unwind all of your positions via `Strategy.exitPosition()`.
- Fill in a way to estimate the total `want` tokens managed by the strategy via `Strategy.estimatedTotalAssets()`.
- Migrate all the positions managed by your strategy via `Strategy.prepareMigration()`.
- Make a list of all position tokens that should be protected against movements via `Strategy.protectedTokens()`.

## Testing

Tests run in fork environment, you need to complete [Installation and Setup](#installation-and-setup) step 6 to be able to run these commands.

```sh
make test
```

Run tests with traces (very useful)

```sh
make trace
```

Run specific test contract (e.g. `test/StrategyOperation.t.sol`)

```sh
make test-contract contract=StrategyOperationsTest
```

Run specific test contract with traces (e.g. `test/StrategyOperation.t.sol`)

```sh
make trace-contract contract=StrategyOperationsTest
```

See here for some tips on testing [`Testing Tips`](https://book.getfoundry.sh/forge/tests.html)

## Deploying Contracts

You can Deploy and verify your strategies if PRIV_KEY and ETHERSCAN_API_KEY are both set in the .env by using the command

```sh
make deploy
```

Before deploying, update the constructor-args variable within the Makefile to include any parameters applicable. Make sure to seperate each argument only by a space, no commas.

The deploy script is coded to deploy the "Strategy" contract within the Strategy.sol file. This can be updated by simply updating to src/YourContract.sol:YourContract.

## GitHub Actions

This template comes with GitHub Actions pre-configured. Your contracts will be linted and tested on every push to
`master` and `develop` branch.

Note though that to make this work, you must set your `INFURA_API_KEY` and your `ETHERSCAN_API_KEY` as GitHub secrets.

# Resources

- Yearn [Discord channel](https://discord.com/invite/6PNv2nF/)
- [Getting help on Foundry](https://github.com/gakonst/foundry#getting-help)
- [Forge Standard Lib](https://github.com/brockelmore/forge-std)
- [Awesome Foundry](https://github.com/crisgarner/awesome-foundry)
- [Foundry Book](https://book.getfoundry.sh/)
- [Learn Foundry Tutorial](https://www.youtube.com/watch?v=Rp_V7bYiTCM)

</details>
