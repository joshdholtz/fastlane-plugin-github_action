# github_action plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-github_action)
[![Gem Version](https://badge.fury.io/rb/fastlane-plugin-github_action.svg)](https://badge.fury.io/rb/fastlane-plugin-github_action)

## About github_action

[GitHub Actions](https://github.com/features/actions) makes it easy to build, test, and deploy your code right from GitHub. However, etting up [_fastlane_](https://github.com/fastlane/fastlane) to work with [match](https://docs.fastlane.tools/actions/match/#match) on GitHub Actions can take bit of juggling and manual work :pensive:

But `fastlane-plugin-github_action` to the rescue :muscle:

This plugin will:

### 1. Prompt you if `setup_ci` is not found in your `Fastfile`
Running _fastlane_ on a CI requires the environment to be setup properly. Calling the [setup_ci](http://docs.fastlane.tools/actions/setup_ci/#setup_ci) action does that by configuring a new keychain that will be used for code signing with _match_

### 2. Create a Deploy Key on your _match_ repository to be used from your GitHub Action
A [Deploy Key](https://developer.github.com/v3/guides/managing-deploy-keys/) is needed for GitHub Actions to access your _match_ repository. This action creates a new SSH key and uses the public key for the Deploy Key on your _match_ repository.

This will only get executed if the `match_org` and `match_repo` options are specified.

### 3. Set the Deploy Key private key in secrets (along with secrets in your [dotenv](https://github.com/bkeepers/dotenv) file(s)
The private key created for the Deploy Key is store encrypted in your [repository secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets). The private key is stored under the name `MATCH_DEPLOY_KEY`. 

Encrypted secrets will also get set for environment variables from [dotenv](https://github.com/bkeepers/dotenv) files specified by the `dotenv_paths` option.

### 4. Generate a Workflow YAML file to use
A Workflow YAML file is created at `.github/workflows/fastlane.yml`. This will enable your repository to start running GitHub Actions right away - once committed and pushed :wink:. The Workflow YAML template will add the Deploy Key private key into the GitHub Action by loading it from the `MATCH_DEPLOY_KEY` secret and executing `ssh-add`. All of your other encrypted secrets will also be loaded into environment variables for you as well. 

An example can be [seen here](https://github.com/joshdholtz/test-repo-for-fastlane-plugin-github_action/blob/add-github-action/.github/workflows/fastlane.yml).

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-github_action`, add it to your project by running:

```bash
fastlane add_plugin github_action
```

### Requirements

`fastlane-plugin-github_action` depends on [rbnacl](https://github.com/RubyCrypto/rbnacl) which uses [libsodium](https://github.com/jedisct1/libsodium)

For macOS, libsodium can be installed with:

```sh
brew install libsodium
```

See https://github.com/RubyCrypto/rbnacl/wiki/Installing-libsodium for more installation instructions.

## Usage

`fastlane-plugin-github_action` can be execute either direction on the command line with `bundle exec fastlane run github_action` or by adding `github_action` to your `Fastfile`.

### CLI

```sh
bundle exec fastlane run github_action \
  api_token:"your-github-personal-access-token-with-all-repo-permissions" \
  org:"your-org" \
  repo:"your-repo" \
  match_org:"your-match-repo-org" \
  match_repo:"your-match-repo" \
  dotenv_paths:"fastlane/.env.secret,fastlane/.env.secret2"
```

### In `Fastfile`

```ruby
lane :init_ci do
  github_action(
    api_token: "your-github-personal-access-token-with-all-repo-permissions",
    org: "your-org",
    repo: "your-repo",
    match_org: "your-match-repo-org",
    match_repo: "your-match-repo",
    dotenv_paths: ["fastlane/.env.secret", "fastlane/.env.secret2"]
  )
end
```

### Help

Once installed, information and help for an action can be printed out with this command:

```bash
fastlane action github_action # or any action included with this plugin
```

### Options

| Key | Environment Variable | Description |
|---|---|---|
| `server_url` | `FL_GITHUB_API_SERVER_URL` | The server url. e.g. 'https://your.internal.github.host/api/v3' (Default: 'https://api.github.com') |
| `api_token` | `FL_GITHUB_API_TOKEN` | Personal API Token for GitHub - generate one at https://github.com/settings/tokens |
| `org` | `FL_GITHUB_ACTIONS_ORG` | Name of organization of the repository for GitHub Actions |
| `repo` | `FL_GITHUB_ACTIONS_REPO` | Name of repository for GitHub Actions |
| `match_org` | `FL_GITHUB_ACTIONS_MATCH_ORG` | Name of organization of the match repository |
| `match_repo` | `FL_GITHUB_ACTIONS_MATCH_REPO` | Name of match repository |
| `dotenv_paths` | `FL_GITHUB_ACTINOS_DOTENV_PATHS` | Paths of .env files to parse |


## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
