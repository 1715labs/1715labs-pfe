Model = require '../data/model'
Store = require '../data/store'
subjectsStore = require './subjects'

class Classification extends Model
  subject: ''

  constructor: ->
    window.classification = this
    super
    @annotations ?= []

  save: ->
    console.log 'Saving', JSON.stringify this
    postClassification = new Promise (resolve, reject) ->
      console?.info 'POST /classifications', JSON.stringify this
      @update _saving: true
      setTimeout resolve, 1000

    postClassification.then =>
      @update _saving: false

module.exports = window.classificationsStore = new Store
  root: '/classifications'
  type: Classification

  # Map a project ID to a classification ID:
  inProgress: {}

  'classification:create': (project) ->
    @inProgress[project] = subjectsStore.fetch({project}).then ([subject]) =>
      @inProgress[project] = @create
        subject: subject.id
        workflow: subject.workflow

  'classification:annotate': (classification, task) ->
    classification.annotations.push {task}
    classification.emitChange()

  'classification:annotation:update': (classification, annotation, answer) ->
    annotation.answer = answer
    classification.emitChange()

  'classification:annotation:abort': (classification, annotation) ->
    classification.annotations.pop() # TODO: Test.
    classification.emitChange()

  # This is a hack until there's an annotations store and a marks store.
  findClassificationAndAnnotationForMark: (mark) ->
    for project, classification of @inProgress when classification.annotations?
      for annotation in classification.annotations when annotation.marks?
        if mark in annotation.marks
          return {classification, annotation}

  'classification:annotation:mark:update': (mark, changes) ->
    {classification} = @findClassificationAndAnnotationForMark mark
    mark.update changes
    classification.emitChange()

  'classification:annotation:mark:delete': (mark) ->
    {classification, annotation} = @findClassificationAndAnnotationForMark mark
    markIndex = annotation.marks.indexOf mark
    annotation.marks.splice markIndex, 1
    classification.emitChange()
