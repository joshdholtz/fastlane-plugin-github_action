# github_action plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-github_action)
[![Gem Version](https://badge.fury.io/rb/fastlane-plugin-github_action.svg)](https://badge.fury.io/rb/fastlane-plugin-github_action)

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

## About github_action

Helper to setup GitHub Actions for _fastlane_.

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

### Parameters

The action parameters `api_token`, `owner_name`, `app_name`, and others can also be omitted when their values are [set as environment variables](https://docs.fastlane.tools/advanced/#environment-variables). By default, `appcenter_upload` will use the same `api_token`, `owner_name`, and `app_name` you used in `appcenter_fetch_devices`.

Here is the list of all existing parameters:

#### `appcenter_fetch_devices`

| Key | Environment Variable | Description |
|-----------------|--------------------|
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
