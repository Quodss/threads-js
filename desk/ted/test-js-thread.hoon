/-  spider
/+  thread-builder-js
::
=,  strand=strand:spider
=;  ted
  =/  m  (strand vase)
  |=  *
  ^-  form:m
  ;<  res=(each cord (pair cord cord))  bind:m  ted
  (pure:m !>(res))
::
%-  thread-builder-js
'''
const ub = require("urbit_thread");
module.exports = () => {
  console.log('store the file')
  ub.store_txt_file('foo/bax.txt', 'Test');
  console.log('read the file')
  let txt = ub.load_txt_file('foo/bax.txt');
  return txt;
};
'''