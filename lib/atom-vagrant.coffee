{CompositeDisposable} = require 'atom';

Rsync     = require './models/rsync'
Init      = require './models/init'
Up        = require './models/up'
Status    = require './models/status'
Provision = require './models/provision'
Suspend   = require './models/suspend'
Reload    = require './models/reload'
Halt      = require './models/halt'
Destroy   = require './models/destroy'

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
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:sync', -> Rsync()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:sync-auto-toggle', =>
      @toggleAutoSync()
      if @shouldAutoSync()
        Rsync()
    atom.workspace.observeTextEditors (editor) =>
      @subscriptions.add editor.onDidSave () =>
        if @shouldAutoSync()
          Rsync()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:init', -> Init()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:up', -> Up()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:status', -> Status()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:provision', -> Provision()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:suspend', -> Suspend()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:reload', -> Reload()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:halt', -> Halt()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:destroy', -> Destroy()

  toggleAutoSync: ->
    @autoSync = !@autoSync

  shouldAutoSync: ->
    return @autoSync

  deactivate: ->
    @subscriptions.dispose()
