; docformat = 'rst'

;+
; Base test class that all unit tests should inherit from.
;-


function mlsoapiclient_testcase::init, $
                                 local=local, $
                                 base_url=base_url, $
                                 api_version=api_version, $
                                 _extra=e
  compile_opt strictarr

  if (~self->MGutTestCase::init(_extra=e)) then return, 0

  self.root = mg_src_root()

  self.base_url = n_elements(base_url) gt 0 $
    ? base_url $
    : (keyword_set(local) ? 'http://127.0.0.1:5000' : 'http://api.mlso.ucar.edu')
  self.api_version = n_elements(api_version) gt 0L ? api_version : 'v1'

  return, 1
end


pro mlsoapiclient_testcase__define
  compile_opt strictarr

  !null = {mlsoapiclient_testcase, inherits MGutTestCase, $
           root: '', $
           base_url: '', $
           api_version: ''}
end
