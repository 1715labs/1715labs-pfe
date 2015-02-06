React = require 'react'
PromiseToSetState = require '../lib/promise-to-set-state'
ChangeListener = require '../components/change-listener'
PromiseRenderer = require '../components/promise-renderer'
auth = require '../api/auth'
handleInputChange = require '../lib/handle-input-change'
{Link} = require 'react-router'
apiClient = require '../api/client'
InPlaceForm = require '../components/in-place-form'
MarkdownEditor = require '../components/markdown-editor'

HandlePropChanges =
  componentDidMount: ->
    for prop, handler of @propChangeHandlers ? {}
      handler.call this, @props[prop]

  componentWillReceiveProps: (nextProps) ->
    for prop, handler of @propChangeHandlers ? {}
      unless nextProps[prop] is @props[prop]
        handler.call this, nextProps[prop]

ProjectEditPage = React.createClass
  displayName: 'EditProjectPage'

  mixins: [HandlePropChanges, PromiseToSetState]

  getDefaultProps: ->
    project: null

  getInitialState: ->
    workflows: []
    busy: false

  propChangeHandlers:
    project: (project) ->
      @promiseToSetState workflows: project.link 'workflows'

  render: ->
    handleProjectChange = handleInputChange.bind @props.project

    <ChangeListener target={auth}>{=>
      currentAndOwner = Promise.all [
        auth.checkCurrent()
        @props.project.link 'owner'
      ]

      <PromiseRenderer promise={currentAndOwner}>{(error, [currentUser, projectOwner] = []) =>
        if error?
          <p><code>{error.toString()}</code></p>

        else if projectOwner?
          if currentUser is projectOwner
            <ChangeListener target={@props.project}>{=>
              <InPlaceForm onSubmit={@handleSubmit}>
                Name<br />
                <input type="text" name="display_name" value={@props.project.display_name} onChange={handleProjectChange} /><br />

                Description<br />
                <MarkdownEditor name="description" value={@props.project.description} onChange={handleProjectChange} /><br />

                Introduction<br />
                <MarkdownEditor name="introduction" value={@props.project.introduction} onChange={handleProjectChange} /><br />

                Workflows<br />
                <ul>
                  {for workflow in @state.workflows
                    <ChangeListener key={workflow.id} target={workflow}>{=>
                      <li><Link to="edit-workflow" params={id: workflow.id}>{workflow.display_name}</Link></li>
                    }</ChangeListener>}
                </ul>

                <button type="submit" disabled={@state.busy or not @props.project.hasUnsavedChanges()}>Save</button><br />
                <button type="button" onClick={@handleDelete}>Delete this project</button><br />
              </InPlaceForm>
            }</ChangeListener>

          else
            <p>You don’t have permission to edit this project.</p>

        else
          <p>Checking permissions</p>
      }</PromiseRenderer>
    }</ChangeListener>

  handleSubmit: ->
    @setState busy: true, =>
      @props.project.save().then =>
        @setState busy: false

  handleDelete: ->
    if prompt('Enter REALLY to delete this project forever.')?.toUpperCase() is 'REALLY'
      @setState busy: true, =>
        @props.project.delete().then =>
          location.hash = '/build'

module.exports = React.createClass
  displayName: 'ProjectEditPageWrapper'

  render: ->
    <PromiseRenderer promise={apiClient.type('projects').get(@props.params.id)}>{(error, project) =>
      if error?
        <p><code>{error.toString()}</code></p>
      else if project?
        <ProjectEditPage project={project} />
      else
        <p>Loading project {@props.params.id}</p>
    }</PromiseRenderer>
