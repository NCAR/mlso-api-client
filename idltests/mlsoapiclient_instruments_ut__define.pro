; docformat = 'rst'

function mlsoapiclient_instruments_ut::test_basic
  compile_opt strictarr

  standard_fieldnames = strupcase(['end_date', 'id', 'name', 'start_date'])
  instruments = mlso_instruments(base_url=self.base_url, $
                                 api_version=self.api_version, $
                                 n_instruments=n_instruments)
  for i = 0L, n_instruments - 1L do begin
    server_fieldnames = tag_names(instruments[i])
    server_fieldnames = server_fieldnames[sort(server_fieldnames)]
    assert, array_equal(server_fieldnames, standard_fieldnames), $
            'instrument field names not correct'
  endfor

  return, 1
end


function mlsoapiclient_instruments_ut::init, _extra=e
  compile_opt strictarr

  if (~self->mlsoapiclient_testcase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mlso_instruments', /is_function

  return, 1
end


pro mlsoapiclient_instruments_ut__define
  compile_opt strictarr

  !null = {mlsoapiclient_instruments_ut, inherits mlsoapiclient_testcase}
end
