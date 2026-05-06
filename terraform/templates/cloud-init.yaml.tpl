#cloud-config
# Target platform: Oracle Linux 8, aarch64 (VM.Standard.A1.Flex)
# Package manager: dnf (OL8 default — do NOT use apt-get or yum)

# Upgrade all OS packages at first boot before installing dolt.
package_upgrade: true

# Write the dolt systemd unit file before runcmd executes.
write_files:
  - path: /etc/systemd/system/dolt-server.service
    owner: root:root
    permissions: "0644"
    content: |
      [Unit]
      Description=Dolt SQL Server
      After=network.target

      [Service]
      User=dolt
      WorkingDirectory=/var/lib/dolt/databases/doltdb
      ExecStart=/usr/local/bin/dolt sql-server --host 0.0.0.0
      Restart=always
      RestartSec=5
      KillSignal=SIGTERM
      SendSIGKILL=no

      [Install]
      WantedBy=multi-user.target

# All install steps run in runcmd (NOT bootcmd) so that network is available.
runcmd:
  # Install dolt — pinned to v1.87.0 (never use releases/latest).
  - curl -L https://github.com/dolthub/dolt/releases/download/v1.87.0/install.sh | sudo bash

  # Create the dolt system user with a home directory under /var/lib/dolt.
  - useradd -r -m -d /var/lib/dolt dolt

  # Configure dolt identity for the dolt OS user.
  - sudo -u dolt /usr/local/bin/dolt config --global --add user.email "dolt@localhost"
  - sudo -u dolt /usr/local/bin/dolt config --global --add user.name "dolt"

  # Create and initialise the database directory that dolt sql-server serves.
  # dolt sql-server requires WorkingDirectory to be an initialised dolt repo.
  - sudo -u dolt mkdir -p /var/lib/dolt/databases/doltdb
  - [ sh, -c, "cd /var/lib/dolt/databases/doltdb && sudo -u dolt /usr/local/bin/dolt init" ]

  # Open port 3306 in the OS firewall (firewalld is enabled by default on OL8).
  - firewall-offline-cmd --add-port=3306/tcp

  # Reload systemd so the new unit file is recognised.
  - systemctl daemon-reload

  - [ sh, -c, "cd /var/lib/dolt/databases/doltdb && sudo -u dolt /usr/local/bin/dolt sql -q \"CREATE USER 'root'@'%' IDENTIFIED BY '${dolt_db_password}'; GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;\"" ]

  # Enable and start the dolt server service.
  - systemctl enable dolt-server
  - systemctl start dolt-server

  # Reload the firewall
  - systemctl restart firewalld
