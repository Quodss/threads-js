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
  console.log('begin script');
  console.log('store the file');
  ub.store_txt_file('foo/test.txt', 'Test file content overwrite #5');
  console.log('read the file');
  let txt = ub.load_txt_file('foo/test.txt');
  return txt;
};
'''