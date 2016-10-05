rsync = require '../rsync'

module.exports = () ->
  atom.workspace.observeTextEditors (editor) ->
    editor.onDidSave () ->
      rsync.manual()
  rsync.manual()
