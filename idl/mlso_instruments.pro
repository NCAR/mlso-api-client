; docformat = 'rst'

;+
; Retrieve list of instruments from the `/instruments/{instrument}` endpoint
; with some of their properties.
;
; :Returns:
;   array of structures with fields "id", "name", "start_date", and "end_date",
;   all strings
;
; :Keywords:
;   base_url : in, optional, type=string, default="http://api.mlso.ucar.edu"
;     base URL for the API
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;   url_object : in, optional, type=IDLnetURL object
;     existing `IDLnetURL` object if available
;   n_instruments : out, optional, type=long
;     set to a named variable to retrieve the number of instruments
;-
function mlso_instruments, base_url=base_url, $
                           api_version=api_version, $
                           url_object=url_object, $
                           n_instruments=n_instruments
  compile_opt strictarr

  _base_url = n_elements(base_url) gt 0 ? base_url : 'http://api.mlso.ucar.edu'
  _api_version = n_elements(api_version) gt 0L ? api_version : 'v1'

  own_url_object = 0B
  if (~obj_valid(url_object)) then begin
    url_object = IDLnetURL()
    own_url_object = 1B
  endif

  instruments_url = string(_base_url, _api_version, format='%s/%s/instruments')
  instruments_response = url_object->get(url=instruments_url, /string_array)
  instruments = json_parse(instruments_response, /toarray, /tostruct)

  n_instruments = n_elements(instruments)
  instruments_info = replicate({id: '', name: '', start_date: '', end_date: ''}, $
                               n_instruments)

  for i = 0L, n_instruments - 1L do begin
    instrument_url = string(_base_url, _api_version, instruments[i], $
                            format='%s/%s/instruments/%s')
    instrument_response = url_object->get(url=instrument_url, /string_array)
    instrument_response = json_parse(instrument_response, /toarray, /tostruct)

    instruments_info[i].name = instrument_response.name
    instruments_info[i].id = instruments[i]
    instruments_info[i].start_date = instrument_response.dates.start_date
    instruments_info[i].end_date = instrument_response.dates.end_date
  endfor

  sort_indices = sort(instruments_info.id)
  instruments_info = instruments_info[sort_indices]

  if (own_url_object) then obj_destroy, url_object

  return, instruments_info
end
