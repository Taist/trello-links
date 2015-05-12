React = require 'react'

{ div, span, h3, a } = React.DOM

CardEditor = React.createFactory React.createClass
  getInitialState: ->
    isEditorActive: false

  onToggleEditor: ->
    @setState isEditorActive: not @state.isEditorActive

  render: ->
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
        div {}, 'Editor'

      div {}, 'Links will be here'

module.exports = CardEditor
