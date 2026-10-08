; docformat = 'rst'

function mlsoapiclient_about_ut::test_basic
  compile_opt strictarr

  standard_fieldnames = strupcase(['documentation', 'homepage', 'support', 'version'])
  about = mlso_about(base_url=self.base_url, $
                     api_version=self.api_version)
  server_fieldnames = tag_names(about)
  server_fieldnames = server_fieldnames[sort(server_fieldnames)]
  assert, array_equal(server_fieldnames, standard_fieldnames), $
          'about field names not correct'

  return, 1
end


function mlsoapiclient_about_ut::init, _extra=e
  compile_opt strictarr

  if (~self->mlsoapiclient_testcase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mlso_about', /is_function

  return, 1
end


pro mlsoapiclient_about_ut__define
  compile_opt strictarr

  !null = {mlsoapiclient_about_ut, inherits mlsoapiclient_testcase}
end
