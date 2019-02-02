# Borgmatic in a Docker container


## Overview

docker-borgmatic is a simple ephemeral container I wrote to provide a portable backup solution. borgmatic is a python based wrapper script for borgbackup.

The container supports specifying your settings in a declarative configuration file rather than having to put them all on the command-line, and borgmatic handles common errors.

Both borg and borgmatic are provided within the Alpine Edge base container. borg and borgmatic are sourced from the Python Package Index and the latest versions along with dependencies are installed using pip.



## Installation

### Installing the docker container
```bash
docker pull hobbsau/borgmatic:latest
```

### Required configuration directories and files
You will need to create the following files or directories on the backup source host.

Config Directory | Description 
 --- | --- 
/srv/backup/borgconf | Used to hold borg configuration data such as repo keyfile under a subdirectory keys/repokeyfile
/srv/backup/borgcache | Used to hold borg cache information and speeds up backups significantly
/srv/backup/borgmaticconf | Directory must include the borgmatic "config.yaml"
/home/user/.ssh | If using a remote SSH repo then you will also need to configure keys and any SSH config parameters for the remote host. This is typically stored in the user's .ssh directory.


### Sample "config.yaml" for borgmatic
```yaml
location:
    # List of source directories to backup. Globs are expanded.
    source_directories:
        - /home
        - /etc
        - /var/log/syslog*

    # Paths to local or remote repositories.
    repositories:
        - user@backupserver:sourcehostname.borg

    # Any paths matching these patterns are excluded from backups.
    exclude_patterns:
        - /home/*/.cache

retention:
    # Retention policy for how many backups to keep in each category.
    keep_daily: 7
    keep_weekly: 4
    keep_monthly: 6

consistency:
    # List of consistency checks to run: "repository", "archives", or both.
    checks:
        - repository
        - archives
```


## Usage
Ensure all directories and configuration files are available in the section above.

This docker container uses an entrypoint so any subsequent arguements to the docker run command will be treated as arguements to borgmatic itself.

### Example: Performing a backup 
You can run borgmatic and start a backup by invoking it without arguments:

```bash
docker run \
  --rm -t --name hobbsau-borgmatic \
  -e TZ=UTC
  -v /srv/backup/borgconf:/root/.config/borg \
  -v /srv/backup/borgcache:/cache \
  -v /srv/backup/borgmaticconf:/root/.config/borgmatic \
  -v /home/user/.ssh:/root/.ssh:ro \
  -v /backuplocation1:/backup/backuplocation1 \
  -v /backuplocation2:/backup/backuplocation2 \
  -v /backuplocationN:/backup/backuplocationN \
  hobbsau/borgmatic --verbosity 1
```

### Example: Listing backup archives
```bash
docker run \
  --rm -t --name hobbsau-borgmatic \
  -e TZ=UTC
  -v /srv/backup/borgconf:/root/.config/borg \
  -v /srv/backup/borgcache:/cache \
  -v /srv/backup/borgmaticconf:/root/.config/borgmatic \
  -v /home/user/.ssh:/root/.ssh:ro \
  -v /backuplocation1:/backup/backuplocation1 \
  -v /backuplocation2:/backup/backuplocation2 \
  -v /backuplocationN:/backup/backuplocationN \
  hobbsau/borgmatic --list
```

### Initialisation

Before you can create backups with borgmatic, you first need to initialise a
Borg repository so you have a destination for your backup archives. (But skip
this step if you already have a Borg repository.) To create a repository, run
a command like the following:

```bash
borgmatic --init --encryption repokey
```

This uses the borgmatic configuration file you created above to determine
which local or remote repository to create, and encrypts it with the
encryption passphrase specified there if one is provided. Read about [Borg
encryption
modes](https://borgbackup.readthedocs.io/en/latest/usage/init.html#encryption-modes)
for the menu of available encryption modes.

Also, optionally check out the [Borg Quick
Start](https://borgbackup.readthedocs.org/en/latest/quickstart.html) for more
background about repository initialization.

Note that borgmatic skips repository initialization if the repository already
exists. This supports use cases like ensuring a repository exists prior to
performing a backup.

If the repository is on a remote host, make sure that your local user has
key-based SSH access to the desired user account on the remote host.



## Autopilot

If you want to run borgmatic automatically, say once a day, the you can
configure a job runner to invoke it periodically.

### cron

If you're using cron, download the [sample cron
file](https://raw.githubusercontent.com/hobbsAU/docker-borgmatic/master/borg_cron).
Then, from the directory where you downloaded it:

```bash
sudo mv borgmatic /etc/cron.d/borgmatic
sudo chmod +x /etc/cron.d/borgmatic
```

You can modify the cron file if you'd like to run borgmatic more or less frequently.



## Issues

Please open an issue if you find a problem or wish to request a feature. PRs are welcome.


