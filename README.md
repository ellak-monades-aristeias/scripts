Use the GitHub API to autmatically create teams, repos and add users to them.

## Requirements

1. Ruby
2. Install `octokit` with: `gem install octokit`

## Usage

Create a personal access token in <https://github.com/settings/tokens>.

Clone this repo, cd into it and create a file named `.env` containing the
following:

```
ACCESS_TOKEN='your-access-token'
```

Run the script with:

```
source .env
ruby aristeia.rb
```

Add new teams by editing the `teams` hash.
