{BufferedProcess} = require 'atom'
notifier = require './notifier'

module.exports = vagrant =
  cmd: (args, options) ->
    options = @assignDefaultsToCmdOptions(options)
    new Promise (resolve, reject) =>
      output = ''
      process = new BufferedProcess
        command: atom.config.get('vagrant.vagrantPath') ? 'vagrant'
        args: args
        options: options
        stdout: (data) -> output += data.toString()
        stderr: (data) -> output += data.toString()
        exit: (code) =>
          if code == 0
            options.success output
            resolve output
          else if code == 1
            options.error output
            reject output
      process.onWillThrowError (errorObject) ->
        notifier.addError 'An error occurred.'
        reject 'An error occurred.'

  assignDefaultsToCmdOptions: (options) ->
    options = options || {}
    options.env = options.env || process.env.path
    options.cwd = options.cwd || atom.project.getPaths()[0]
    options.success = options.success || (output) -> notifier.addSuccess output
    options.error = options.error || (output) -> notifier.addError output
    return options

  rsync: ->
    notifier.addInfo 'Syncing project, this may take a while...'
    vagrant.cmd(['rsync'], {
      success: (output) ->
        notifier.addSuccess @formatVagrantRsyncSuccessMessage(output)
      error: (output) ->
        notifier.addError @formatVagrantRsyncErrorMessage(output)
    })

  formatVagrantRsyncSuccessMessage: (output) ->
    return 'Vagrant machine synced successfully.'

  formatVagrantRsyncErrorMessage: (output) ->
    return 'Vagrant machine could not be synced.'

  init: ->
    vagrant.cmd(['init'], {
      success: (output) ->
        notifier.addSuccess @formatVagrantInitSuccessMessage(output)
      error: (output) ->
        notifier.addError @formatVagrantInitErrorMessage(output)
    })

  formatVagrantInitSuccessMessage: (output) ->
    return output

  formatVagrantInitErrorMessage: (output) ->
    return output

  up: ->
    vagrant.cmd(['up'], {
      success: (output) =>
        notifier.addSuccess @formatVagrantUpSucessMessage(output)
      error: (output) ->
        notifier.addError @formatVagrantUpErrorMessage(output)
    })

  formatVagrantUpSucessMessage: (output) ->
    return output

  formatVagrantUpErrorMessage: (output) ->
    return output

  status: ->
    vagrant.cmd(['status'], {
      success: (output) =>
        notifier.addSuccess @formatVagrantStatusSucessMessage(output)
      error: (output) ->
        notifier.addError @formatVagrantStatusErrorMessage(output)
    })

  formatVagrantStatusSucessMessage: (output) ->
    return output

  formatVagrantStatusErrorMessage: (output) ->
    return output

  provision: ->
    vagrant.cmd(['provision'], {
      success: (output) =>
        notifier.addSuccess @formatVagrantProvisionSucessMessage(output)
      error: (output) ->
        notifier.addError @formatVagrantProvisionErrorMessage(output)
    })

  formatVagrantProvisionSucessMessage: (output) ->
    return output

  formatVagrantProvisionErrorMessage: (output) ->
    return output

  suspend: ->
    vagrant.cmd(['suspend'], {
      success: (output) =>
        notifier.addSuccess @formatVagrantSuspendSucessMessage(output)
      error: (output) ->
        notifier.addError @formatVagrantSuspendErrorMessage(output)
    })

  formatVagrantSuspendSucessMessage: (output) ->
    return output

  formatVagrantSuspendErrorMessage: (output) ->
    return output

  reload: ->
    vagrant.cmd(['reload'], {
      success: (output) =>
        notifier.addSuccess @formatVagrantReloadSucessMessage(output)
      error: (output) ->
        notifier.addError @formatVagrantReloadErrorMessage(output)
    })

  formatVagrantReloadSucessMessage: (output) ->
    return output

  formatVagrantReloadErrorMessage: (output) ->
    return output

  halt: ->
    vagrant.cmd(['halt'], {
      success: (output) =>
        notifier.addSuccess @formatVagrantHaltSucessMessage(output)
      error: (output) ->
        notifier.addError @formatVagrantHaltErrorMessage(output)
    })

  formatVagrantHaltSucessMessage: (output) ->
    return output

  formatVagrantHaltErrorMessage: (output) ->
    return output

  destroy: ->
    vagrant.cmd(['destroy', '--force'], {
      success: (output) =>
        notifier.addSuccess @formatVagrantDestroySucessMessage(output)
      error: (output) ->
        notifier.addError @formatVagrantDestroyErrorMessage(output)
    })

  formatVagrantDestroySucessMessage: (output) ->
    return output

  formatVagrantDestroyErrorMessage: (output) ->
    return output
