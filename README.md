# ioi_console

## Development Prerequisites

- Ruby 2.5 or later
  - Bundler
- webpack w/ npm and yarn

## Running Locally

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
