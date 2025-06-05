/-  *spider
/+  thread-builder-js
::
^-  thread
|=  *
%-  thread-builder-js
'''
const ub = require("urbit_thread");
module.exports = () => {
  res = fetch_sync("google.com");
  return res.body;
};
'''