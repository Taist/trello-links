React = require 'react'

{ div, span, h3, a, table, tbody, tr, input } = React.DOM

td = () ->
  props = arguments[0]

  unless props.style?
    props.style = {}

  props.style.padding = 2
  props.style.border = 'none'

  React.DOM.td.apply @, arguments


CustomSelect = require '../taist/customSelect'

CardEditor = React.createFactory React.createClass
  getInitialState: ->
    isEditorActive: true
    selectedCard: null
    selectedLinkType: null

  onToggleEditor: ->
    @setState isEditorActive: not @state.isEditorActive

  onSelectCard: (selectedCard) ->
    @setState { selectedCard }

  onSelectLinkType: (selectedLinkType) ->
    @setState { selectedLinkType }

  onCreateLink: () ->
    if @state.selectedCard and @state.selectedLinkType
      @props.onCreateLink @state.selectedCard, @state.selectedLinkType

  render: ->
    console.log @props

    div { className: 'window-module' },
      div { className: 'window-module-title window-module-title-no-divider' },
        span { className: 'window-module-title-icon icon-lg icon-card' }
        h3 { style: display: 'inline-block' }, 'Card links'
        a {
          className: 'dark-hover'
          style:
            background: '#d6dadc'
            borderRadius: '3'
            color: '#8c8c8c'
            cursor: 'pointer'
            display: 'inline-block'
            padding: 2
            marginLeft: 12
        },
          if @state.isEditorActive
            span { className: 'icon-sm icon-remove', onClick: @onToggleEditor }
          else
            span { className: 'icon-sm icon-add', onClick: @onToggleEditor }

      if @state.isEditorActive
        table { style: width: '100%', border: 'none' },
          tbody { style: background: 'none' },

            tr {},
              td { style: textAlign: 'right', verticalAlign: 'middle', width: 100 }, 'This card'
              td {},
                CustomSelect {
                  selectType: 'static'
                  onSelect: @onSelectLinkType
                  options: @props.linkTypes
                }

            tr {},
              td { style: textAlign: 'right', verticalAlign: 'middle' }, 'Card'
              td {},
                CustomSelect {
                  selectType: 'search'
                  onSelect: @onSelectCard
                  onChange: @props.onChange
                }

            tr {},
              td {}
              td {},
                input {
                  type: 'submit'
                  className: 'primary confirm'
                  value: 'Link cards'
                  onMouseDown: @onCreateLink
                }

      div {}, 'Links will be here'

module.exports = CardEditor
