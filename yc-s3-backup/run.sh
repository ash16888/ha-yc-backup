#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on:  S3 Backup
# ==============================================================================
#bashio::log.level "debug"

bashio::log.info "Starting Yandex Cloud S3 Backup..."

bucket_name="$(bashio::config 'bucket_name')"
storage_class="$(bashio::config 'storage_class' 'STANDARD')"
delete_local_backups="$(bashio::config 'delete_local_backups' 'true')"
local_backups_to_keep="$(bashio::config 'local_backups_to_keep' '3')"
monitor_path="/backup"
jq_filter=".backups|=sort_by(.date)|.backups|reverse|.[$local_backups_to_keep:]|.[].slug"
datetime=$(date "+%d-%m-%Y")
filename=$(find "$monitor_path" -type f -name "*.tar" -mmin -60 -print0 | xargs -0 ls -t | head -1)

export AWS_ACCESS_KEY_ID="$(bashio::config 'aws_access_key')"
export AWS_SECRET_ACCESS_KEY="$(bashio::config 'aws_secret_access_key')"
export AWS_DEFAULT_REGION=ru-central1
### Rename backup file
if [ ! -z "$filename" ]; then
  mv "$filename" "$monitor_path/${datetime}.tar"
fi
sleep 10

bashio::log.debug "Using AWS CLI version: '$(aws --version)'"
bashio::log.debug "Command: 'aws s3 sync --endpoint-url=https://storage.yandexcloud.net/  $monitor_path s3://$bucket_name/ --no-progress  --storage-class $storage_class'"
aws s3 sync --endpoint-url=https://storage.yandexcloud.net/  $monitor_path s3://"$bucket_name"/ --no-progress  --storage-class "$storage_class"

if bashio::var.true "${delete_local_backups}"; then
    bashio::log.info "Will delete local backups except the '${local_backups_to_keep}' newest ones."
    backup_slugs="$(bashio::api.supervisor "GET" "/backups" "false" "$jq_filter")"
    bashio::log.debug "Backups to delete: '$backup_slugs'"

    for s in $backup_slugs; do
        bashio::log.info "Deleting Backup: '$s'"
        bashio::api.supervisor "DELETE" "/backups/$s"
    done
else
    bashio::log.info "Will not delete any local backups since 'delete_local_backups' is set to 'false'"
fi

bashio::log.info "Finished YC S3 Backup."
