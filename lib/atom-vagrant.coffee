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
notifier  = require './notifier'
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
    @subscriptions = new CompositeDisposable
    @findVagrantFile()
    if !@vagrantFileExists
      @setupNoVagrantCommandListeners()
      return
    @setupVagrantCommandListeners()

  setupNoVagrantCommandListeners: ->
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:sync-auto-toggle', => @notifyNoVagrantFound()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:sync', => @notifyNoVagrantFound()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:init', => @notifyNoVagrantFound()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:up', => @notifyNoVagrantFound()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:status', => @notifyNoVagrantFound()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:provision', => @notifyNoVagrantFound()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:suspend', => @notifyNoVagrantFound()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:reload', => @notifyNoVagrantFound()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:halt', => @notifyNoVagrantFound()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:destroy', => @notifyNoVagrantFound()
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:search', =>
      @findVagrantFile()
      if (@vagrantFileExists)
        @subscriptions.dispose()
        @setupVagrantCommandListeners()
      else
        @notifyNoVagrantFound()

  notifyNoVagrantFound: ->
    notifier.addError('The Vagrant command could not be ran as no VagrantFile was found.\nYou can run `vagrant:search` to try again.')

  setupVagrantCommandListeners: ->
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:sync', -> Rsync()
    # For auto-syncing we need to listen to save events from text editors in this
    # workspace.
    @subscriptions.add atom.commands.add 'atom-workspace', 'vagrant:sync-auto-toggle', => @handleAutoSyncToggle()
    atom.workspace.observeTextEditors (editor) =>
      @subscriptions.add editor.onDidSave ({path}) =>
        if @shouldAutoSync() and @fileIsInProject(path)
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
    @setGitRepositoryListeners()

  handleAutoSyncToggle: ->
    @toggleAutoSync()
    if @shouldAutoSync()
      Rsync()

  fileIsInProject: (filePath) ->
    projectPath = atom.project.getPaths()[0]
    return filePath.indexOf(projectPath) == 0

  setGitRepositoryListeners: ->
    if !@usingGitRepository()
      return
    for repo in atom.project.getRepositories()[0]
      @subscriptions.add repo.onDidChangeStatuses () =>
        if @shouldAutoSync()
          Rsync()
      @subscriptions.add repo.onDidChangeStatus ({path, pathStatus}) =>
        if @shouldAutoSync() and path == atom.workspace.getActivePaneItem()
          Rsync()

  usingGitRepository: ->
    return !!atom.project.getRepositories()[0]

  findVagrantFile: ->
    path = atom.project.getPaths()[0]
    if typeof path isnt 'string'
      return
    dir = Fs.readdirSync path
    for filePath in dir
      if !@filePathIsVagrantFile(filePath)
        continue
      @vagrantFileExists = true
      return

  filePathIsVagrantFile: (filePath) ->
    return filePath.toLowerCase() == 'vagrantfile'

  toggleAutoSync: ->
    @autoSync = !@autoSync

  shouldAutoSync: ->
    return @autoSync

  deactivate: ->
    @subscriptions.dispose()
