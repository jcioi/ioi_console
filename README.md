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

### authenticating with GitHub 

- `GITHUB_CLIENT_ID`
- `GITHUB_CLIENT_SECRET`
- `GITHUB_ACCESS_TOKEN`
- `GITHUB_TEAMS`

## SQS (ActiveJob and Shoryuken)

SQS is activated when IOI_SQS_QUEUE_PREFIX is given

- `IOI_SQS_REGION` (optional, default to `AWS_REGION`)
- `IOI_SQS_QUEUE_PREFIX`
    - no need to have `_` at the end, ActiveJob gives delimiter between the prefix and queue name, and it defaults to `_`
- `IOI_SHORYUKEN_QUEUE` (for shoryuken worker, optional, specify single queue name to activate long polling)
- `IOI_SHORYUKEN_CONCURRENCY` (for shoryuken worker, optional, default to `15`)

## Remote Task

### S3 Log Provider

- `IOI_S3_LOG_REGION`
- `IOI_S3_LOG_BUCKET`
- `IOI_S3_LOG_PREFIX`

### SSM Driver

- `IOI_SSM_PROCESS_EVENTS` (optional, default to `0`; set `1` to disable polling)
- `IOI_SSM_REGION`
- `IOI_SSM_LOG_S3_REGION`
- `IOI_SSM_LOG_S3_BUCKET`
- `IOI_SSM_LOG_S3_PREFIX`
- `IOI_SSM_SCRATCH_S3_REGION`
- `IOI_SSM_SCRATCH_S3_BUCKET`
- `IOI_SSM_SCRATCH_S3_PREFIX`
