#!/bin/sh

/opt/Upsource/bin/upsource.sh configure \
    --logs-dir=$UPSOURCE_LOGS_DIR \
    --temp-dir=$UPSOURCE_TEMP_DIR \
    --data-dir=$UPSOURCE_DATA_DIR \
    --backups-dir=$UPSOURCE_BACKUPS_DIR

echo "Starting wizard configuration..."
printf "#Wizard Configured Settings\n" \
	> /opt/Upsource/conf/internal/wizard-configured.properties

if ! [ -z "$UPSOURCE_LICENSE_USER_NAME" -o -z "$UPSOURCE_LICENSE_KEY" ]; then
  printf "Setting up:\n- license user name (\"$UPSOURCE_LICENSE_USER_NAME\")\n- license key: (\"$UPSOURCE_LICENSE_KEY\")\n"
  printf "%s\n%s\n" \
    "service.upsource-frontend.license-user-name=$UPSOURCE_LICENSE_USER_NAME" \
    "service.upsource-frontend.license-key=$UPSOURCE_LICENSE_KEY" \
    >> /opt/Upsource/conf/internal/wizard-configured.properties
fi

printf "wizard.configuration.finished=true" \
	>> /opt/Upsource/conf/internal/wizard-configured.properties

printf "Finished setting up the wizard.\n"
cat /opt/Upsource/conf/internal/wizard-configured.properties