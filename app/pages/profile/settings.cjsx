React = require 'react'
ChangeListener = require '../../components/change-listener'
auth = require '../../api/auth'
PromiseRenderer = require '../../components/promise-renderer'
counterpart = require 'counterpart'
Translate = require 'react-translate-component'
AccountInformation = require './account-information'
CustomizeProfile = require './customize-profile'

counterpart.registerTranslations 'en',
  userSettingsPage:
    header: "Settings"
    nav:
      accountInformation: "Account Information"
      customizeProfile: "Customize Profile"

UserSettingsPage = React.createClass
  displayName: 'UserSettingsPage'

  getInitialState: ->
    activeTab: "account-information"

  render: ->
    <div className="secondary-page settings-page">
      <h2><Translate content="userSettingsPage.header" /></h2>
      <div className="settings-content">
        <aside className="secondary-page-side-bar settings-side-bar">
          <nav>
            <button
              type="button"
              className="secret-button settings-button"
              style={fontWeight: "700" if @state.activeTab is 'account-information'}
              onClick={@showTab.bind(null, 'account-information')}>
                <Translate content="userSettingsPage.nav.accountInformation" />
              </button>
            <button
              type="button"
              className="secret-button settings-button"
              style={fontWeight: "700" if @state.activeTab is 'customize-profile'}
              onClick={@showTab.bind(null, 'customize-profile')}>
                <Translate content="userSettingsPage.nav.customizeProfile" />
              </button>
          </nav>
        </aside>
        <section className="settings-tab-content">
          {if @state.activeTab is 'account-information'
            <AccountInformation user={@props.user} />
          else if @state.activeTab is 'customize-profile'
            <CustomizeProfile user={@props.user} />}
        </section>
      </div>
    </div>

  showTab: (tab) ->
    event.preventDefault()
    @setState activeTab: tab


module.exports = React.createClass
  displayName: 'UserSettingsPageWrapper'

  render: ->
    <ChangeListener target={auth} handler={=>
      <PromiseRenderer promise={auth.checkCurrent()} then={(user) =>
        if user?
          <ChangeListener target={user} handler={=>
            <UserSettingsPage user={user} />
          } />
        else
          <div className="content-container">
            <p>You’re not signed in.</p>
          </div>
      } />
    } />
