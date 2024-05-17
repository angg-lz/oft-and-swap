<p align="center">
  <a href="https://layerzero.network">
    <img alt="LayerZero" style="max-width: 500px" src="https://d3a2dpnnrypp5h.cloudfront.net/bridge-app/lz.png"/>
  </a>
</p>

<p align="center">
  <a href="https://layerzero.network" style="color: #a77dff">Homepage</a> | <a href="https://docs.layerzero.network/" style="color: #a77dff">Docs</a> | <a href="https://layerzero.network/developers" style="color: #a77dff">Developers</a>
</p>

<h1 align="center">Mint Burn OFT Adapter Example</h1>

<p align="center">
  <a href="https://docs.layerzero.network/contracts/oft" style="color: #a77dff">Quickstart</a> | <a href="https://docs.layerzero.network/contracts/oapp-configuration" style="color: #a77dff">Configuration</a> | <a href="https://docs.layerzero.network/contracts/options" style="color: #a77dff">Message Execution Options</a> | <a href="https://docs.layerzero.network/contracts/endpoint-addresses" style="color: #a77dff">Endpoint Addresses</a>
</p>

<p align="center">Example project for getting started with <code>MintBurnOFTAdapter</code>, a wrapper on top of LayerZero's <code>OFT</code> standard contract.</p>

---

- [Usage](#usage)
  - [Developing Contracts](#developing-contracts)
    - [Installing dependencies](#installing-dependencies)
    - [Compiling your contracts](#compiling-your-contracts)
    - [Running tests](#running-tests)
  - [Deploying Contracts](#deploying-contracts)
- [What is an OFT Adapter?](#what-is-an-oft-adapter)
- [MintBurnOFTAdapter](#mintburnoftadapter)
- [Requirement](#requirement)
- [Contracts Structure](#contracts-structure)
  - [`ElevatedMinterBurner.sol`](#elevatedminterburnersol)
    - [Variables](#variables)
    - [Functions](#functions)
  - [`MintBurnOFTAdapter.sol`](#mintburnoftadaptersol)
    - [Variables](#variables-1)
    - [Functions](#functions-1)


## Usage

### Developing Contracts

#### Installing dependencies

We recommend using `pnpm` as a package manager (but you can of course use a package manager of your choice):

```bash
pnpm install
```

#### Compiling your contracts

This project supports both `hardhat` and `forge` compilation. By default, the `compile` command will execute both:

```bash
pnpm compile
```

If you prefer one over the other, you can use the tooling-specific commands:

```bash
pnpm compile:forge
pnpm compile:hardhat
```

Or adjust the `package.json` to for example remove `forge` build:

```diff
- "compile": "$npm_execpath run compile:forge && $npm_execpath run compile:hardhat",
- "compile:forge": "forge build",
- "compile:hardhat": "hardhat compile",
+ "compile": "hardhat compile"
```

#### Running tests

Similarly to the contract compilation, we support both `hardhat` and `forge` tests. By default, the `test` command will execute both:

```bash
pnpm test
```

If you prefer one over the other, you can use the tooling-specific commands:

```bash
pnpm test:forge
pnpm test:hardhat
```

Or adjust the `package.json` to for example remove `hardhat` tests:

```diff
- "test": "$npm_execpath test:forge && $npm_execpath test:hardhat",
- "test:forge": "forge test",
- "test:hardhat": "$npm_execpath hardhat test"
+ "test": "forge test"
```

### Deploying Contracts

Set up deployer wallet/account:

- Rename `.env.example` -> `.env`
- Choose your preferred means of setting up your deployer wallet/account:

```
MNEMONIC="test test test test test test test test test test test junk"
or...
PRIVATE_KEY="0xabc...def"
```

- Fund this address with the corresponding chain's native tokens you want to deploy to.

To deploy your contracts to your desired blockchains, run the following command in your project's folder:

```bash
npx hardhat lz:deploy
```

More information about available CLI arguments can be found using the `--help` flag:

```bash
npx hardhat lz:deploy --help
```

By following these steps, you can focus more on creating innovative omnichain solutions and less on the complexities of cross-chain communication.

<br></br>

<p align="center">
  Join our community on <a href="https://discord-layerzero.netlify.app/discord" style="color: #a77dff">Discord</a> | Follow us on <a href="https://twitter.com/LayerZero_Labs" style="color: #a77dff">Twitter</a>
</p>

## What is an OFT Adapter?

OFT Adapter allows an existing token to expand to any supported chain as a native token with a unified global supply, inheriting all the features of the OFT Standard. This works as an intermediary contract that handles sending and receiving tokens that have already been deployed. Read more [here](https://docs.layerzero.network/v2/developers/evm/oft/adapter).

Ideally, when you want to convert an existing ERC20 token with its current fixed supply into an Omnichain token, you can use the OFTAdapter as a wrapper around that ERC20. 

There are several ways to go about it since the base code of OFTAdapter keeps contract logic implementation up to the developer. Eg., the Adapter could be implemented in such a way that the original ERC20 is locked inside the Adapter on chain A and the OFT is minted on chain B. 


## MintBurnOFTAdapter
[`MintBurnOFTAdapter`](/contracts/MintBurnOFTAdapter.sol) is a template OFT adapter used primarily for tokens that are **burnt** on chain A (source chain), as opposed to **locked**, and are minted on chain B (destination chain).

## Requirement
The only requirement is that the base ERC20 must have a `burn` and a `mint` function

## Contracts Structure
### `ElevatedMinterBurner.sol`
![alt text](image.png)
This is a periphery contract for minting or burning tokens and executing arbitrary calls on the underlying ERC20.

#### Variables
Maintains a single variable, `token` which is the address of the ERC20 implementation.

#### Functions
`mint()`, `burn()` and `exec()` facilitate direct interface with the ERC20 implementation.

### `MintBurnOFTAdapter.sol`
![alt text](image-1.png)

#### Variables
This is the actual OFT Adapter contract that maintains two constants: `innerToken` and `minterBurner`
- `innerToken`: underlying ERC20 implementation
- `minterBurner`: reference to the `ElevatedMinterBurner` implementation that has the implementation of `burn` and `mint` functions

#### Functions
- `_debit`: Calls `burn` on `minterBurner` (implementation of `ElevatedMinterBurner`) effectively burning tokens from sender's balance from source chain.
- `_credit`: Calls `mint` on `minterBurner`, effectively minting tokens to sender's balance on destination chain.

> [!IMPORTANT]
> The default `OFTAdapter` implementation assumes **lossless** transfers, ie. 1 token in = 1 token out. If the underlying ERC20 applies something like a transfer fee, the default will **not** work. A pre/post balance check will need to be added to calculate the `amountReceivedLD`.

