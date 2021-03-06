React = require 'react'

{ div, span, h3, a, table, tbody, tr, input, textarea } = React.DOM

extend = require 'react/lib/Object.assign'

td = () ->
  defs =
    padding: 2
    border: 'none'

  arguments[0].style = extend {}, defs, arguments[0].style

  React.DOM.td.apply @, arguments

CustomSelect = require '../taist/customSelect'

CardEditor = React.createFactory React.createClass
  getInitialState: ->
    isEditorActive: false
    selectedCard: null
    selectedLinkType: null
    highlightedLinkId: null

  onToggleEditor: ->
    @setState isEditorActive: not @state.isEditorActive

  onSelectCard: (selectedCard) ->
    @setState { selectedCard }

  onSelectLinkType: (selectedLinkType) ->
    @setState { selectedLinkType }

  onCreateLink: () ->
    if @state.selectedCard and @state.selectedLinkType
      @props.onCreateLink @state.selectedCard, @state.selectedLinkType
      @setState isEditorActive: false

  onRemoveLink: (linkId) ->
    @props.onRemoveLink? linkId

  render: ->
    prevType = ''

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
        if @props.error
          div {className: 'card-detail-data u-gutter u-clearfix'},
            div {}, 'Sorry, an error occured. We know about that and are preparing the fix now. Meanwhile, please try to re-login to Trello - the error should go then.'
        else
          table { style: width: '100%', border: 'none' },
            tbody { style: background: 'none' },

              tr {},
                td { style:
                  textAlign: 'right'
                  verticalAlign: 'middle'
                  width: 140
                  paddingRight: 12
                },
                  'This card'
                td {},
                  CustomSelect {
                    selectType: 'static'
                    onSelect: @onSelectLinkType
                    options: @props.linkTypes
                    placeholder: 'Select link type'
                  }

              tr {},
                td { style: textAlign: 'right', verticalAlign: 'middle', paddingRight: 12 }, 'Card'
                td {},
                  CustomSelect {
                    selectType: 'search'
                    onSelect: @onSelectCard
                    onChange: @props.onChange
                    placeholder: 'Start typing to find a card'
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

      unless @props.error
        div {},
          table { style: width: '100%', border: 'none' },
            tbody { style: background: 'none' },
              @props.linkedCards.map (card) =>
                tr {
                  key: "#{card.linkedCardId}-#{card.linkTypeName}"
                  onMouseEnter: =>
                    @setState highlightedLinkId: card.linkId
                  onMouseLeave: =>
                    if card.linkId is @state.highlightedLinkId
                      @setState highlightedLinkId: null
                },
                  td { style:
                    textAlign: 'right'
                    verticalAlign: 'middle'
                    width: 140
                    minWidth: 140
                    paddingRight: 12
                  },
                    if prevType isnt card.linkTypeName
                      prevType = card.linkTypeName
                    else
                      ''
                  td {},
                    a {
                      href: "/c/#{card.linkedCardId}"
                      style:
                        paddingLeft: 4
                        display: 'block'
                        width: '100%'
                        overflow: 'hidden'
                        height: '1.2rem'
                        textOverflow: 'ellipsis'
                    },
                      card.linkedCardName

                  td {
                    style:
                      textAlign: 'right'
                      verticalAlign: 'middle'
                      width: 20
                      minWidth: 20
                  },
                    a {},
                      span {
                        className: 'icon-sm icon-close'
                        onMouseDown: () =>
                          @onRemoveLink card.linkId
                        style:
                          color: 'salmon'
                          cursor: 'pointer'
                          display: if card.linkId is @state.highlightedLinkId then '' else 'none'
                      }

module.exports = CardEditor
