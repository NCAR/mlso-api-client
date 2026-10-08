; docformat = 'rst'

function mlsoapiclient_human_size_ut::test_basic
  compile_opt strictarr

  values = [2387203222ULL, 12121, 13872960]

  name = 'basic'
  standards = ['2 G', '12 K', '13 M']
  for i = 0L, n_elements(values) - 1L do begin
    assert, mlsoapi_human_size(values[i]) eq standards[i], $
            '%s: value %s != standard %s', $
            name, mlsoapi_human_size(values[i]), standards[i]
  endfor

  name = 'si'
  standards = ['2 G', '12 K', '14 M']
  for i = 0L, n_elements(values) - 1L do begin
    assert, mlsoapi_human_size(values[i], /si) eq standards[i], $
            '%s: value %s != standard %s', $
            name, mlsoapi_human_size(values[i], /si), standards[i]
  endfor

  name = 'decimals'
  standards = ['2.22 G', '11.84 K', '13.23 M']
  for i = 0L, n_elements(values) - 1L do begin
    assert, mlsoapi_human_size(values[i], decimal_places=2) eq standards[i], $
            '%s: value %s != standard %s', $
            name, mlsoapi_human_size(values[i], decimal_places=2), standards[i]
  endfor

  name = 'long'
  standards = ['2 GiB', '12 KiB', '13 MiB']
  for i = 0L, n_elements(values) - 1L do begin
    assert, mlsoapi_human_size(values[i], /long) eq standards[i], $
            '%s: value %s != standard %s', $
            name, mlsoapi_human_size(values[i], /long), standards[i]
  endfor

  name = 'bits'
  standards = ['18 Gib', '95 Kib', '106 Mib']
  for i = 0L, n_elements(values) - 1L do begin
    assert, mlsoapi_human_size(values[i], /bits) eq standards[i], $
            '%s: value %s != standard %s', $
            name, mlsoapi_human_size(values[i], /bits), standards[i]
  endfor

  return, 1
end


function mlsoapiclient_human_size_ut::init, _extra=e
  compile_opt strictarr

  if (~self->mlsoapiclient_testcase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mlsoapi_human_size', /is_function

  return, 1
end


pro mlsoapiclient_human_size_ut__define
  compile_opt strictarr

  !null = {mlsoapiclient_human_size_ut, inherits mlsoapiclient_testcase}
end
