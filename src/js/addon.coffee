app = require './app'

insertAfter = require './helpers/insertAfter'

React = require 'react'
CardEditor = require './react/trello/cardEditor'

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    DOMObserver = require './helpers/domObserver'
    app.elementObserver = new DOMObserver()

    app.elementObserver.waitElement '.card-detail-window', (detailWindow) ->

      container = document.createElement 'div'
      container.className = 'taist'

      insertAfter container, detailWindow.querySelector '.card-detail-data'

      React.render CardEditor(), container

module.exports = addonEntry
