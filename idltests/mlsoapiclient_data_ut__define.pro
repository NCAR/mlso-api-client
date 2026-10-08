; docformat = 'rst'

function mlsoapiclient_data_ut::test_data
  compile_opt strictarr

  start_date = '2026-04-01'
  end_date = '2026-04-03'

  results = {all: 2, cavity: 0, cme: 1, jet: 0, loop: 0, surge: 0}
  event_types = strlowcase(tag_names(results))
  for t = 0L, n_tags(results) - 1L do begin
    data = mlso_data( $
      'events', $
      event_types[t], $
      start_date=start_date, $
      end_date=end_date, $
      base_url=self.base_url, $
      api_version=self.api_version, $
      n_data=n_events $
    )
    assert, results.(t) eq n_events, $
            'incorrect number of events %d (expecting %d) for type %s', n_events, results.(t), event_types[t]
    heap_free, data
  endfor

  return, 1
end


function mlsoapiclient_data_ut::init, _extra=e
  compile_opt strictarr

  if (~self->mlsoapiclient_testcase::init(_extra=e)) then return, 0

  self->addTestingRoutine, 'mlso_data', /is_function

  return, 1
end


pro mlsoapiclient_data_ut__define
  compile_opt strictarr

  !null = {mlsoapiclient_data_ut, inherits mlsoapiclient_testcase}
end
