/-  *spider
/+  thread-builder-js
::
^-  thread
|=  *
%-  thread-builder-js
'''
const ub = require("urbit_thread");
module.exports = () => {
  res = ub.pals.get_leeches()
  return res;
};
'''