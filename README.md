# Avatar-bot

This Telegram bot can ukrainianize your avatar. Just send a picture and you will receive its copy with the Ukrainian flag as a round border!

## General information

## Architecture

Architecture is pretty simple: having received a new message for the bot, Telegram sends it to the Cloud Run through a WebHook. Then, it transmits the request to this application wherein all job is done.

### Build

This project supports building through Opam and Nix. However, static compilation is only available through Nix currently.

#### Opam

```bash
opam install . --deps-only --with-testdune build
opam exec -- dune build 
```

#### Nix

```bash
nix build
```

To build statically:

```bash
nix build .#static
```

Also, one can build container images:

```bash
nix build .#docker
```

Or statically:

```bash
nix build .#staticDocker
```

### CI/CD

There are a few GitHub Actions for testing the compilation of PR through some package managers (Opam, Nix) and deploying on GCP Cloud Run after building the static container image with Nix.
