; docformat = 'rst'

function mlsoapiclient_files_ut::test_basic
  compile_opt strictarr

  wave_region = '789'
  start_date = '2025-01-01'
  end_date = '2025-03-25'

  files_response = mlso_files( $
    "ucomp", $
    "l2", $
    wave_region=wave_region, $
    start_date=start_date, $
    end_date=end_date, $
    n_files=n_files, $
    base_url=self.base_url, $
    api_version=self.api_version $
  )
  assert, n_files eq 2
  heap_free, files_response

  return, 1
end


function mlsoapiclient_files_ut::init, _extra=e
  compile_opt strictarr

  if (~self->mlsoapiclient_testcase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mlso_files', /is_function

  return, 1
end


pro mlsoapiclient_files_ut__define
  compile_opt strictarr

  !null = {mlsoapiclient_files_ut, inherits mlsoapiclient_testcase}
end
