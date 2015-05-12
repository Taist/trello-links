React = require 'react'

{ div, input } = React.DOM

CustomSelectOption = React.createFactory React.createClass
  getInitialState: ->
    backgroundColor: ''

  onClick: ->
    @props.onSelect?(@props)

  onMouseEnter: ->
    @setState backgroundColor: '#ddd'

  onMouseLeave: ->
    @setState backgroundColor: ''

  render: ->
    div {
      onClick: @onClick
      onMouseEnter: @onMouseEnter
      onMouseLeave: @onMouseLeave
      style:
        padding: "2px 16px 2px 4px"
        backgroundColor: @state.backgroundColor
        whiteSpace: 'nowrap'
    }, @props.value

attrName = require('react/lib/DOMProperty').ID_ATTRIBUTE_NAME
dataAttrName = attrName.replace(/^data-/, '').replace /-./g, (a) -> a.slice(1).toUpperCase()

CustomSelect = React.createFactory React.createClass
  componentDidMount: ->
    document.addEventListener 'keyup', @onKeyUp
    document.addEventListener "mousedown", @onClickOutside

  componentWillUnmount: ->
    document.removeEventListener 'keyup', @onKeyUp
    document.removeEventListener "mousedown", @onClickOutside

  onClickOutside: (event) ->
    console.log 'dataAttrName'
    if event.target.dataset[dataAttrName]?.indexOf(@.getDOMNode().dataset[dataAttrName]) isnt 0
      #target is not a child of the component
      @onClose()

  onKeyUp: (event) ->
    if event.keyCode is 27
      @onClose()

  onClose: ->
    @setState { mode: 'view' }

  getInitialState: ->
    mode: 'view'
    options: []

  updateState: (newProps) ->
    @setState
      selected: newProps.selected
      # options: newProps.options or []
      # mode: 'view'

  componentWillMount: ->
    @updateState @props

  componentWillReceiveProps: (nextProps) ->
    @updateState nextProps

  onSelectOption: (selectedOption) ->
    @setState { value: selectedOption.value, mode: 'view' }
    @props.onSelect?(selectedOption)

  onChange: ->
    value = @refs.inputText?.getDOMNode().value
    @props.onChange?(value)
    .then (newOptions) =>
      console.log newOptions, @state.options
      @setState { options: newOptions, mode: 'select' }, =>
        console.log @state.options

  onClickOnInput: ->
    @setState { mode: 'select' }, =>

      optionRect = @refs.selectedOption?.getDOMNode().getBoundingClientRect()

      if optionRect
        container = @refs.optionsContainer.getDOMNode()
        containerRect = container.getBoundingClientRect()

        container.scrollTop = Math.max(
          optionRect.top - optionRect.height * 2 - containerRect.top , 0
        )

  render: ->
    console.log @state, @state.options.length

    controlWidth = @props.width or '100%'

    div {
      style:
        display: 'inline-block'
        width: controlWidth
    },
      div {}
        input {
          ref: 'inputText'

          onChange: @onChange
          onMouseDown: =>
            console.log 'onClick'
            @onClickOnInput()

          style:
            width: controlWidth
            boxSizing: 'border-box'
            marginBottom: 0
            backgroundColor: 'white'
        }

      if @state.mode is 'select' and @state.options.length > 0
        div {
          ref: 'optionsContainer'
          style:
            position: 'absolute'
            border: '1px solid silver'
            borderRadius: 3
            minWidth: controlWidth
            cursor: 'pointer'
            backgroundColor: 'white'
            zIndex: 1024
            maxHeight: 128
            overflowY: 'auto'
            overflowX: 'hidden'
            boxSizing: 'border-box'
        },

          @state.options.map (o) =>
            console.log o
            div { key: o.id }, CustomSelectOption {
              ref: if o.id is @state.selected?.id then 'selectedOption' else undefined
              id: o.id
              value: o.value
              onSelect: @onSelectOption
            }

module.exports = CustomSelect
