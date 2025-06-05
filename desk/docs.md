# JS script documentation

`thread-builder-js.hoon` library allows to run scripts written in JS. This document describes the API for it.

## Imports and exports

The interaction with the host environment is done in CommonJS style: import Urbit JS library by calling `require("urbit_thread")`. No other packages are available in the JS environment on Urbit: bundle dependencies into a single file with JS bundlers if necessary.

`thread-builder-js.hoon` expects that the provided JS code will export a function to call to `module.exports`. Here is an example of a JS script that prints to console:

```js
const urbit = require("urbit_thread");

module.exports = () => {
    console.log("Hello world!");
}
```

Importing `urbit` library is not strictly necessary if you will not call functions from it. The exported function will be called with no arguments.

## Built-in functions

In addition to usual printing functions in `console` object, the JS script execution environment comes with `fetch_sync` function for synchronous HTTP requests:

```js
/**
 * @typedef {{
 *      status: number,
 *      statusText: string,
 *      headers: Record<string, string>,
 *      body?: string
 * }} Response
 * 
 * @typedef {(url: string | URL, options: {
 *      method?: string,
 *      headers?: [string, string][] | Record<string, string>,
 *      body?: string
 * }) => Response} fetch_sync
 * @description Performs HTTP request synchronously
 */
```

It is also aliased with `fetch` function that wraps the return of `fetch_sync` with a `Promise` for ease of code portability:

```js
/**
 * @typedef {(url: string | URL, options: {
 *      method?: string,
 *      headers?: [string, string][] | Record<string, string>,
 *      body?: string
 * }) => Promise(Response)} fetch
 * @description Performs HTTP request synchronously, wraps result in Promise
 */
```

## `urbit-thread` library

These functions are defined in the root of the importable object and are used to interact with the JS script host.

```js
/**
 * @typedef {(path: string) => string} load_txt_file
 * @description Returns contents of a .txt file at a given path. The search is not global and is performed in the filesystem partition for JS threads
 */

/**
 * @typedef {(path: string, text: string) => void} store_txt_file
 * @description Stores contents of a .txt file at a given path relative to the JS script directory
 */

/**
 * @typedef {(seconds: number) => void} sleep
 * @description Sleep for a given amount of seconds, rounded down
 * 
 * @typedef {() => never} restart
 * @description Restart the script, discarding all state. Useful for scripts that run for a very long time and would otherwise spend all memory on urwasm event log
 */
```

These functions are used for interacting with Tlon Messenger app suite. `id: string` in DM-related functions is either a `@p` like `~sampel-palnet` or a groupchat ID which can be found in the URL of the groupchat. `Nest` string is the last element of a channel URL, e.g. in `https://example.com/apps/groups/groups/~halbex-palheb/uf-public/channels/chat/~halbex-palheb/general-4066` the `Nest` is `general-4066`.

```js
/**
 * @typedef {
 *      string
 *      | {italics: Inline[]}
 *      | {bold: Inline[]}
 *      | {strike: Inline[]}
 *      | {blockquote: Inline[]}
 *      | {ship: string}
 *      | {"inline-code": string}
 *      | {code: string}
 *      | {tag: string}
 *      | {break: null}
 *      | {block: {index: number, text: string}}
 *      | {link: {href: string, content: string}}
 *      | {task: {checked: boolean, content: Inline[]}}
 * } Inline
 */

/**
 * @typedef {
 *      {list: {type: string, items: Listing[], contents: Inline[]}}
 *      | {item: Inline[]}
 * } Listing
 */

/**
 * @typedef {
 *      {group: string}
 *      | {desk: {flag: string, where: string}}
 *      | {chan: {nest: string, where: string}}
 *      | {bait: {group: string, graph: string, where: string}}
 * } Cite
 */

/**
 * @typedef {
 *      {rule: null}
 *      | {cite: Cite}
 *      | {listing: Listing}
 *      | {code: {code: string, lang: string}}
 *      | {header: {tag: string, content: Inline[]}}
 *      | {image: {src: string, height: number, width: number, alt: string}}
 * } Block
 */

/**
 * @typedef {{block: Block} | {inline: Inline[]}} Verse
 */

/**
 * @typedef {Verse[]} Story
 */

/**
 * @typedef {string} Nest
 * @description Unique identifier of a TM channel
 */

/**
 * @typedef {content: Story, author: string, sent: number} Memo
 * @description Post contents with an author and a timestamp
 */

/**
 * @typedef {() => Nest[]} get_channels
 * @description Returns a list of all TM channels' identifiers you are currently in
 */

/**
 * @typedef {(nest: Nest, n: number) => {key: string, message: Memo}[]} get_channel-messages
 * @description Returns a list of N last messages in a given channel with their unique keys
 */

/**
 * @typedef {(id: string, n: number) => {key: string, message: Memo}[]} get_dm_messages
 * @description Returns a list of N last messages in a given chat with their unique keys
 */

/**
 * @typedef {(id: string, key: string) => Memo[]} get_dm_replies
 * @description Returns a list of replies to a DM message
 */

/**
 * @typedef {(nest: Nest, key: string) => Memo[]} get_channel_replies
 * @description Returns a list of replies to a channel post
 */

/**
 * @typedef {(nest: Nest) => string[]} get_channel_members
 * @description Returns a list of members in a channel
 */

/**
 * @typedef {(id: string) => string[]} get_groupchat_members
 * @description Returns a list of members in a groupchat
 */

/**
 * @typedef {(nest: Nest, ship: string) => string[]} get_roles
 * @description Returns a list of roles of a user in the group of a channel
 */

/**
 * @typedef {(nest: Nest, ship: string) => ()} invite_user_channel
 * @description Invite user to the group of a channel
 */

/**
 * @typedef {(id: string, ship: string) => ()} invite_user_groupchat
 * @description Invite user to a groupchat
 */

/**
 * @typedef {(nest: Nest, ship: string) => ()} kick_user_channel
 * @description Remove user from the group of a channel
 */

/**
 * @typedef {(nest: Nest, ship: string, role: string) => ()} give_role
 * @description Give role to a user in the group of a channel
 */

/**
 * @typedef {(nest: Nest, ship: string, role: string) => ()} remove_role
 * @description Remove role from a user in the group of a channel
 */

/**
 * @typedef {(nest: Nest, post: string) => ()} post_channel
 * @description Post a simple message in the channel, no formatting
 */

/**
 * @typedef {(id: string, post: string) => ()} send_dm
 * @description Send a simple DM in the channel, no formatting
 */

/**
 * @typedef {(nest: Nest, key: string, post: string) => ()} reply_channel
 * @description Reply to a message in a channel, no formatting
 */
```