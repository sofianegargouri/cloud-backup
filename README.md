# Local Cloud Backup

This script allows you to backup a local folder on a remote cloud storage.

## Getting started

You will need Ruby (at least 3.3) up and running.
If you're new to this and using UNIX, I would recommend using [RVM](https://rvm.io/rvm/install).

```sh
# Clone the repository or get it through zip
git clone https://github.com/sofianegargouri/cloud-backup.git

# Get into the folder
cd cloud-backup

# Setup your config.yaml
cp config.example.yaml config.yaml

# Install dependencies
bundle install

# Start the script
ruby main.rb
```

### Creating a service

```sh
# In /etc/systemd/system/cloud-backup.service
[Unit]
Description=Cloud Backup Ruby Script
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/bin/env ruby /path/to/cloud-backup/main.rb
Group=YOUR_GROUP    # Optional: you can remove if you want to run as sudo
Restart=always
RestartSec=5
Type=simple
User=YOUR_USER      # Optional: you can remove if you want to run as sudo
WorkingDirectory=/path/to/cloud-backup

[Install]
WantedBy=multi-user.target
```

Then run `sudo systemctl daemon-reload`. Enable the service using `sudo systemctl enable cloud-backup.service` and start it with `sudo systemctl start cloud-backup.service`.


## Storage services supported

- Google Cloud Storage
