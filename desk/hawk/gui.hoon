!:
:-  %shed
=/  input-placeholder=tape  "Paste JavaScript code here"
=/  m  (strand ,vase)
|^
;<  bol=bowl:rand  bind:m  get-bowl
=/  builder-beam=beam
  :-  [our %threads-js da+now]:bol
  /lib/thread-builder-js/hoon
::
;<  builder-vax=vase  bind:m  (build-file-hard builder-beam)
?~  cod=get-code  (pure:m !>(`manx`(render ~)))
=/  shed-vax=vase  (slam builder-vax !>((crip cod)))
=+  !<(=shed:khan shed-vax)
;<  res=thread-result  bind:m  (await-shed shed)
%-  pure:m  !>
^-  manx
(render `res)
::
+$  thread-result
  (each vase (pair term tang))
::  defined in thread-builder-js.hoon
::
+$  shed-result
  [%0 (each cord (pair cord cord))]
::  bear == %threads-js
::
++  await-shed
  |=  =shed:khan
  =/  m  (strand thread-result)
  ::  get new entropy
  ::
  ;<  *  bind:m  (sleep `@`1)
  ;<  =bowl:spider  bind:m  get-bowl
  =/  tid  (scot %ta (cat 3 'strand_' (scot %uv (sham eny.bowl))))
  =/  poke-vase
    !>  ^-  inline-args:spider
    [`tid.bowl `tid [our %threads-js da+now]:bowl shed]
  ::
  ;<  ~      bind:m  (watch-our /awaiting/[tid] %spider /thread-result/[tid])
  ;<  ~      bind:m  (poke-our %spider %spider-inline poke-vase)
  ;<  ~      bind:m  (sleep ~s0)  ::  wait for thread to start
  ;<  =cage  bind:m  (take-fact /awaiting/[tid])
  ;<  ~      bind:m  (take-kick /awaiting/[tid])
  ?+  p.cage  ~|([%strange-thread-result p.cage file tid] !!)
    %thread-done  (pure:m %& q.cage)
    %thread-fail  (pure:m %| !<([term tang] q.cage))
  ==
::
++  render
  |=  result=(unit thread-result)
  ;div.wf.hf.fc
    ;form.fc.grow
      =method  "post"
      =hx-swap  "none"
      ;textarea#code-val-el.b0.grow.p2.mono
        =name  "/code-val"
        =placeholder  input-placeholder
        ;-  get-code
      ==
      ;button.p2.hover.b1.bd1.loader
        ;span.loaded: submit
        ;span.loading.o5: loading
      ==
    ==
    ::
    ;div#output.b0.grow.p2.pre.mono
      ;+  refresher
    ::
      ;-
      ^-  tape
      ?~  result  ""
      ?:  ?=(%| -.u.result)
        (of-wall:format (zing (turn q.p.u.result (cury wash [0 80]))))
      =+  !<(=shed-result p.u.result)
      ?:  ?=(%& -.shed-result)
        """
        JS script ran succesfully:
        {(trip p.shed-result)}
        """
      """
      JS script failed:
      {(trip p.p.shed-result)}
      {(trip q.p.shed-result)}
      """
    ::
    ==
  ==
++  get-code
  ^-  tape
  ?^  x=(peb:c /code-val)  u.x
  =,  mq
  %-  zing
  %-  text-content
  (get-id "code-val-el" dat:f)
  ::
++  refresher
  ;div.hidden
    =hx-get  "?data"
    =hx-target  "#output"
    =hx-select  "#output"
    =hx-swap  "outerHTML"
    =hx-trigger  "load delay:3s"
    ;div.loader.mono.tc.wfc.pre.hidden
      ;span.loaded:       
      ;div.loading: loading
    ==
  ==
--