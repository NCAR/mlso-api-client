; docformat = 'rst'

function mlsoapiclient_products_ut::test_instrument_products
  compile_opt strictarr

  standard_fieldnames = strupcase(['description', 'id', 'name', 'title'])
  instruments = ['kcor', 'ucomp']
  for i = 0L, n_elements(instruments) - 1L do begin
    product_info = mlso_products(instruments[i], $
                                 base_url=self.base_url, $
                                 api_version=self.api_version, $
                                 n_products=n_products)
    for p = 0L, n_products - 1L do begin
        server_fieldnames = tag_names(product_info.products[p])
        server_fieldnames = server_fieldnames[sort(server_fieldnames)]
        assert, array_equal(server_fieldnames, standard_fieldnames), $
                'product field names not correct for instrument %s and product %s', $
                instruments[i], product_info.products[p].id
    endfor
  endfor

  return, 1
end


function mlsoapiclient_products_ut::test_instrument_products
  compile_opt strictarr

  ; datasets don't have legacy 'title' field, just 'name'
  standard_fieldnames = strupcase(['description', 'id', 'name'])
  datasets = ['events']
  for d = 0L, n_elements(datasets) - 1L do begin
    product_info = mlso_products(datasets[d], $
                                 /is_dataset, $
                                 base_url=self.base_url, $
                                 api_version=self.api_version, $
                                 n_products=n_products)
    for p = 0L, n_products - 1L do begin
        server_fieldnames = tag_names(product_info.products[p])
        server_fieldnames = server_fieldnames[sort(server_fieldnames)]
        assert, array_equal(server_fieldnames, standard_fieldnames), $
                'product field names not correct for dataset %s and product %s', $
                datasets[d], product_info.products[p].id

    endfor
  endfor

  return, 1
end


function mlsoapiclient_products_ut::init, _extra=e
  compile_opt strictarr

  if (~self->mlsoapiclient_testcase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mlso_products', /is_function

  return, 1
end


pro mlsoapiclient_products_ut__define
  compile_opt strictarr

  !null = {mlsoapiclient_products_ut, inherits mlsoapiclient_testcase}
end
