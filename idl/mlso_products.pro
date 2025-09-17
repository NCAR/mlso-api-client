; docformat = 'rst'

;+
; Retrieve information about the products available for a given instrument from
; the `/instruments/{instrument}/products` endpoint.
;
; :Returns:
;   structure with field "products" which is an array of structures with fields
;   "id", "title", and "description"
;
; :Params:
;   instrument : in, required, type=string
;     instrument ID to find the products of
;
; :Keywords:
;   base_url : in, optional, type=string, default="http://api.mlso.ucar.edu"
;     base URL for the API
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;   url_object : in, optional, type=IDLnetURL object
;     existing `IDLnetURL` object if available
;   n_products : out, optional, type=long
;     set to a named variable to retrieve the number of products
;-
function mlso_products, instrument, $
                        base_url=base_url, $
                        api_version=api_version, $
                        url_object=url_object, $
                        n_products=n_products
  compile_opt strictarr

  _base_url = n_elements(base_url) gt 0 ? base_url : 'http://api.mlso.ucar.edu'
  _api_version = n_elements(api_version) gt 0L ? api_version : 'v1'

  own_url_object = 0B
  if (~obj_valid(url_object)) then begin
    url_object = IDLnetURL()
    own_url_object = 1B
  endif

  products_url = string(_base_url, _api_version, instrument, $
                        format='%s/%s/instruments/%s/products')
  products_response = url_object->get(url=products_url, /string_array)
  products_info = json_parse(products_response, /toarray, /tostruct)
  n_products = n_elements(products_info.products)

  if (own_url_object) then obj_destroy, url_object

  return, products_info
end
