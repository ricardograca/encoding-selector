# View to show the encoding name in the status bar.
class EncodingStatusView extends HTMLDivElement
  initialize: (@statusBar, @encodings) ->
    @classList.add('encoding-status', 'inline-block')
    @encodingLink = document.createElement('a')
    @encodingLink.classList.add('inline-block')
    @encodingLink.href = '#'
    @appendChild(@encodingLink)
    @handleEvents()

  attach: ->
    @tile = @statusBar.addRightTile(priority: 11, item: this)

  handleEvents: ->
    @activeItemSubscription = atom.workspace.onDidChangeActivePaneItem =>
      @subscribeToActiveTextEditor()

    clickHandler = =>
      atom.commands.dispatch(atom.views.getView(@getActiveTextEditor()), 'encoding-selector:show')
      false
    @addEventListener('click', clickHandler)
    @clickSubscription = dispose: => @removeEventListener('click', clickHandler)

    @subscribeToActiveTextEditor()

  destroy: ->
    @activeItemSubscription?.dispose()
    @encodingSubscription?.dispose()
    @clickSubscription?.dispose()
    @configSubscription?.off()
    @tile?.destroy()

  getActiveTextEditor: ->
    atom.workspace.getActiveTextEditor()

  subscribeToActiveTextEditor: ->
    @encodingSubscription?.dispose()
    @encodingSubscription = @getActiveTextEditor()?.onDidChangeEncoding =>
      @updateEncodingText()
    @updateEncodingText()

  updateEncodingText: ->
    encoding = @getActiveTextEditor()?.getEncoding()
    if encoding?
      encoding = encoding.toLowerCase().replace(/[^0-9a-z]|:\d{4}$/g, '')
      @encodingLink.textContent = @encodings[encoding]?.status ? encoding
      @encodingLink.dataset.encoding = encoding
      @style.display = ''
    else
      @style.display = 'none'

module.exports = document.registerElement('encoding-selector-status', prototype: EncodingStatusView.prototype)
