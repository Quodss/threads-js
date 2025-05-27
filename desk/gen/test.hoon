/+  wasm=wasm-lia
/+  parser=wat-parser-lia
::
=/  wasm-bin=octs
  %-  parser
  """
  (module
    (import "env" "ext" (func $ext (result i32)))
    (export "foo" (func $foo))
    (func $foo 
      loop $outer
        loop $inner
          call $ext
          br_if $outer
        end
      end
    )
  )
  """
::
:-  %say  |=  *  :-  %noun
::
=*  cw  coin-wasm:wasm-sur:wasm
=*  lv  lia-value:lia-sur:wasm
=*  yield  script-yield:lia-sur:wasm
::
=/  env-ext
  |=  *
  =/  m  (script:lia-sur:wasm (list cw) *)
  =/  arr  (arrows:wasm *)
  =,  arr
  ~&  %calling-ext
  ;<  res=(list lv)  try:m  (call-ext %foo ~)
  ?^  res
    ~&  ext+1
    (return:m i32+1 ~)
  ~&  ext+0
  (return:m i32+0 ~)
::
=/  imports=(import:lia-sur:wasm)
  :-  ~
  =/  m  (script:lia-sur:wasm (list cw) *)
  %-  ~(gas by *(map (pair cord cord) $-((list cw) form:m)))
  :~
    ['env'^'ext' env-ext]
  ==
::
=/  main
  =/  m  runnable:wasm
  ^-  form:m
  =/  arr  (arrows:wasm *)
  =,  arr
  ;<  *  try:m  (call 'foo' ~)
  (return:m ~)
::
=/  =seed:lia-sur:wasm  [wasm-bin (return:runnable:wasm ~) ~ imports]
=/  flag  %rand
=/  b1=[[yil=(yield (list lv)) *] seed=seed:lia-sur:wasm]  (run:wasm &+main seed flag)
=/  b2=[[yil=(yield (list lv)) *] seed=seed:lia-sur:wasm]  (run:wasm |+~[i32+0 i32+0] seed.b1 flag)
=/  b3=[[yil=(yield (list lv)) *] seed=seed:lia-sur:wasm]  (run:wasm |+~[i32+0 i32+0] seed.b2 flag)
=/  b4=[[yil=(yield (list lv)) *] seed=seed:lia-sur:wasm]  (run:wasm |+~ seed.b3 flag)
?>  ?=(%0 -.yil.b4)
p.yil.b4