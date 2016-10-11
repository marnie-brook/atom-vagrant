# Vagrant package

# Done

- Provide an easier way to sync projects without using system listeners. (0.1.0)
- Extend package to handle Vagrant machines rather than just syncing files. (0.2.0)
- Respond to changing branches in git. (0.3.0)
- Only enable commands if a VagrantFile exists in project. (0.4.0)

# To Do
- Provide an option to run `vagrant provision` after changing branches in git.
- Format all data returned from `vagrant` CLI commands
- Queue actions if they are already being executed when requested
- Provide information on currently executing command(s) in the status bar
- Provide an easy way to see whether or not a vagrant machine is in sync
