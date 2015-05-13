Q = require 'q'

require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME = 'data-vrtl-reactid'

extend = require 'react/lib/Object.assign'

appData =
  trelloLinks: {}

  linkTypes:
    relates:
      name: 'Relates'
      outward: 'relates to'
      inward: 'relates to'
    duplicate:
      name: 'Duplicate'
      outward: 'duplicates'
      inward: 'is duplicated by'
    blocked:
      name: 'Blocked'
      outward: 'blocks'
      inward: 'is blocked by'
    cloners:
      name: 'Cloners'
      outward: 'clones'
      inward: 'is cloned by'


app =
  api: null
  exapi: {}


  init: (api) ->
    app.api = api

    app.exapi.setUserData = Q.nbind api.userData.set, api.userData
    app.exapi.getUserData = Q.nbind api.userData.get, api.userData

    app.exapi.setCompanyData = Q.nbind api.companyData.set, api.companyData
    app.exapi.getCompanyData = Q.nbind api.companyData.get, api.companyData

    app.exapi.setPartOfCompanyData = Q.nbind api.companyData.setPart, api.companyData
    app.exapi.getPartOfCompanyData = Q.nbind api.companyData.getPart, api.companyData

    app.exapi.updateCompanyData = (key, newData) ->
      app.exapi.getCompanyData key
      .then (storedData) ->
        updatedData = {}
        extend updatedData, storedData, newData
        app.exapi.setCompanyData key, updatedData
        .then ->
          updatedData

  actions:
    onCreateLink: (currentCard, card, linkType) ->
      master = currentCard
      slave = card

      [ dummy, linkName, linkDirection ] = linkType.id.match /^(.+)\.(in|out)$/

      if linkDirection is 'in'
        [ master, slave ] = [ slave, master ]

      linkId = "#{master.id}-#{slave.id}-#{linkName}"
      linkData =
        id: linkId
        masterName: master.value
        slaveName: slave.value
      console.log linkData

      app.exapi.setPartOfCompanyData 'trelloLinks', linkId, linkData
      .then () ->
        appData.trelloLinks[linkId] = linkData
        app.helpers.getCardLinks currentCard.id
      .catch (error) ->
        console.log error

    onRemoveLink: (currentCard, linkId) ->
      app.exapi.setPartOfCompanyData 'trelloLinks', linkId, null
      .then () ->
        delete appData.trelloLinks[linkId]
        app.helpers.getCardLinks currentCard.id
      .catch (error) ->
        console.log error

  helpers:
    setTrelloLinks: (trelloLinks) ->
      appData.trelloLinks = trelloLinks

    getCardLinks: (cardId) ->
      result = []
      for id, link of appData.trelloLinks
        direction = null
        [ masterId, slaveId, linkType ] = id.split('-')

        if masterId is cardId
          direction = 'outward'
          linkedCardId = slaveId
          linkedCardName = link.slaveName

        else if slaveId is cardId
          direction = 'inward'
          linkedCardId = masterId
          linkedCardName = link.masterName

        if direction
          result.push
            linkId: id
            linkTypeName: appData.linkTypes[linkType][direction]
            linkedCardId: linkedCardId
            linkedCardName: linkedCardName

      result.sort (a, b) ->
        if a.linkTypeName <= b.linkTypeName then 0 else 1

      result

    prepareLinkTypes: () ->
      result = []
      for type, link of appData.linkTypes
        result.push { id: "#{type}.out", value: link.outward }
        if link.outward isnt link.inward
          result.push { id: "#{type}.in", value: link.inward }

      result

module.exports = app
