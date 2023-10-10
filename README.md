# Avatar-bot

This Telegram bot can ukrainianize your avatar. Just send a picture and you will receive its copy with the Ukrainian flag as a round border!

## General information

## Architecture

Architecture is pretty simple: having received a new message for the bot, Telegram sends it to the Cloud function endpoint through a WebHook. Then, this application is invoked with some parameters, which include information about the message and parses parameters to do its job.

### Build

This project supports building through Opam and Nix. However, static compilation for Cloud functions is only available through Nix currently.

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

### CI/CD

There are a few GitHub Actions for testing the compilation of PR through some package managers (Opam, Nix) and deploying on IBM Cloud functions after static building with Nix.
