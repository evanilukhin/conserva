# Сonvert service

## Migrations
rake db:migrate

## Cleaning task
For clean downloaded file run:
```ruby
rake task_cleaner:downloaded
```
This task clear task which was last downloaded n-minutes ago.

For clean outdated file run:
```ruby
rake task_cleaner:outdated
```
This task clear task which was  created n-days ago.
Clearing time customize in environment.yml.
