{CompositeDisposable} = require 'atom';

RsyncManual = require './models/sync-manual'
RsyncAuto = require './models/sync-auto'

module.exports =
  config:
    vagrantPath:
      type: 'string'
      default: 'vagrant'
      description: 'Where is your vagrant?'

  subscriptions: null

  autoSync: false

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant-rsync:sync', -> RsyncManual()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant-rsync:sync-auto-toggle', =>
      @toggleAutoSync()
      if @shouldAutoSync()
        RsyncManual()
    atom.workspace.observeTextEditors (editor) =>
      @subscriptions.add editor.onDidSave () =>
        if @shouldAutoSync()
          RsyncManual()

  toggleAutoSync: ->
    @autoSync = !@autoSync

  shouldAutoSync: ->
    return @autoSync

  deactivate: ->
    @subscriptions.dispose()
