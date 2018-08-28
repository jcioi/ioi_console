# ioi_console

## Development Prerequisites

- Ruby 2.5 or later
  - Bundler
- webpack w/ npm and yarn
- PostgreSQL (at least we need jsonb support)

## Running Locally

```
bundle install 
yarn install
bundle exec rake db:migrate
```

Run the following 2 _concurrently:_

```
bundle exec rails server
./bin/webpack --watch
```

## Build

### Docker

```
docker build -t ioi_console .
```

## Environment Variables

- `GITHUB_CLIENT_ID`
- `GITHUB_CLIENT_SECRET`
- `GITHUB_ACCESS_TOKEN`
- `GITHUB_TEAMS`
- `IOI_SQS_REGION` (optional, default to `AWS_REGION`)
- `IOI_SQS_QUEUE_PREFIX`
    - no need to have `_` at the end, ActiveJob gives delimiter between the prefix and queue name, and it defaults to `_`
