app = require './app'

Q = require 'q'
React = require 'react'
insertAfter = require './helpers/insertAfter'

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

      renderData =
        onChange: (query = '') ->
          if query.length < 3
            return Q.resolve []

          url = "https://trello.com/1/search?query=#{query}"
          url += '&partial=true&modelTypes=cards&card_board=true&card_list=true&card_stickers=true&elasticsearch=true'

          Q.when $.ajax url
          .then (result) ->
            result.cards.map (card) -> { id: card.shortLink, value: card.name }
          .catch (error) ->
            console.log error

      React.render CardEditor( renderData ), container

module.exports = addonEntry
