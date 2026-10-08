; docformat = 'rst'

;+
; Retrieve basic facts about the MLSO API server, i.e., the results of the
; `/about` endpoint. For example::
;
;        IDL help, mlso_about()
;        ** Structure <3060f828>, 4 tags, length=64, data length=64, refs=1:
;        DOCUMENTATION   STRING    'https://mlso-api-client.readthedocs.io/en/latest/'
;        HOMEPAGE        STRING    'https://www2.hao.ucar.edu/mlso'
;        SUPPORT         STRING    'mlso_data_requests@ucar.edu'
;        VERSION         STRING    '1.1.0'
;
; :Returns:
;   structure with fields "documentation", "homepage", "support", "version"
;
; :Keywords:
;   base_url : in, optional, type=string, default="http://api.mlso.ucar.edu"
;     base URL for the API
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;   url_object : in, optional, type=IDLnetURL object
;     existing `IDLnetURL` object if available
;-
function mlso_about, base_url=base_url, $
                     api_version=api_version, $
                     url_object=url_object
  compile_opt strictarr

  _base_url = n_elements(base_url) gt 0 ? base_url : 'http://api.mlso.ucar.edu'
  _api_version = n_elements(api_version) gt 0L ? api_version : 'v1'

  own_url_object = 0B
  if (~obj_valid(url_object)) then begin
    url_object = IDLnetURL()
    own_url_object = 1B
  endif

  about_url = string(_base_url, _api_version, format='%s/%s/about')
  about_response = url_object->get(url=about_url, /string_array)
  about = json_parse(about_response, /toarray, /tostruct)

  if (own_url_object) then obj_destroy, url_object

  return, about
end
