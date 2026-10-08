; docformat = 'rst'

;+
; Initialize object, adding all test cases.
;
; :Returns:
;   1 for success, 0 for failure
;
; :Keywords:
;   _extra : in, optional, type=keywords
;     keywords to `MGutTestSuite::init` or `MGutTestCase` subclass `init`
;     methods
;-
function mlsoapiclient_uts::init, _extra=e
  compile_opt strictarr

  if (~self->mguttestsuite::init(_extra=e)) then return, 0

  self->add, /all, _extra=e

  return, 1
end


;+
; Define member variables.
;-
pro mlsoapiclient_uts__define
  compile_opt strictarr

  define = { mlsoapiclient_uts, inherits MGutTestSuite }
end
