/-  spider
/+  sio=strandio
/+  wasm=wasm-lia
/*  quick-js-wasm  %wasm  /quick-js-emcc/wasm
::
=,  strand=strand:spider
=*  cw  coin-wasm:wasm-sur:wasm
=*  lv  lia-value:lia-sur:wasm
=*  script-form  script-raw-form:lia-sur:wasm
=*  strand-form  strand-form-raw:rand
=*  yield  script-yield:lia-sur:wasm
=*  stub  !!
!:
::  Types, interfaces
::
=>  |%
    ::  typeless identity monad
    ::  even though it's typeless we still need the mold of the result
    ::  due to contravariant nesting rules of $-
    ::
    ++  mist
      |*  m=mold
      |=  [a=* b=$-(m *)]
      (slum b a)
    ::
    ++  get-bowl
      |=  tor=*
      ;;  (unit *)
      ;<  =acc  mist  tor
      ^-  (unit bowl:rand)
      bowl.acc
    ::
    ++  put-bowl
      |=  [owl=* tor=*]
      ^-  *
      ;<  [bol=bowl:rand =acc]  mist  [owl tor]
      ^-  ^acc
      acc(bowl `bol)
    ::
    ++  get-js-ctx
      |=  tor=*
      ;;  [run-u=@ ctx-u=@ fil-u=@]
      ;<  =acc  mist  tor
      ^-  [@ @ @]
      [run-u ctx-u fil-u]:acc
    ::  actual accumulator type of a raw noun to be stored in lia accumulator
    ::
    +$  acc
      $:  run-u=@
          ctx-u=@
          fil-u=@
          :: state=json  XX  not necessary?
          bowl=(unit bowl:rand)
      ==
    ::
    +$  acc-mold  *
    ++  arr  (arrows:wasm acc-mold)
    --
::
::  External call arrows
::
=>  |%
    ++  ext
      |%
      ::  (~ => [noun+bowl:rand ~])
      ::
      :: ++  get-bowl  (call-ext:arr %get-bowl ~)
      ::  ([noun+path ~] => ?(~ [octs+contents=octs ~]))
      ::
      ++  get-txt-file
        |=  pax=path
        (call-ext:arr %get-txt-file noun+pax ~)
      ::  ([noun+path noun+cord ~] => ~)
      ::
      ++  set-txt-file
        |=  [pax=path txt=cord]
        (call-ext:arr %set-txt-file noun+pax noun+txt ~)
      --
    ::  +fetch-thread: get a Spider thread by name from +call-ext:arr
    ::
    ++  fetch-thread
      =/  m  (strand (list lv))
      |=  name=term
      ^-  $-((list lv) (strand-form (list lv)))
      ?+    name  ~|(thread-not-defined+name !!)
          %get-bowl
        ::  (~ => [noun+bowl:rand ~])
        ::  does not need the argument
        ::
        |=  *
        ^-  form:m
        ;<  bol=bowl:rand  bind:m  get-bowl:sio
        (pure:m noun+bol ~)
      ::
          %get-txt-file
        ::  ([noun+path ~] => ?(~ [octs+contents=octs ~]))
        ::
        |=  l=(pole lv)
        ^-  form:m
        =*  prefix  %scripts
        ?>  ?=([[%noun p=*] ~] l)
        =+  ;;(pax=path p.l)
        ;<  bol=bowl:rand  bind:m  get-bowl:sio
        =/  bek=beak  [our %base %da now]:bol
        ;<  =riot:clay  bind:m
          (warp:sio p.bek q.bek ~ %sing %x r.bek [prefix pax])
        ::
        ?~  riot  (pure:m ~)
        ?.  =(%txt p.r.u.riot)
          ~&  >>>  [%not-a-txt pax]
          (pure:m ~)
        ?~  wan=(mole |.(!<(wain q.r.u.riot)))
          ~&  >>>  [%weird-txt pax]
          (pure:m ~)
        =/  str=cord  (of-wain:format u.wan)
        (pure:m octs+[(met 3 str) str] ~)
      ::
          %set-txt-file
        ::  ([noun+path noun+cord ~] => ~)
        ::
        |=  l=(pole lv)
        ^-  form:m
        =*  prefix  %scripts
        ?>  ?=([[%noun p=*] [%noun t=*] ~] l)
        =+  ;;([pax=path txt=cord] [p.l t.l])
        =/  wan=wain  (to-wain:format txt)
        =/  not=note-arvo  [%c [%info %base %& [prefix^pax %ins %txt !>(wan)]~]]
        (send-raw-card:sio [%pass / %arvo not])
      ==
    --
::
::  Thread builder helping functions
::
=>  |%
    ::  +malloc-write: allocate and immediately write `p` bytes of `q` atom
    ::
    ++  malloc-write
      |=  data=octs
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      ;<  ptr-u=@  try:m  (call-1 'malloc' p.data ~)
      ;<  ~        try:m  (memwrite ptr-u data)
      (return:m ptr-u)
    ::  +malloc-cord: allocate and write a null-terminated cord
    ::
    ++  malloc-cord
      |=  str=cord
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      (malloc-write +((met 3 str)) str)
    ::  +ring: complex call, with other calls inlined
    ::
    ++  ring
      |=  [func=cord args=(list $@(@ (script-form @ acc-mold)))]
      =/  m  (script:lia-sur:wasm (list @) acc-mold)
      ^-  form:m
      =,  arr
      =|  args-atoms=(list @)
      |-  ^-  form:m
      ?~  args  (call func (flop args-atoms))
      ?@  i.args  $(args t.args, args-atoms [i.args args-atoms])
      ;<  atom=@  try:m  i.args
      $(args t.args, args-atoms [atom args-atoms])
    ::  +ding: complex call-1
    ::
    ++  ding
      |=  [func=cord args=(list $@(@ (script-form @ acc-mold)))]
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ;<  out=(list @)  try:m  (ring func args)
      ?>  =(~ |1.out)
      (return:m -.out)
    ::  +js-eval: run JS code
    ::
    ++  js-eval
      |=  code=cord
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      ;<  acc=acc-mold  try:m  get-acc
      ::  [run-u=@ ctx-u=@ fil-u=@]
      ::
      =+  (get-js-ctx acc)
      ::
      =/  code-len  (met 3 code)
      ;<  code-u=@  try:m  (malloc-write +(code-len) code)
      ;<  res-u=@   try:m  (call-1 'QTS_Eval' ctx-u code-u code-len fil-u 0 0 ~)
      ;<  *         try:m  (call 'free' code-u ~)
      (return:m res-u)
    ::  +mayb-error: check is JSValue* is an exception
    ::
    ++  mayb-error
      |=  res-u=@
      =/  m  (script:lia-sur:wasm (unit cord) acc-mold)
      ^-  form:m
      =,  arr
      ;<  acc=acc-mold  try:m  get-acc
      =+  (get-js-ctx acc)
      ::
      ;<  err-u=@   try:m  (call-1 'QTS_ResolveException' ctx-u res-u ~)
      ?:  =(0 err-u)  (return:m ~)
      ;<  str-u=@   try:m  (call-1 'QTS_GetString' ctx-u err-u ~)
      ;<  str=cord  try:m  (get-c-string str-u)
      (return:m `str)
    ::  +get-c-string: load a null-terminated string
    ::
    ++  get-c-string
      |=  ptr=@
      =/  m  (script:lia-sur:wasm cord acc-mold)
      ^-  form:m
      =,  arr
      =/  len=@  0
      =/  cursor=@  ptr
      |-  ^-  form:m
      ;<  char=octs  try:m  (memread cursor 1)
      ?.  =(0 q.char)
        $(len +(len), cursor +(cursor))
      ;<  =octs  try:m  (memread ptr len)
      (return:m q.octs)
    ::  +get-js-string: load a JSValue-represented string
    ::
    ++  get-js-string
      |=  val-u=@
      =/  m  (script:lia-sur:wasm cord acc-mold)
      ^-  form:m
      =,  arr
      ;<  acc=acc-mold  try:m  get-acc
      =+  (get-js-ctx acc)
      ::
      ;<  str-u=@  try:m  (call-1 'QTS_GetString' ctx-u val-u ~)
      (get-c-string str-u)
    ::  +tem: cord to octs
    ::
    ++  tem
      |=  c=cord
      ^-  octs
      [(met 3 c) c]
    ::  +ret: render result type to (list lv)
    ::
    ++  ret
      =/  m  runnable:wasm
      |=  out=(each cord (pair cord cord))
      ^-  form:m
      %-  return:m
      ?-  -.out
        %&  ~[i32+& octs+(tem p.out)]
        %|  ~[i32+| octs+(tem p.p.out) octs+(tem q.p.out)]
      ==
    ::  +register-function: associate a function name with a magic number.
    ::  The magic number must be recognized by +qts-host-call-function.
    ::
    ++  register-function
      |=  [name=cord mag-w=@ obj-u=@]
      ::  return: (unit error=cord)
      ::
      =/  m  (script:lia-sur:wasm (unit cord) acc-mold)
      ^-  form:m
      =,  arr
      ;<  acc=acc-mold  try:m  get-acc
      =+  (get-js-ctx acc)
      ;<  nam-u=@  try:m  (malloc-cord name)
      ;<  res-u=@  try:m  (call-1 'QTS_NewFunction' ctx-u mag-w nam-u ~)
      ::
      ;<  err=(unit cord)  try:m  (mayb-error res-u)
      ?^  err  (return:m err)
      ::
      ;<  nam-val-u=@  try:m  (call-1 'QTS_NewString' ctx-u nam-u ~)  ::  free string value?
      ;<  undef-u=@    try:m  (call-1 'QTS_GetUndefined' ~)
      ;<  *            try:m
        %:  call  'QTS_DefineProp'
          ctx-u
          obj-u
          nam-val-u
          res-u
          undef-u  ::  get
          undef-u  ::  set
          0        ::  configurable
          1        ::  enumerable
          1        ::  has_value
          ~
        ==
      ::
      (return:m ~)
    ::  +main: JS code -> main script to run
    ::
    ++  main
      |=  code=cord
      =/  m  runnable:wasm
      ^-  form:m
      =,  arr
      =/  filename=cord  'script-eval.js'
      ;<  run-u=@    try:m  (call-1 'QTS_NewRuntime' ~)
      ;<  ctx-u=@    try:m  (call-1 'QTS_NewContext' run-u 0 ~)
      ;<  fil-u=@    try:m  (malloc-cord filename)
      =|  tor=acc
      =.  tor  tor(run-u run-u, ctx-u ctx-u, fil-u fil-u)
      ;<  ~          try:m  (set-acc tor)
      ;<  global-this-u=@  try:m  (call-1 'QTS_GetGlobalObject' ctx-u ~)
      ;<  undef-u=@        try:m  (call-1 'QTS_GetUndefined' ~)
      ;<  err=(unit cord)  try:m  (register-function 'require' 0 global-this-u)
      ?^  err  (ret |+[u.err 'make require'])
      ::  define `module` object
      ::
      ;<  *  try:m
        %:  ring  'QTS_DefineProp'
          ctx-u
          global-this-u
        ::
          %:  ding  'QTS_NewString'                       ::  property name
            ctx-u
            (malloc-cord 'module')
            ~
          ==
        ::
          (call-1 'QTS_NewObject' ctx-u ~)                ::  init value
          undef-u                                         ::  getter
          undef-u                                         ::  setter
          1                                               ::  configurable
          1                                               ::  enumerable
          1                                               ::  has value
          ~
        ==
      ::  define `console` object
      ::
      ;<  console-str-u=@  try:m
        %:  ding  'QTS_NewString'
          ctx-u
          (malloc-cord 'console')
          ~
        ==
      ::
      ;<  *  try:m
        %:  ring  'QTS_DefineProp'
          ctx-u
          global-this-u
        ::
          console-str-u
        ::
          (call-1 'QTS_NewObject' ctx-u ~)                ::  init value
          undef-u                                         ::  getter
          undef-u                                         ::  setter
          1                                               ::  configurable
          1                                               ::  enumerable
          1                                               ::  has value
          ~
        ==
      ::
      ;<  console-u=@  try:m
        (call-1 'QTS_GetProp' ctx-u global-this-u console-str-u ~)
      ::
      ;<  *  try:m  (register-function 'log' 1 console-u)
      ;<  *  try:m  (register-function 'error' 2 console-u)
      ;<  *  try:m  (register-function 'warn' 3 console-u)
      ;<  *  try:m  (register-function 'info' 4 console-u)
      ::
      ::  define fetch
      ::
      ;<  *  try:m  (register-function 'fetch_sync' 7 global-this-u)
      ;<  fun-u=@  try:m
        %-  js-eval
        '''
        var _fetch = function(url, options) {
          return new Promise((resolve, reject) => {
            const res = globalThis.fetch_sync(url, options);
            //console.log("_fetch");
            //console.log(res);
            //
            resolve({
              status: 200,                                      //  res.status,
              statusText: "OK",                                 //  res.statusText,
              headers: {"Content-Type": "application/json"},    //  res.headers,
              ok: true,
              text: () => Promise.resolve(res),                 //  res.body
              json: () => Promise.resolve(JSON.parse(res)),     //  res.body
            });
          });
        };
        _fetch
        '''
      ::
      ;<  *  try:m
        %:  ring  'QTS_DefineProp'
          ctx-u
          global-this-u
          (ding 'QTS_NewString' ctx-u (malloc-cord 'fetch') ~)
          fun-u
          undef-u  ::  get
          undef-u  ::  set
          0        ::  configurable
          1        ::  enumerable
          1        ::  has_value
          ~
        ==
      ::
      ::
      :: imports the interface library via require, exports a function to module.exports
      ::
      ;<  res-u=@          try:m  (js-eval code)
      ;<  err=(unit cord)  try:m  (mayb-error res-u)
      ?^  err  (ret |+[u.err 'failed to export the script function'])
      ;<  res-u=@          try:m
        %-  js-eval
        '''
        module.exports()
        '''
      ::
      :: ;<  dump-u=@  try:m  (call-1 'malloc' 4 ~)  ::  XX use scratch arena for things like that
      :: ;<  *         try:m
      ::   (call 'QTS_ExecutePendingJob' run-u ^~((sub (bex 32) 1)) dump-u ~)
      ::
      ;<  err=(unit cord)  try:m  (mayb-error res-u)
      ?^  err  (ret |+[u.err 'failed to call the exported function'])
      ;<  str=cord         try:m  (get-js-string res-u)
      (ret &+str)
    ::  +get-result: parse (list lv) to get result type.
    ::  Must roundtrip with +ret.
    ::
    ++  get-result
      |=  res=(pole lv)
      ^-  (each cord (pair cord cord))
      ?+  res  !!
        [[%i32 %&] [%octs o=octs] ~]  &+q.o.res
        [[%i32 %|] [%octs p=octs] [%octs q=octs] ~]  |+[q.p.res q.q.res]
      ==
    ::  +js-val-cord-compare: compare a JSValue* with a string from cord
    ::
    ++  js-val-cord-compare
      |=  [val-u=@ =cord]
      =/  m  (script:lia-sur:wasm ? acc-mold)
      ^-  form:m
      =,  arr
      ;<  acc=acc-mold  try:m  get-acc
      =+  (get-js-ctx acc)
      ::
      ;<  crd-u=@  try:m  (malloc-cord cord)
      ;<  str-u=@  try:m  (call-1 'QTS_NewString' ctx-u crd-u ~)
      ;<  is-eq=@  try:m  (call-1 'QTS_IsEqual' ctx-u val-u str-u 0 ~)  :: QTS_EqualOp_SameValue
      ;<  *        try:m  (call 'QTS_FreeValuePointer' ctx-u str-u ~)
      ;<  *        try:m  (call 'free' crd-u ~)
      (return:m !=(is-eq 0))
    ::  +make-error: create an Exception object with a custom message
    ::
    ++  make-error
      |=  txt=cord
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      ;<  acc=acc-mold  try:m  get-acc
      =+  (get-js-ctx acc)
      ::
      ;<  err-u=@  try:m  (call-1 'QTS_NewError' ctx-u ~)
      =/  field=cord  'message'
      ;<  *        try:m
        %:  ring  'QTS_SetProp'
          ctx-u
          err-u
          (ding 'QTS_NewString' ctx-u (malloc-cord field) ~)
          (ding 'QTS_NewString' ctx-u (malloc-cord txt) ~)
          ~
        ==
      ::
      (return:m err-u)
    ::  +urbit-thread-make-object: construct a JS object to be imported with
    ::  `require`. Returns a pointer to that object.
    ::  Every registered functions' magic number must be recognized by
    ::  +qts-host-call-function
    ::
    ++  urbit-thread-make-object
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      ;<  acc=acc-mold  try:m  get-acc
      =+  (get-js-ctx acc)
      ::
      ;<  undef-u=@        try:m  (call-1 'QTS_GetUndefined' ~)
      ;<  obj-u=@          try:m  (call-1 'QTS_NewObject' ctx-u ~)
      ::
      ;<  *  try:m  (register-function 'load_txt_file' 5 obj-u)
      ;<  *  try:m  (register-function 'store_txt_file' 6 obj-u)
      ::
      :: ;<  *  try:m  (register-function 'foo' 1 obj-u)
      ::
      (return:m obj-u)
    ::  +throw-error: returns a pointer to JSException
    ::
    ++  throw-error
      |=  err=cord
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      ;<  acc=acc-mold  try:m  get-acc
      =+  (get-js-ctx acc)
      (ding 'QTS_Throw' ctx-u (make-error err) ~)
    ::  +parse-path: friendly path parser, replaces .ext with /ext
    ::
    ++  parse-path
      |=  xap=cord
      |^  ^-  (unit path)
      (rush xap path-rule)
      ::
      ++  urs-ab-dotless
        %+  cook
          |=(a=tape (rap 3 ^-((list @) a)))
        (star ;~(pose nud low hep sig cab))
      ::
      ++  path-rule
        %+  sear
          |=  p=path
          ^-  (unit path)
          ?:  ?=([~ ~] p)  `~
          ?.  =(~ (rear p))  `p
          ~
        ;~  pfix
          ::  optional starting /
          ::
          (punt fas)
        ::::
          ::  foo/bar/baz.abc
          ::
          |-
          =*  this  $
          %+  knee  *path  |.  ~+
          ;~  pose
            ::  done
            ::
            (full (easy ~))
          ::::
            ::  foo.bar
            ::
            %+  cook  |=([a=@ta b=@ta] ~[a b])
            (full ;~(plug urs-ab-dotless ;~(pfix dot urs:ab)))
          ::::
            ::  foo | foo/...
            ::
            ;~(plug urs:ab ;~(pose (full (easy ~)) ;~(pfix fas this)))
          ==
        ==
      --
    ::  +return-undefined: return a pointer to a copy of `undefined` constant
    ::
    ::    apparently QuickJS crashes when it tries to free a constant pointer
    ::    return by QTS_GetUndefined and friends, so we duplicate a value
    ::    for safe return
    ::
    ++  return-undefined
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      ;<  acc=acc-mold  try:m  get-acc
      =+  (get-js-ctx acc)
      ;<  undef-const-u=@  try:m  (call-1 'QTS_GetUndefined' ~)
      (call-1 'QTS_DupValuePointer' ctx-u undef-const-u ~)
    ::
    --
::
::  Wasm & JS imports
::
=>  |%
    ++  throw-args
      |=  [name=cord got=@ need=@]
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      %-  throw-error
      %:  rap  3
        'Not enough arguments for function "'  name  '", got '
        (scot %ud got)  ', need at least '  (scot %ud need)
        ~
      ==
    ::
    ++  throw-path
      |=  xap=cord
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      %-  throw-error
      %:  rap  3
        'Invalid path: "'  xap  
        ~
      ==
    :: +require: NodeJS-like import interface
    ::
    ++  require
      |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      ?.  (gte argc-w 1)  (throw-args 'require' argc-w 1)
      ;<  is-urbit-thread=?  try:m  (js-val-cord-compare argv-u 'urbit_thread')
      ?:  is-urbit-thread  urbit-thread-make-object
      ::
      ::  ;<  is-foo-bar=?  try:m  (js-val-cord-compare argv-u 'foo_bar')
      ::  ?:  is-foo-bar  foo-bar-make-object
      ::  ...
      ::
      ::  If the string is not matched: throw error
      ::
      ;<  str=cord  try:m  (get-js-string argv-u)
      (throw-error (rap 3 'Name "' str '" not recognized by "require"' ~))
    ::
    ++  console-log
      |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      =|  strs=(list cord)
      |-  ^-  form:m
      ?:  =(argc-w 0)
        ~&  `@t`(rap 3 (join ' ' strs))
        return-undefined
      =.  argc-w  (dec argc-w)
      ;<  str=cord  try:m  (get-js-string (add (mul 8 argc-w) argv-u))
      $(strs [str strs])
    ::
    ++  console-error
      |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      =|  strs=(list cord)
      |-  ^-  form:m
      ?:  =(argc-w 0)
        ~&  >>>  `@t`(rap 3 (join ' ' strs))
        return-undefined
      =.  argc-w  (dec argc-w)
      ;<  str=cord  try:m  (get-js-string (add (mul 8 argc-w) argv-u))
      $(strs [str strs])
    ::
    ++  console-warn
      |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      =|  strs=(list cord)
      |-  ^-  form:m
      ?:  =(argc-w 0)
        ~&  >>  `@t`(rap 3 (join ' ' strs))
        return-undefined
      =.  argc-w  (dec argc-w)
      ;<  str=cord  try:m  (get-js-string (add (mul 8 argc-w) argv-u))
      $(strs [str strs])
    ::
    ++  load-txt-file
      |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      ?.  (gte argc-w 1)  (throw-args 'load_txt_file' argc-w 1)
      ;<  xap=cord  try:m  (get-js-string argv-u)
      ?~  pax=(parse-path xap)  (throw-path xap)
      ;<  res=(pole lv)  try:m  (get-txt-file:ext u.pax)
      ?~  res  (throw-error (rap 3 'No .txt file at path ' xap ~))
      ?>  ?=([[%octs p=octs] ~] res)
      (ding 'QTS_NewString' ctx-u (malloc-cord q.p.res) ~)
    ::
    ++  store-txt-file
      |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      ?.  (gte argc-w 2)  (throw-args 'store_txt_file' argc-w 2)
      ;<  xap=cord  try:m  (get-js-string argv-u)
      ;<  txt=cord  try:m  (get-js-string (add argv-u 8))  ::  sizeof JSValue == 8 in Wasm build of QuickJS
      ?~  pax=(parse-path xap)  (throw-path xap)
      =/  las=@ta  (rear u.pax)
      ?.  =(%txt las)
        (throw-error (rap 3 'Invalid path extension: want txt, got ' las ~))
      ;<  *         try:m  (set-txt-file:ext u.pax txt)
      return-undefined
    ::
    ++  host-fetch-url  ::  XX fake fetch to test Promises
      |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      ?.  (gte argc-w 2)  (throw-args 'fetch_sync' argc-w 2)
      (ding 'QTS_NewString' ctx-u (malloc-cord 'yes hello') ~)
    ::
    ::  +clock-time-get: WASI import to get time
    ::
    ++  clock-time-get
      |=  args=(pole cw)
      =/  m  (script:lia-sur:wasm (list cw) acc-mold)
      ^-  form:m
      ?>  ?=([[%i32 @] [%i64 @] [%i32 time-u=@] ~] args)
      =,  arr  =,  args
      :: ;<  l=(pole lv)   try:m  get-bowl:ext
      :: ?>  ?=([[%noun owl=*] ~] l)
      :: ;<  tor=acc-mold  try:m  get-acc
      :: =.  tor  (put-bowl owl.l tor)
      :: ;<  ~             try:m  (set-acc tor)
      ::
      =/  time  ;;  @da
        :: ;<  bol=bowl:rand  mist  owl.l
        :: now.bol
        *@da
      ::  WASI time is in ns
      ::
      =/  ntime  (mul 1.000.000 (unm:chrono:userlib time))
      ;<  ~  try:m  (memwrite time-u 8 ntime)
      (return:m i32+0 ~)
    ::  +qts-host-call-function: Wasm import to resolve JS imports
    ::
    ++  qts-host-call-function
      |=  args=(pole cw)
      =/  m  (script:lia-sur:wasm (list cw) acc-mold)
      ^-  form:m
      ?>  ?=  $:  [%i32 ctx-u=@]
                  [%i32 this-u=@]
                  [%i32 argc-w=@]
                  [%i32 argv-u=@]
                  [%i32 magic-w=@]
                  ~
              ==
          args
      ::
      =,  arr  =,  args
      ;<  acc=acc-mold  try:m  get-acc
      =/  arrow=$-([@ @ @ @] (script-form @ acc-mold))
        ?+  magic-w.args  !!
        ::  put JS imports here
        ::
          %0  require
          %1  console-log
          %2  console-error
          %3  console-warn
          %4  console-log
          %5  load-txt-file
          %6  store-txt-file
          %7  host-fetch-url
        ==
      ::
      ;<  val-u=@  try:m  (arrow ctx-u this-u argc-w argv-u)
      (return:m i32+val-u ~)
    ::  +emscripten-notify-memory-growth: ES-generated Wasm import to let
    ::  the host update its memory view. Urwasm memory model is not affected
    ::  by reallocations, so we do nothing.
    ::
    ++  emscripten-notify-memory-growth
      |=  *
      =/  m  (script:lia-sur:wasm (list cw) acc-mold)
      (return:m ~)
    --
::
=/  imports=(import:lia-sur:wasm acc-mold)
  :-  *acc
  =/  m  (script:lia-sur:wasm (list cw) acc-mold)
  %-  ~(gas by *(map (pair cord cord) $-((list cw) form:m)))
  :~
    ['wasi_snapshot_preview1'^'clock_time_get' clock-time-get]
    ['env'^'qts_host_call_function' qts-host-call-function]
    ['env'^'emscripten_notify_memory_growth' emscripten-notify-memory-growth]
  ==
::
::  Thread builder, (JS code => ?([%& p=result] [%| p=how q=where]))
::
=/  hint  %rand
|=  code=cord
=/  m  (strand (each cord (pair cord cord)))
^-  form:m
;<  bol=bowl:rand  bind:m  get-bowl:sio
~&  now.bol
=/  =seed:lia-sur:wasm  [quick-js-wasm (return:runnable:wasm ~) ~[~[octs+[0 'hello']] ~] imports]
=^  [yil=(yield (list lv)) *]  seed  (run:wasm &+(main code) seed hint)
|-  ^-  form:m
?-    -.yil
    %0
  ~&  shop.seed
  (pure:m (get-result p.yil))
::
    %1
  ~&  name.yil
  ;<  res=(list lv)  bind:m  ((fetch-thread name.yil) args.yil)
  ~&  shop.seed
  =^  [yil1=(yield (list lv)) *]  seed  (run:wasm |+res seed hint)
  $(yil yil1)
::
    %2
  (strand-fail:rand %thread-js ~['Wasm VM crashed'])
==