; docformat = 'rst'

;+
; Retrieve information about the files available for a given instrument and
; product from the `/instruments/{instrument}/products/{product}` endpoint.
;
; :Returns:
;   array of structures with fields "filename" and "url"
;
; :Params:
;   instrument : in, required, type=string
;     instrument ID to retrieve files for
;   product : in, required, type=string
;     product ID for instrument to retrieve files for
;
; :Keywords:
;   wave_region : in, optional, type=string
;     wave region of files to return
;   start_date : in, optional, type=string
;     start date to begin looking for files from
;   end_date : in, optional, type=string
;     end date to end looking for files to
;   carrington_rotation : in, optional, type=integer
;     Carrington Rotation number of files to return
;   every : in, optional, type=string
;     time period to select 1 file from, e.g., "15minute" returns 1 file every
;     15 minutes; units are second, minute, hour, day, week, month, quarter,
;     year
;   client : in, optional, type=string, default="idl"
;     client used, e.g., "idl", "forward"
;   base_url : in, optional, type=string, default="http://api.mlso.ucar.edu"
;     base URL for the API
;   url_object : in, optional, type=IDLnetURL object
;     existing `IDLnetURL` object if available
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;   n_files : out, optional, type=long
;     set to a named variable to retrieve the number of files
;-
function mlso_files, instrument, product, $
                     n_files=n_files, $
                     wave_region=wave_region, $
                     start_date=start_date, $
                     end_date=end_date, $
                     carrington_rotation=carrington_rotation, $
                     every=every, $
                     client=client, $
                     base_url=base_url, $
                     api_version=api_version, $
                     url_object=url_object
  compile_opt strictarr

  _base_url = n_elements(base_url) gt 0 ? base_url : 'http://api.mlso.ucar.edu'
  _api_version = n_elements(api_version) gt 0L ? api_version : 'v1'
  _client = n_elements(client) gt 0L ? client : 'idl'

  own_url_object = 0B
  if (~obj_valid(url_object)) then begin
    url_object = IDLnetURL()
    own_url_object = 1B
  endif

  files_url = string(_base_url, _api_version, instrument, product, $
                     format='%s/%s/instruments/%s/products/%s')
  filters = !null
  if (n_elements(wave_region) gt 0L) then begin
    filters = [filters, string(wave_region, format='wave-region=%s')]
  endif
  if (n_elements(start_date) gt 0L) then begin
    filters = [filters, string(start_date, format='start-date=%s')]
  endif
  if (n_elements(end_date) gt 0L) then begin
    filters = [filters, string(end_date, format='end-date=%s')]
  endif
  if (n_elements(carrington_rotation) gt 0L) then begin
    filters = [filters, string(carrington_rotation, format='cr=%s')]
  endif
  if (n_elements(every) gt 0L) then begin
    filters = [filters, string(every, format='every=%s')]
  endif
  filters = [filters, string(_client, format='client=%s')]
  filters = n_elements(filters) gt 0L ? ('?' + strjoin(filters, '&')) : ''

  files_url += filters

  files_response = url_object->get(url=files_url, /string_array)
  files_info = json_parse(files_response, /toarray, /tostruct)
  n_files = n_elements(files_info.files)

  if (own_url_object) then obj_destroy, url_object

  return, files_info
end
