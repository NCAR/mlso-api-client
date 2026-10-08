; docformat = 'rst'

function mlsoapiclient_download_file_ut::test_basic
  compile_opt strictarr

  ; skip this test if no username provided
  assert, self.username ne '', $
          'skipping download test (no username is provided)', $
          /skip

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

  files = files_response['files']
  for f = 0L, n_files - 1L do begin
    file = files[f]
    mlso_download_file, file['filename'], $
                        file['url'], $
                        self.username, $
                        base_url=self.base_url, $
                        api_version=self.api_version, $
                        verbose=verbose
    assert, file_test(file['filename']), '%s does not exist', file['filename']
    file_delete, file['filename']
  endfor

  heap_free, files_response

  return, 1
end


function mlsoapiclient_download_file_ut::init, _extra=e
  compile_opt strictarr

  if (~self->mlsoapiclient_testcase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mlso_download_file'

  return, 1
end


pro mlsoapiclient_download_file_ut__define
  compile_opt strictarr

  !null = {mlsoapiclient_download_file_ut, inherits mlsoapiclient_testcase}
end
