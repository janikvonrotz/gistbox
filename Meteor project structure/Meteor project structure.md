# Meteor project structure

The Meteor project structure (MPS) is a proposal for a simple file and folder naming specification. 

There are several basic distinctions when building a Meteor project structure. First there is a **client**, **server** and an **imports** folder. All folders have specific naming rules and differ in their structure.

Global restrictions are applied to all folders:

* Non-npm-package-import sources are always `index.js` files.
* Every first-level subfolder contains an `index.js` file.
* A subfolder depth of three is the limit.
* Everything which is not defined in this guide must be according to the [Meteor code style guide]( https://guide.meteor.com/code-style.html).

Important paradigms:

* Modularity is key when designing a structure.
* A module is a namespace reserved for an entity.

Requirements:

* UI: React
* Local state: Redux
* Remote state: Meteor publications

## client

Restrictions:

* Component file names are PascalCase.
* Folder and module names are lower case.
* CSS files can be placed anywhere.

Folders and files:

* `actions/` Redux methods to dispatch actions.
  * `core.js` Application actions.
  * `[modules].js` Module actions.
* `core/` App react components.
* `main.js` Client startup.
* `main.html` Contains the render target for the react-dom mount and static header tags.
* `MainLayout.js` Is the main template of the app.
* `[modules]/` Module react components.
* `reducers/` Redux state reducers.
  * `[state].js` Filename is equal to the state name.
* `users/` User react components.

React component naming:

* `[Entity].js` Single entity react component.
* `[Entity]List.js` React list view component.
* `[Entity]Search.js` React search form component.
* `[Entity][Suffix]Container.js` React component container.

## imports

Folders and files:

* `collections/` Mongo collections.
  * `[Modules].js` Collection definitions.
* `schemas/` Schemas.
  * `[Module].js` Schema definitions.
* `helpers/` Helper functions for client and server.
* `translations/` Translation sets.
  * `[language].js` Contains a translated language set.

## server

Server restrictions:

* Folder and module names are lower case.

Folders and files:

* `actions/` Server only methods.
  * `[modules].js` Module specific actions.
* `methods/` Meteor methods.
  * `[modules].js` Module Meteor methods.
* `pubication/s` Meteor publications.
  * `[modules].js` Module Meteor publications.
* `main.js` Server startup.
* `seeds.js` Contains database seed sets.
* `accounts.js` User account configurations.

Publications and methods naming:

Component -> Publication  
`PostList` -> `posts.list`  
`Post` -> `posts.item`

Action -> Method  
`Update post` -> `posts.update`  
`Remove post` -> `posts.remove`  
`Insert post` -> `posts.insert` 