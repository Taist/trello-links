defaultConfig =
  subtree: true
  childList: true

class DOMObserver
  mutationObserver: null
  isActive: no
  observers: {}

  processedOnce: []

  checkForAction: (selector, observer, container) ->
    nodesList = container.querySelectorAll selector
    matchedElems = Array.prototype.slice.call nodesList
    matchedElems.forEach (elem) =>
      if elem and @processedOnce.indexOf(elem) < 0
        @processedOnce.push elem
        observer.action elem

  constructor: (props) ->
    @config = props?.observerConfig ? defaultConfig
    @mutationObserver = new MutationObserver (mutations) =>
      mutations.forEach (mutation) =>
        for selector, observer of @observers
          @checkForAction selector, observer, mutation.target

  activateMainObserver: ->
    unless @isActive
      @isActive = yes
      target = document.querySelector 'body'
      @mutationObserver.observe target, @config

  waitElement: (selector, action) ->
    @activateMainObserver()
    observer = { selector, action }
    @observers[selector] = observer
    @checkForAction selector, observer, document.querySelector 'body'

module.exports = DOMObserver
