# Primal
## Introduction
Primal is an NFT Card RPG game on Polygon.
Players can control powerful heroes to explore the Primal world, fight with enemies to seize spoils Erc-20, and even subdue enemy Erc-721 for their own use. There are various ways for players to strengthen heroes and become the king of Primal world!
The token and NFT circulation will be automatically optimized through smart contract.
Primal’s objective is to build a totally decentralized, open and free Metaverse game!

## Gameplay
1. Becoming stronger is the dream of every primal hero.
2. Access channels by selecting suitable resources according to the skill attributes.
3. Except through your own efforts, players can also seize resources of other players.
4. Pay attention to hero's patience: too low may out of your control.
5. The patience can be regained through repairment.
6. Go to revenue page to confirm revenue.
7. Except The First Genesis Blind Box and Airdrop, players can get new NFTs by defeating system hero, trading in the market and other ways from other players.

### Game Story
The story starts in 2022, another vast world-Primal opened its entrance: there are infinite plot waiting for you to explore, there are infinite stimulation waiting for you to enjoy.
So you flexed muscle, after having partner heroes, you finally opened the trip to Primal.

Start the Game
1. Connect your wallet (sign in Metamask)
2. Check the account assets (each player has one NFT collection to show HERO NFT)
3. Click to enter Primal
4. Primal can’t be opened without hero. Players must obtain the first HERO NFT through NFT market or Blind Box

### Game Mode 1
PVE
Single Monster Mode
You can gain corresponding resource rewards by choosing HERO NFT to fight with enemy. When hostile hero's patience = 0, you have a chance to subdue and change NFT. Similarly you may also be subdued by enemy.
Dungeons
Turn on Team Battle Mode: choose 3 heroes to fight with 3 hostile heroes.
Win more than 2 times, the battle will be judged as victory. Otherwise will be judged as being captured.
Players can get free monster information once a day in PVE Mode

### Game Mode 2
#### Mining
According to the hero’s professional skills, player can mine different resources. Different qualities will have different income bonuses.
During mining, pay attention to the attack from players with plundering skills. They will randomly select a player in mining to attack. After successfully attacking, they will seize part of player's undrawn income. If the opponent's hero's patience is 0, it is possible to plunder the hero's NFT. Similarly, it is also possible to be captured by enemy.

### NFT attribute display
**Element** :
Water | Fire | Ground | Air | Life

**Attribute** :
Health | Attack | Critical | Speed | Defense | Dodge

**Skill** :
Air Affinity (mining the Primal Air); Earth Affinity (mining the Primal Earth); Water Affinity (mining the Primal Water); Fire Affinity (mining the Primal Fire); Life Affinity (mining the Primal Life); Primal Affinity (mining the Primal Might); Predator (can plunder other players' resources)

**Patience** :
Hero's patience. If patience= 0, it may be out of the player's control and captured by the enemy

## NFT reinforcement

### Finishing
The lost patience of the hero can be restored by trimming. You need to pay the corresponding elemental power and source energy

### Synthesis
A new hero has more powerful attributes by melting and synthesizing multiple heroes. You can invest up to 4 Heroes at a time. The higher the level, the more difficult it is to synthesize

### Recasting
The attribute values and skills of the current hero can be recast by paying the force of corresponding elements

## Token Description
In game resource token:
Primal Might: general consumption. Only NFT of affinity skill of source can be mined
Primal Earth: NFT recasting consumption of soil element, NFT trimming consumption of fire element and NFT synthesis consumption of water element. Only NFT with affinity skill of soil element can be excavated
Primal Water: NFT recasting consumption of water element, NFT trimming consumption of life element and NFT synthesis consumption of air element. Only NFT with affinity skill of water element can be excavated
Primal Fire: fire element NFT recasting consumption, water element NFT trimming consumption and life element NFT synthesis consumption. Only NFT with fire element affinity skill can be excavated
Primal Air: NFT recasting consumption of air element, NFT trimming consumption of earth element and NFT synthesis consumption of fire element. Only NFT with affinity skill of air element can be excavated
Primal Life: life element NFT recasting consumption, air element NFT trimming consumption, soil element NFT synthesis consumption. Only NFT with life element affinity skill can be excavated

The way to get it is through in-game mining, PVE wild monster chance drop, plundering other players' resources, or by exchange pool.

### Game Token
Name: Mote of Primal (MP)
Total issue 1000000000
20% stake pool
40% PVP activity reward
5%  Swap LP
10% Team and Marketing
15% Community
10% strategic sale

### Usage scenario

Refresh PVE wild monster, PVP admission fee, NFT trading market, etc

### Contact Address

// TODO: There addresses are localized, should be updated to latest against to Polygon Test Network(Mumbai)

ERC20
- Primal Air: 0x144397D33DcA6A8570d1014CBAC713C2299764ac
- Primal Life: 0x09bc45Ca128856F1e33e09762500BC6dacf3A59C
- Primal Water: 0xbfAaB1e2b68BC625fC53C1D8c864C5118Ec871CA
- Primal Fire: 0xb128BEB2009AE505de146db882C77d86dB1CA6Cd
- Primal Earth: 0x5871c44b81A93ef656e62D99d84CB3f3B11d09C0
- Primal Might: 0xc4CbE261A319821B3Cb3c40Fc0dbc2104Dae489b
- Mote of Primal (MP)0xd04476363070E5d1f6ee0E022Dce35854781ff74

ERC721: 
- 0xd112845c5A70A30343F092eaecbDEEFDA02b5ed0
721 Attribute warehouse: 
- 0x0F3E2eaDB062DDB8D05c86b10242507346cdE90A
Stake Contact: 
- 0x72Cc1Ba12042AC4c2c49eEE9Aac58F6e5fa2330A
PVE Contact :
- 0x93A1E51A94668bf76C41193B1ab95e3e7f86caC9


# Deployment

```bash

cp .env.example .env 

# edit .env by add your public+private key

npm install
npx hardhat run --network bsctestnet scripts/deploy_logic.js
```

```bash
# Test with ganache
npm install -g ganache 
ganache -m "buzz track ticket fresh mom cigar net switch cruise response mention start"

```