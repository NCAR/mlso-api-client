; docformat = 'rst'

;+
; Retrieve information about the data available for a given dataset and
; product from the `/datasets/{dataset}/products/{product}` endpoint.
;
; :Returns:
;   hierarchy of ordered hashes and lists
;
; :Params:
;   dataset : in, required, type=string
;     dataset ID to retrieve data for
;   product : in, required, type=string
;     product ID for instrument to retrieve data for
;
; :Keywords:
;   start_date : in, optional, type=string
;     start date to begin looking for files from
;   end_date : in, optional, type=string
;     end date to end looking for files to
;   instrument : in, optional, type=string
;     filter datasets by instrument observed in
;   page : in, optional, type=int, default=0
;     page index of results to request, e.g., 0 is the first page, 1 is the
;     second page, etc.
;   base_url : in, optional, type=string, default="http://api.mlso.ucar.edu"
;     base URL for the API
;   url_object : in, optional, type=IDLnetURL object
;     existing `IDLnetURL` object if available
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;   n_files : out, optional, type=long
;     set to a named variable to retrieve the number of files
;-
function mlso_data, dataset, product, $
                    n_data=n_data, $
                    start_date=start_date, $
                    end_date=end_date, $
                    instrument=instrument, $
                    page=page, $
                    base_url=base_url, $
                    api_version=api_version, $
                    url_object=url_object
  compile_opt strictarr

  _base_url = n_elements(base_url) gt 0 ? base_url : 'http://api.mlso.ucar.edu'
  _api_version = n_elements(api_version) gt 0L ? api_version : 'v1'
  _client = n_elements(client) gt 0L ? client : 'idl'
  _page = n_elements(page) gt 0L ? page : 0L

  own_url_object = 0B
  if (~obj_valid(url_object)) then begin
    url_object = IDLnetURL()
    own_url_object = 1B
  endif

  data_url = string(_base_url, _api_version, dataset, product, $
                    format='%s/%s/datasets/%s/products/%s/data')
  filters = !null
  if (n_elements(start_date) gt 0L) then begin
    filters = [filters, string(start_date, format='start-date=%s')]
  endif
  if (n_elements(end_date) gt 0L) then begin
    filters = [filters, string(end_date, format='end-date=%s')]
  endif
  if (n_elements(instrument) gt 0L) then begin
    filters = [filters, string(event, format='instrument=%s')]
  endif
  filters = [filters, string(_page, format='page=%d')]
  filters = '?' + strjoin(filters, '&')

  data_url += filters
  data_response = url_object->get(url=data_url, /string_array)
  data_info = json_parse(data_response)
  n_data = n_elements(data_info['events'])

  if (own_url_object) then obj_destroy, url_object

  return, data_info
end
