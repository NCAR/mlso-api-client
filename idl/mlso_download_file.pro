; docformat = 'rst'

;+
; Download a file given its name, URL, and a valid username registered with the
; HAO website.
;
; :Params:
;   basename : in, required, type=string
;     file basename to use for downloaded file
;   url : in, required, type=string
;     URL of file to download
;   username : in, required, type=string
;     username registered with HAO website
;
; :Keywords:
;   output_dir : in, optional, type=string, default='.'
;     location to place downloaded file
;   base_url : in, optional, type=string, default="http://api.mlso.ucar.edu"
;     base URL for the API
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;   url_object : in, optional, type=IDLnetURL object
;     existing `IDLnetURL` object if available
;-
pro mlso_download_file, basename, url, username, $
                        output_dir=output_dir, $
                        base_url=base_url, $
                        api_version=api_version, $
                        url_object=url_object, $
                        verbose=verbose
  compile_opt strictarr

  _base_url = n_elements(base_url) gt 0 ? base_url : 'http://api.mlso.ucar.edu:5000'
  _api_version = n_elements(api_version) gt 0L ? api_version : 'v1'

  _output_dir = n_elements(output_dir) gt 0 ? output_dir : '.'

  own_url_object = 0B
  if (~obj_valid(url_object)) then begin
    url_object = IDLnetURL()
    own_url_object = 1B
  endif

  authenticate_url = string(_base_url, _api_version, username, $
                            format='%s/%s/authenticate?username=%s')
  if (keyword_set(verbose)) then print, authenticate_url
  response = url_object->get(url=authenticate_url, /string_array)

  url_object->getProperty, response_header=response_header
  newline = string([10B])
  response_header = strsplit(response_header, newline, /extract)

  ; find the session cookie in the authentication response; cookies always
  ; start with "Set-Cookie:" in the response header -- ours looks something
  ; like:
  ; Set-Cookie: session=FrFClgPOPeNZVR-r44Yn5jVTILVZ-2cfWRh5ilsLbRQ; Expires=Fri, 25 Jul 2025 15:51:18 GMT; HttpOnly; Path=/
  cookie_matches = strmatch(response_header, 'Set-Cookie: *')
  cookie_indices = where(cookie_matches, /null)

  ; in the request header, we set the cookie by stating a line with "Cookie:"
  cookie = response_header[cookie_indices[0]]

  ; we just want the "Cookie: name=value" of above, i.e.:
  ;   Cookie: session=FrFClgPOPeNZVR-r44Yn5jVTILVZ-2cfWRh5ilsLbRQ
  cookie = strmid(cookie, 4, strpos(cookie, ';') - 4)

  url_object->setProperty, header=cookie
  if (keyword_set(verbose)) then print, url
  response = url_object->get(url=url, filename=filepath(basename, root=_output_dir))

  if (own_url_object) then obj_destroy, url_object
end
