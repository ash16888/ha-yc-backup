# Home Assistant Add-on: Yandex Cloud S3 Backup

## Installation

Follow these steps to get the add-on installed on your system:

1. Enable **Advanced Mode** in your Home Assistant user profile.
2. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
3. Search for "YC S3 Backup" add-on and click on it.
4. Click on the "INSTALL" button.

## How to use

1. Set the `aws_access_key`, `aws_secret_access_key`, and `bucket_name`. 
2. Optionally / if necessary, change  `storage_class`, and `delete_local_backups` and `local_backups_to_keep` configuration options.
3. Start the add-on to sync the `/backup/` directory to the configured `bucket_name` on YC S3. You can also automate this of course, see example below:

## Automation

To automate your backup creation and syncing to Amazon S3, add these two automations in Home Assistants `configuration.yaml` and change it to your needs:
```
automation:
  # create a full backup
  - id: backup_create_full_backup
    alias: Create a full backup every day at 4am
    trigger:
      platform: time
      at: "04:00:00"
    action:
      service: hassio.backup_full
      data:
        # uses the 'now' object of the trigger to create a more user friendly name (e.g.: '202101010400_automated-backup')
        name: "{{as_timestamp(trigger.now)|timestamp_custom('%Y%m%d%H%M', true)}}_automated-backup"
    - delay:
        hours: 0
        minutes: 30
        seconds: 0
        milliseconds: 0
    - service: hassio.addon_start
      data:
        addon: xxxxxxx_yc-s3-backup
```

The automation above first creates a full backup at 4am, and then at 4:15am syncs to Amazon S3 and if configured deletes local backups according to your configuration.

## Configuration

Example add-on configuration:

```
aws_access_key: AKXXXXXXXXXXXXXXXX
aws_secret_access_key: XXXXXXXXXXXXXXXX
bucket_name: my-bucket
storage_class: STANDARD
delete_local_backups: true
local_backups_to_keep: 3
```

### Option: `aws_access_key` (required)
AWS IAM access key used to access the S3 bucket.

### Option: `aws_secret_access_key` (required)
AWS IAM secret access key used to access the S3 bucket.

### Option: `bucket_name` (required)
Amazon S3 bucket used to store backups.


### Option: `storage_class` (optional, Default: STANDARD)
Yandex Cloud S3 storage class to use for the synced objects, when uploading files to S3. One of STANDARD, COLD, ICE For more information see https://cloud.yandex.ru/docs/storage/concepts/storage-class.

### Option: `delete_local_backups` (optional, Default: true)
Should the addon remove oldest local backups after syncing to your Amazon S3 Bucket? You can configure how many local backups you want to keep with the Option `local_backups_to_keep`. Oldest Backups will get deleted first.

### Option: `local_backups_to_keep` (optional, Default: 3)
How many backups you want to keep locally? If you want to disable automatic local cleanup, set `delete_local_backups` to false.



## Support

Usage of the addon requires knowledge of Yandex Cloud S3.
Under the hood it uses the aws cli version 1, specifically the `aws s3 sync` command.

## Thanks
This addon is fork  from https://github.com/thomasfr/hass-addons
