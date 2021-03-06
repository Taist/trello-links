app = require './app'

Q = require 'q'
React = require 'react'
insertAfter = require './helpers/insertAfter'

CardEditor = require './react/trello/cardEditor'

container = null

addonEntry =
  start: (_taistApi, entryPoint) ->
    window._app = app
    app.init _taistApi

    DOMObserver = require './helpers/domObserver'
    app.elementObserver = new DOMObserver()

    app.exapi.getCompanyData('trelloLinks')
    .then (trelloLinks) ->
      app.helpers.setTrelloLinks trelloLinks

      app.elementObserver.waitElement '.card-detail-window', (detailWindow) ->

        container = document.createElement 'div'
        container.className = 'taist'

        insertAfter container, detailWindow.querySelector '.card-detail-data'

        if matches = location.href.match /\/c\/([^\/]+)\//
          currentCardId = matches[1]
          currentCardName = detailWindow.querySelector('.js-card-title').innerText
        currentCard = { id: currentCardId, value: currentCardName }

        renderData =
          onChange: (query = '') ->
            if query.length < 3
              return Q.resolve []

            url = "https://trello.com/1/search?query=#{query}"
            url += '&partial=true&modelTypes=cards&card_board=true&card_list=true&card_stickers=true&elasticsearch=true'

            Q.when $.ajax url
            .then (result) ->
              result.cards
              .filter (card) -> card.shortLink isnt currentCard.id
              .map (card) -> { id: card.shortLink, value: card.name }
            .catch (error) ->
              console.log error

          linkTypes: app.helpers.prepareLinkTypes()

          currentCard: currentCard

          onCreateLink: (card, linkType) ->
            app.actions.onCreateLink currentCard, card, linkType
            .then (linkedCards) ->
              renderData.linkedCards = linkedCards
              React.render CardEditor( renderData ), container

          onRemoveLink: (linkId) ->
            app.actions.onRemoveLink currentCard, linkId
            .then (linkedCards) ->
              renderData.linkedCards = linkedCards
              React.render CardEditor( renderData ), container
            .catch (error) ->
              console.log error

        renderData.linkedCards = app.helpers.getCardLinks currentCard.id

        React.render CardEditor( renderData ), container
    .catch (error) ->
      app.api.log "TAIST ADDON ERROR !!! TRELLO !!! #{error.stack.replace /\n/g, ' '}"
      React.render CardEditor( { error } ), container

module.exports = addonEntry
