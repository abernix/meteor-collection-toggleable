af = Package['aldeed:autoform']
c2 = Package['aldeed:collection2']
SimpleSchema = Package['aldeed:simple-schema']?.SimpleSchema

defaults =
  toggleOn: 'toggle' # function
  toggleOff: 'untoggle' #function
  toggle: 'toggle'
  toggled: 'toggled'
  toggledAt: 'toggledAt'
  toggledBy: 'toggledBy'
  untoggledAt: 'untoggledAt'
  untoggledBy: 'untoggledBy'
  omit: false
  systemId: '0'

behaviour = (options = {}) ->
  check options, Object

  {toggleOn, toggleOff, toggle, toggled, toggledAt, toggledBy, untoggledAt, untoggledBy, omit, systemId} =
    _.defaults options, @options, defaults

  if c2?
    afDefinition = autoform:
      omit: true

    addAfDef = (definition) ->
      _.extend definition, afDefinition

    definition = {}

    def = definition[toggle] =
      optional: true
      type: Boolean

    addAfDef def if af?

    if toggledAt
      def = definition[toggledAt] =
        denyInsert: true
        optional: true
        type: Date

      addAfDef def if af?

    regEx = new RegExp "(#{SimpleSchema.RegEx.Id.source})|^#{systemId}$"

    if toggledBy
      def = definition[toggledBy] =
        denyInsert: true
        optional: true
        regEx: regEx
        type: String

      addAfDef def if af?

    if untoggledAt
      def = definition[untoggledAt] =
        denyInsert: true
        optional: true
        type: Date

      addAfDef def if af?

    if untoggledBy
      def = definition[untoggledBy] =
        denyInsert: true
        optional: true
        regEx: regEx
        type: String

      addAfDef def if af?

    @collection.attachSchema new SimpleSchema definition

  if omit
    beforeFindHook = (userId = systemId, selector = {}, options = {}) ->
      isSelectorId = _.isString(selector) or '_id' of selector
      unless options[toggled] or isSelectorId or selector[toggle]?
        selector = _.clone selector
        selector[toggle] =
          $exists: false

      @args[0] = selector
      return

    @collection.before.find beforeFindHook
    @collection.before.findOne beforeFindHook

  @collection.before.update (userId = systemId, doc, fieldNames, modifier,
    options) ->

    $set = modifier.$set ?= {}
    $unset = modifier.$unset ?= {}

    if $set[toggle] and doc[toggle]?
      return false

    if $unset[toggle] and not doc[toggle]?
      return false

    if $set[toggle] and not doc[toggle]?
      $set[toggle] = true

      if toggledAt
        $set[toggledAt] = new Date

      if toggledBy
        $set[toggledBy] = userId

      if untoggledAt
        $unset[untoggledAt] = true

      if untoggledBy
        $unset[untoggledBy] = true

    if $unset[toggle] and doc[toggle]?
      $unset[toggle] = true

      if toggledAt
        $unset[toggledAt] = true

      if toggledBy
        $unset[toggledBy] = true

      if untoggledAt
        $set[untoggledAt] = new Date

      if untoggledBy
        $set[untoggledBy] = userId

    if _.isEmpty $set
      delete modifier.$set

    if _.isEmpty $unset
      delete modifier.$unset

  isLocalCollection = @collection._connection is null

  @collection[toggleOn] = (selector, callback) ->
    return 0 unless selector

    modifier =
      $set: $set = {}

    $set[toggle] = true

    try
      if Meteor.isServer or isLocalCollection
        ret = @update selector, modifier, multi: true, callback

      else
        ret = @update selector, modifier, callback

    catch error
      if error.reason.indexOf 'Not permitted.' isnt -1
        throw new Meteor.Error 403, 'Not permitted. Untrusted code may only ' +
          "toggle documents by ID."

    if ret is false
      0
    else
      ret

  @collection[toggleOff] = (selector, callback) ->
    return 0 unless selector

    modifier =
      $unset: $unset = {}

    $unset[toggle] = true

    try
      if Meteor.isServer or isLocalCollection
        selector = _.clone selector
        selector[toggle] = true
        ret = @update selector, modifier, multi: true, callback

      else
        ret = @update selector, modifier, callback

    catch error
      if error.reason.indexOf 'Not permitted.' isnt -1
        throw new Meteor.Error 403, 'Not permitted. Untrusted code may only ' +
          "untoggle documents by ID."

    if ret is false
      0
    else
      ret

CollectionBehaviours.define 'toggleable', behaviour
