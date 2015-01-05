addonEntry =
  start: (_taistApi, entryPoint) ->
    _taistApi.log 'Addon started'

    require('./greetings/hello') _taistApi


module.exports = addonEntry
