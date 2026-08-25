# Mac setup

This repository records the tools and configuration needed to reproduce this Mac environment.

## Restore on a new Mac

1. Install Homebrew from [brew.sh](https://brew.sh/).
2. Install the packages in this repository:

   ```sh
   brew bundle --file ./Brewfile
   ```

3. Review and apply macOS preferences:

   ```sh
   ./defaults.sh
   ```

4. Copy or symlink the required files from `dotfiles/` into the home directory.

## Keeping the inventory current

After installing software with Homebrew, add its formula or cask to `Brewfile`. To generate a complete inventory of currently installed Homebrew packages, run:

```sh
brew bundle dump --file ./Brewfile --force
```

Review the resulting changes before committing them.

## Herdr

[Herdr](https://herdr.dev/) is a terminal multiplexer for coding agents.

It is tracked in `Brewfile` and can be installed with:

```sh
brew install herdr
```

Verify the installation with:

```sh
herdr
```

Because this setup uses Homebrew, update Herdr with `brew upgrade herdr` rather than `herdr update`.

## Node.js and pnpm

Node.js is managed with [NVM](https://github.com/nvm-sh/nvm). Install NVM:

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash
```

Open a new terminal, then install Node.js 24 and make it the default:

```sh
nvm install 24
nvm alias default 24
```

Enable pnpm through the Corepack bundled with Node.js:

```sh
corepack enable
corepack prepare pnpm@11.18.0 --activate
```

Current recorded versions:

- Node.js: `v24.18.1`
- npm: `11.16.0`
- pnpm: `11.18.0`

The `.nvmrc` file records the desired Node.js major version. Run `nvm use` from this directory to select it.

## Security

Do not commit passwords, API keys, SSH private keys, `.env` files, or other secrets.
