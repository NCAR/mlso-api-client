; docformat = 'rst'

;+
; Retrieve list of datasets from the `/datasets/{dataset}` endpoint
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
;   n_datasets : out, optional, type=long
;     set to a named variable to retrieve the number of datasets
;-
function mlso_datasets, base_url=base_url, $
                        api_version=api_version, $
                        url_object=url_object, $
                        n_datasets=n_datasets
  compile_opt strictarr

  _base_url = n_elements(base_url) gt 0 ? base_url : 'http://api.mlso.ucar.edu'
  _api_version = n_elements(api_version) gt 0L ? api_version : 'v1'

  own_url_object = 0B
  if (~obj_valid(url_object)) then begin
    url_object = IDLnetURL()
    own_url_object = 1B
  endif

  datasets_url = string(_base_url, _api_version, format='%s/%s/datasets')
  datasets_response = url_object->get(url=datasets_url, /string_array)
  datasets = json_parse(datasets_response, /toarray, /tostruct)

  n_datasets = n_elements(datasets)
  datasets_info = replicate({id: '', name: '', start_date: '', end_date: ''}, $
                             n_datasets)

  for i = 0L, n_datasets - 1L do begin
    dataset_url = string(_base_url, _api_version, datasets[i], $
                         format='%s/%s/datasets/%s')
    dataset_response = url_object->get(url=dataset_url, /string_array)
    dataset_response = json_parse(dataset_response, /toarray, /tostruct)

    datasets_info[i].name = dataset_response.name
    datasets_info[i].id = datasets[i]
    datasets_info[i].start_date = dataset_response.dates.start_date
    datasets_info[i].end_date = dataset_response.dates.end_date
  endfor

  sort_indices = sort(datasets_info.id)
  datasets_info = datasets_info[sort_indices]

  if (own_url_object) then obj_destroy, url_object

  return, datasets_info
end
