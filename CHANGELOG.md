## 0.1.0 - First Release
* Every feature added
* Every bug fixed


## 0.2.0 - Second Release
* Widened project scope to move from controlling Vagrant syncing to managing Vagrant machines.
* Renamed to `atom-vagrant`

# 0.3.0 - Git Integration
* Plugin now uses Atoms internal GitRepository class to monitor when the active branch is changed and resync.

# 0.4.0 -
* Plugin now only activates if it can find a VagrantFile in the project root directory.

# 0.4.1 - Removed a bug regarding finding the Vagrantfile
* Previously was done asynchronously.
