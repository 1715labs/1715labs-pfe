counterpart = require 'counterpart'
React = require 'react'
{Markdown} = (require 'markdownz').default

counterpart.registerTranslations 'en',
  acknowledgements:
   pageContent: '''
    ## How to Acknowledge the Zooniverse in Papers

    If you’ve collected research from a Zooniverse project, we request that you acknowledge Zooniverse in any publications. To do so, please use the following text:

    *This publication uses data generated via the Zooniverse.org platform, development of which was supported by a Global Impact Award from Google, and by the Alfred P. Sloan Foundation.*

    You can find a list of publications written using the Zooniverse on the Publications tab (link).

    If you have any questions about how to acknowledge the Zooniverse, such as referencing a particular individual or custom code, get in touch (link).
'''

module.exports = React.createClass
  displayName: 'Acknowledgements'

  componentDidMount: ->
    document.documentElement.classList.add 'on-secondary-page'

  componentWillUnmount: ->
    document.documentElement.classList.remove 'on-secondary-page'

  render: ->
    <Markdown>{counterpart "acknowledgements.pageContent"}</Markdown>
