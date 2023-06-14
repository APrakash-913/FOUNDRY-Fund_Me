# Foundry Fund Me

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

## Quickstart

```
git clone THIS_REPO_LINK
forge build
```

# Usage

Deploy:

```
forge script scripts/DeployFundMe.s.sol
```

## Testing

4 test tiers.

1. Unit
2. Integration
3. Forked
4. Staging

This repo has #1 and #3.

```
forge test
```

or

```
// Only run test functions matching the specified regex pattern.

forge test --match-test testFunctionName
```

or

```
forge test --fork-url $SEPOLIA_RPC_URL
```

### Test Coverage

```
forge coverage
```
