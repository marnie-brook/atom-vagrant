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
Fs        = require 'fs'

module.exports =
  config:
    vagrantPath:
      type: 'string'
      default: 'vagrant'
      description: 'Where is your vagrant?'

  subscriptions: null

  autoSync: false

  vagrantFileExists: false

  activate: (state) ->
    @findVagrantFile()
    if !@vagrantFileExists
      return
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:sync', -> Rsync()
    # For auto-syncing we need to listen to save events from text editors in this
    # workspace.
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
    # Handle changing of git repositories
    for repo in atom.project.getRepositories()
      if repo
        @subscriptions.add repo.onDidChangeStatuses () =>
          if @shouldAutoSync()
            Rsync()
        @subscriptions.add repo.onDidChangeStatus ({path, status}) =>
          if @shouldAutoSync() and path is atom.workspace.getActivePaneItem()
            Rsync()

  findVagrantFile: ->
    path = atom.project.getPaths()[0]
    if typeof path isnt 'string'
      return
    dir = Fs.readdirSync path
    for filePath in dir
      if filePath.toLowerCase() == 'vagrantfile'
        @vagrantFileExists =  true
        return

  toggleAutoSync: ->
    @autoSync = !@autoSync

  shouldAutoSync: ->
    return @autoSync

  deactivate: ->
    if @subscriptions
      @subscriptions.dispose()
