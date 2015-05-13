Q = require 'q'

require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME = 'data-vrtl-reactid'

extend = require 'react/lib/Object.assign'

appData = {}

linkTypes = {
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
}

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
      console.log 'onCreateLink', currentCard, card, linkType

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
      .catch (error) ->
        console.log error

  helpers:
    prepareLinkTypes: () ->
      result = []
      for type, link of linkTypes
        result.push { id: "#{type}.out", value: link.outward }
        if link.outward isnt link.inward
          result.push { id: "#{type}.in", value: link.inward }

      result

module.exports = app
