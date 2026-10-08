; docformat = 'rst'

function mlsoapiclient_datasets_ut::test_basic
  compile_opt strictarr

  standard_fieldnames = strupcase(['end_date', 'id', 'name', 'start_date'])
  datasets = mlso_datasets(base_url=self.base_url, $
                           api_version=self.api_version, $
                           n_datasets=n_datasets)
  for i = 0L, n_datasets - 1L do begin
    server_fieldnames = tag_names(datasets[i])
    server_fieldnames = server_fieldnames[sort(server_fieldnames)]
    assert, array_equal(server_fieldnames, standard_fieldnames), $
            'dataset field names not correct'
  endfor

  return, 1
end


function mlsoapiclient_datasets_ut::init, _extra=e
  compile_opt strictarr

  if (~self->mlsoapiclient_testcase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mlso_datasets', /is_function

  return, 1
end


pro mlsoapiclient_datasets_ut__define
  compile_opt strictarr

  !null = {mlsoapiclient_datasets_ut, inherits mlsoapiclient_testcase}
end
