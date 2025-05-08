/-  spider
/+  strandio
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
::
=>  |%
    ::  typeless identity monad
    ::  even though it's typeless we still need the mold of the result
    ::  due to contravariant nesting rules of $-
    ++  mist
      |*  m=mold
      |=  [a=* b=$-(m *)]
      (slum b a)
    ::
    ++  get-bowl
      |=  tor=*
      ;;  (unit *)
      ;<  =acc  mist  tor
      bowl.acc
    ::
    +$  acc-mold  *
    ::
    ::  actual accumulator type of a raw noun to be stored in lia accumulator
    +$  acc
      $:  run-u=@
          ctx-u=@
          fil-u=@
          state=json
          bowl=(unit bowl:rand)
      ==
    ::
    ++  m  (script:lia-sur:wasm (list cw) acc-mold)
    ++  arr  (arrows:wasm acc-mold)
    ++  clock-time-get
      |=  args=(pole cw)
      ^-  form:m
      ?>  ?=([[%i32 @] [%i64 @] [%i32 time-u=@] ~] args)
      =,  arr  =,  args
      ;<  acc=acc-mold  try:m  get-acc
      ?~  bol=(get-bowl acc)  ::  XX call-ext to update the bowl
        ;<  ~  try:m  (memwrite time-u 8 0)
        (return:m i32+0 ~)
      ::
      =/  time  ;;  @da
        ;<  owl=bowl:rand  mist  u.bol
        now.owl
      ::
      ::  WASI time is in ns
      =/  ntime  (mul 1.000.000 (unm:chrono:userlib time))
      ;<  ~  try:m  (memwrite time-u 8 ntime)
      (return:m i32+0 ~)
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
          %0  stub  ::  require
        ==
      ::
      ;<  val-u=@  try:m  (arrow ctx-u this-u argc-w argv-u)
      (return:m i32+val-u ~)
    ::
    ::  we don't need to update our memory view
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
=>  |%
    ++  main
      |=  code=cord
      =/  m  runnable:wasm
      ^-  form:m
      =,  arr
      stub
    ::
    ++  fetch-thread
      |=  name=term
      ^-  $-((list lv) (strand-form (list lv)))
      stub  ::  switch on the name
    ::
    ++  get-result
      |=  res=(pole lv)
      ^-  (each cord cord)
      ?>  ?=([[%i32 loob=@] [%octs o=octs] ~] res)
      ?-  =(loob.res &)
        %&  &+q.o.res
        %|  |+q.o.res
      ==
    --
=/  hint  %rand
|=  code=cord
=/  m  (strand (each cord cord))
^-  form:m
=/  =seed:lia-sur:wasm  [quick-js-wasm (return:runnable:wasm ~) ~ imports]
=^  [yil=(yield (list lv)) *]  seed  (run:wasm &+(main code) seed hint)
|-  ^-  form:m
?:  ?=(%2 -.yil)  !!  ::  strand-fail:rand?
?:  ?=(%0 -.yil)  (pure:m (get-result p.yil))
::
::  %1
;<  res=(list lv)  bind:m  ((fetch-thread name.yil) args.yil)
=^  [yil1=(yield (list lv)) *]  seed  (run:wasm |+res seed hint)
$(yil yil1)