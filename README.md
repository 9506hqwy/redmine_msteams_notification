# Redmine MSTeams Notification

This plugin provides a event notification to Microsoft Teams. 

## Features

- Notify to Microsoft Teams using incomming hook when issue or wiki is created or updated.
- Notify test message.
- Mention to issues' author and assignee (Need to use `AdaptiveCard` format).
- Mention to mentioned user (Need to use `AdaptiveCard` format and Redmine 5.0 or later).

## Installation

1. Download plugin in Redmine plugin directory.
   ```sh
   git clone https://github.com/9506hqwy/redmine_msteams_notification.git
   ```
2. Install dependency libraries in Redmine directory.
   ```sh
   bundle install --without development test
   ```
3. Install plugin in Redmine directory.
   ```sh
   bundle exec rake redmine:plugins:migrate NAME=redmine_msteams_notification RAILS_ENV=production
   ```
4. Start Redmine

## Configuration

1. Enable plugin module.

   Check [MSTeams Notification] in project setting.

2. Set in [MSTeams Notification] tab in project setting.

   - [WebHook URL]

     Input MSTeams incoming hook URL.

   - [Message Format]

     Select `MessageCard` or `AdaptiveCard`. The default is `MessageCard`.

   - [Skip SSL certificate verification]

     If the server cant not verify the server certification, check on.

   - [Object ID or UPN]

     Select the custom field which indicates infromation of mentioned user instead of mail address.
     This field lists the user custom field that type is string.

   - [User Preference]

     Select the custom field which indicates whether enable mention per user.
     This field lists the user custom field that type is boolean.

3. Click [Send test notification] after saving.

## Tested Environment

* Redmine (Docker Image)
  * 3.4
  * 4.0
  * 4.1
  * 4.2
  * 5.0
  * 5.1
* Database
  * SQLite
  * MySQL 5.7
  * PostgreSQL 12
