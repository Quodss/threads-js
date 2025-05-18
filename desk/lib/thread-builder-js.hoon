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
    ++  m  (script:lia-sur:wasm (list cw) acc-mold)
    ++  arr  (arrows:wasm acc-mold)
    --
::
::  External call arrows
::
=>  |%
    ++  get-bowl  (call-ext:arr %get-bowl ~)  ::  (~ => [noun+bowl:rand ~])
    --
::
::  Thread builder helping functions
::  Monadic interface `m` can be Wasm interface or thread interface,
::  depending on the context.
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
      ;<  nam-u=@  try:m  (malloc-write +((met 3 name)) name)
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
      =/  filename-len  (met 3 filename)
      ;<  run-u=@    try:m  (call-1 'QTS_NewRuntime' ~)
      ;<  ctx-u=@    try:m  (call-1 'QTS_NewContext' run-u 0 ~)
      ;<  fil-u=@    try:m  (malloc-write +(filename-len) filename)
      =|  tor=acc
      =.  tor  tor(run-u run-u, ctx-u ctx-u, fil-u fil-u)
      ;<  ~          try:m  (set-acc tor)
      ;<  global-this-u=@  try:m  (call-1 'QTS_GetGlobalObject' ctx-u ~)
      ;<  undef-u=@        try:m  (call-1 'QTS_GetUndefined' ~)
      ;<  err=(unit cord)  try:m  (register-function 'require' 0 global-this-u)
      ?^  err  (ret |+[u.err 'make require'])
      ;<  *  try:m
        %:  ring  'QTS_DefineProp'
          ctx-u
          global-this-u
        ::
          %:  ding  'QTS_NewString'                       ::  property name
            ctx-u
            (malloc-write +((met 3 'module')) 'module')   ::  char*
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
      ::
      ;<  res-u=@          try:m  (js-eval code)  :: imports the interface library via require, exports a function to module.exports
      ;<  err=(unit cord)  try:m  (mayb-error res-u)
      ?^  err  (ret |+[u.err 'failed to export the script function'])
      ;<  res-u=@          try:m
        %-  js-eval
        '''
        let _res = module.exports();
        _res
        '''
      ::
      ;<  err=(unit cord)  try:m  (mayb-error res-u)
      ?^  err  (ret |+[u.err 'failed to call the exported function'])
      ;<  str=cord         try:m  (get-js-string res-u)
      (ret &+str)
    ::  +fetch-thread: get a Spider thread by name from +call-ext:arr
    ::
    ++  fetch-thread
      =/  m  (strand (list lv))
      |=  name=term
      ^-  $-((list lv) (strand-form (list lv)))
      ?+    name  ~|(%thread-not-defined !!)
          %get-bowl
        ::  does not need the argument
        ::
        |=  *
        ^-  form:m
        ;<  bol=bowl:rand  bind:m  get-bowl:sio
        (pure:m noun+bol ~)
      ::
      ==
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
      ;<  crd-u=@  try:m  (malloc-write +((met 3 cord)) cord)
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
          (ding 'QTS_NewString' ctx-u (malloc-write +((met 3 field)) field) ~)
          (ding 'QTS_NewString' ctx-u (malloc-write +((met 3 txt)) txt) ~)
          ~
        ==
      ::
      (return:m err-u)
    ::  +urbit-thread-make-object: construct a JS object to be imported with
    ::  `require`. Returns a pointer to that object.
    ::
    ++  urbit-thread-make-object
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      stub
    --
::
::  Wasm & JS imports
::
=>  |%
    :: +require: NodeJS-like import interface
    ::
    ++  require
      |=  [ctx-u=@ this-u=@ argc-w=@ argv-u=@]
      =/  m  (script:lia-sur:wasm @ acc-mold)
      ^-  form:m
      =,  arr
      ?>  (gte argc-w 1)
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
      %:  ding
        'QTS_Throw'
        ctx-u
        (make-error (rap 3 'Name "' str '" not recognized by "require"' ~))
        ~
      ==
    ::  +clock-time-get: WASI import to get time
    ::
    ++  clock-time-get
      |=  args=(pole cw)
      ^-  form:m
      ?>  ?=([[%i32 @] [%i64 @] [%i32 time-u=@] ~] args)
      =,  arr  =,  args
      ;<  l=(pole lv)   try:m  get-bowl
      ~!  l
      ?>  ?=([[%noun owl=*] ~] l)
      ;<  tor=acc-mold  try:m  get-acc
      =.  tor  (put-bowl owl.l tor)
      ;<  ~             try:m  (set-acc tor)
      ::
      =/  time  ;;  @da
        ;<  bol=bowl:rand  mist  owl.l
        now.bol
      ::  WASI time is in ns
      ::
      =/  ntime  (mul 1.000.000 (unm:chrono:userlib time))
      ;<  ~  try:m  (memwrite time-u 8 ntime)
      (return:m i32+0 ~)
    ::  +qts-host-call-function: Wasm import to resolve JS imports
    ::
    ++  qts-host-call-function
      |=  args=(pole cw)
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
        ==
      ::
      ;<  val-u=@  try:m  (arrow ctx-u this-u argc-w argv-u)
      (return:m i32+val-u ~)
    ::  +emscripten-notify-memory-growth: ES-generated Wasm import to let
    ::  the host update its memory view. Urwasm memory model is not affected
    ::  by reallocations, so we do nothing.
    ::
    ++  emscripten-notify-memory-growth
      |=  args=(pole cw)
      (return:m ~)
    --
::
=/  imports=(import:lia-sur:wasm acc-mold)
  :-  *acc-mold
  =/  m  (script:lia-sur:wasm (list cw) acc-mold)
  %-  malt
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
=/  =seed:lia-sur:wasm  [quick-js-wasm (return:runnable:wasm ~) ~ imports]
=^  [yil=(yield (list lv)) *]  seed  (run:wasm &+(main code) seed hint)
|-  ^-  form:m
?:  ?=(%2 -.yil)  (strand-fail:rand %thread-js ~[>'Wasm VM crashed'<])
?:  ?=(%0 -.yil)  (pure:m (get-result p.yil))
::
::  %1
;<  res=(list lv)  bind:m  ((fetch-thread name.yil) args.yil)
=^  [yil1=(yield (list lv)) *]  seed  (run:wasm |+res seed hint)
$(yil yil1)