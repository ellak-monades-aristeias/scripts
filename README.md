Use the GitHub API to automatically create teams, repos and add users to them.

## Requirements

1. Ruby
1. Install required gems:

  ```
  gem install octokit
  gem install dotenv
  ```

## Usage

As an owner of the organization, create a personal access token in
<https://github.com/settings/tokens>.

Clone this repo, cd into it and create a file named `.env` containing the
following variables:

```
ACCESS_TOKEN='your-access-token'
ORGANIZATION='organization-name'
```

Run the script:

```
ruby aristeia.rb
```

### Add new teams

Add new teams by editing the `teams` hash in the script and run it again.
