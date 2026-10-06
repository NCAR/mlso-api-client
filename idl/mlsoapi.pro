; docformat = 'rst'

;+
; Print table of the available instruments.
;
; :Params:
;   url_object : in, required, type=IDLnetURL object
;     `IDLnetURL` to make requests of
;
; :Keywords:
;   base_url : in, optional, type=string
;     base URL for the MLSO API server
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;-
pro mlsoapi_instruments, url_object, base_url=base_url, api_version=api_version
  compile_opt strictarr

  instruments_info = mlso_instruments(base_url=base_url, $
                                      api_version=api_version, $
                                      url_object=url_object, $
                                      n_instruments=n_instruments)

  if (n_instruments gt 0L) then begin
    fmt = '%-8s %-44s %s'
    print, 'ID', 'Instrument name', 'Dates available', format=fmt
    hyphen = (byte('-'))[0]
    print, string(bytarr(8) + hyphen), $
           string(bytarr(44) + hyphen), $
           string(bytarr(23) + hyphen), $
           format=fmt
  endif

  for i = 0L, n_elements(instruments_info) - 1L do begin
    instrument = instruments_info[i]
    print, instrument.id, $
           instrument.name, $
           strmid(instrument.start_date, 0, 10), $
           strmid(instrument.end_date, 0, 10), $
           format='%-8s %-44s %s...%s'
  endfor
end


;+
; Print table of the available datasets.
;
; :Params:
;   url_object : in, required, type=IDLnetURL object
;     `IDLnetURL` to make requests of
;
; :Keywords:
;   base_url : in, optional, type=string
;     base URL for the MLSO API server
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;-
pro mlsoapi_datasets, url_object, base_url=base_url, api_version=api_version
  compile_opt strictarr

  datasets_info = mlso_datasets(base_url=base_url, $
                                api_version=api_version, $
                                url_object=url_object, $
                                n_datasets=n_datasets)

  if (n_datasets gt 0L) then begin
    fmt = '%-8s %-44s %s'
    print, 'ID', 'Dataset name', 'Dates available', format=fmt
    hyphen = (byte('-'))[0]
    print, string(bytarr(8) + hyphen), $
           string(bytarr(44) + hyphen), $
           string(bytarr(23) + hyphen), $
           format=fmt
  endif

  for i = 0L, n_elements(datasets_info) - 1L do begin
    dataset = datasets_info[i]
    print, dataset.id, $
           dataset.name, $
           strmid(dataset.start_date, 0, 10), $
           strmid(dataset.end_date, 0, 10), $
           format='%-8s %-44s %s...%s'
  endfor
end


;+
; Print table of the available products for an instrument.
;
; :Params:
;   url_object : in, required, type=IDLnetURL object
;     `IDLnetURL` to make requests of
;   instrument : in, required, type=string
;     instrument (or dataset, if `IS_DATASET` is set) ID to list the products
;     of
;
; :Keywords:
;   is_dataset : in, optional, type=boolean
;     set to indicate that the `instrument` argument is actually a dataset
;   base_url : in, required, type=string
;     base URL for the MLSO API server
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;-
pro mlsoapi_products, url_object, $
                      instrument, $
                      is_dataset=is_dataset, $
                      base_url=base_url, $
                      api_version=api_version
  compile_opt strictarr

  products_info = mlso_products(instrument, $
                                is_dataset=is_dataset, $
                                base_url=base_url, $
                                url_object=url_object, $
                                n_products=n_products)
  products = products_info.products

  fmt = '%-13s %-22s %s'
  print, 'ID', 'Name', 'Description', format=fmt
  hyphen = (byte('-'))[0]
  print, string(bytarr(13) + hyphen), $
         string(bytarr(22) + hyphen), $
         string(bytarr(55) + hyphen), format=fmt
  for p = 0L, n_products - 1L do begin
    product = products[p]
    print, product.id, product.name, product.description, format=fmt
  endfor
end


;+
; Print table of the available files for a given instrument and product. Files
; are filtered by keywords such as `wave_region`, `start_date`, and `end_date`.
;
; :Params:
;   url_object : in, required, type=IDLnetURL object
;     `IDLnetURL` to make requests of
;   instrument : in, required, type=string
;     instrument ID to list the files of
;   product : in, required, type=string
;     product ID to list the files of
;
; :Keywords:
;   wave_region : in, optional, type=string
;     wave region of files to return
;   start_date : in, optional, type=string
;     start date to begin looking for files from
;   end_date : in, optional, type=string
;     end date to end looking for files to
;   carrington_rotation : in, optional, type=integer
;     Carrington Rotation number of files to return
;   every : in, optional, type=string
;     time period to select 1 file from, e.g., "15minute" returns 1 file every
;     15 minutes; units are second, minute, hour, day, week, month, quarter,
;     year
;   event : in, optional, type=string
;     event type to download files during, currently only "cme"
;   base_url : in, required, type=string
;     base URL for the MLSO API server
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;-
pro mlsoapi_files, url_object, instrument, product, $
                   username=useranme, $
                   base_url=base_url, $
                   api_version=api_version, $
                   wave_region=wave_region, $
                   start_date=start_date, $
                   end_date=end_date, $
                   carrington_rotation=carrington_rotation, $
                   every=every, $
                   event=event
  compile_opt strictarr

  files_info = mlso_files(instrument, product, $
                          n_files=n_files, $
                          wave_region=wave_region, $
                          start_date=start_date, $
                          end_date=end_date, $
                          carrington_rotation=carrington_rotation, $
                          every=every, $
                          event=event, $
                          base_url=base_url, $
                          url_object=url_object)
  files = files_info.files

  print, 'Date/time', 'Instrument', 'Product', 'Filesize', 'Filename', $
         format='%-20s %-10s %-13s %-10s %s'
  max_filename_length = max(strlen(files.filename))
  hyphen = (byte('-'))[0]
  print, string(bytarr(20) + hyphen), $
         string(bytarr(10) + hyphen), $
         string(bytarr(13) + hyphen), $
         string(bytarr(10) + hyphen), $
         string(bytarr(max_filename_length) + hyphen), $
         format='%s %s %s %s %s'

  total_size = 0UL
  for f = 0L, n_elements(files) - 1L do begin
    file = files[f]
    total_size += file.filesize
    print, file.date_obs, file.instrument, file.product, $
           mlsoapi_human_size(file.filesize, decimal_places=1), file.filename, $
           format='%-20s %-10s %-13s %10s %s'
  endfor

  print, string(bytarr(20) + hyphen), $
         string(bytarr(10) + hyphen), $
         string(bytarr(13) + hyphen), $
         string(bytarr(10) + hyphen), $
         string(bytarr(max_filename_length) + hyphen), $
         format='%s %s %s %s %s'
  n_files = string(n_elements(files), format='%d files')
  print, n_files, mlsoapi_human_size(total_size, decimal_places=1), $
         format='%-45s %10s'
end


;+
; Print table of the available event data for a given product. Events are
; filtered by keywords such as `start_date`, `end_date`, or `instrument` seen
; in.
;
; :Params:
;   url_object : in, required, type=IDLnetURL object
;     `IDLnetURL` to make requests of
;   product : in, required, type=string
;     product ID to list the files of
;
; :Keywords:
;   wave_region : in, optional, type=string
;     wave region of files to return
;   start_date : in, optional, type=string
;     start date to begin looking for files from
;   end_date : in, optional, type=string
;     end date to end looking for files to
;   instrument : in, optional, type=string
;     filter datasets by instrument observed in
;   base_url : in, required, type=string
;     base URL for the MLSO API server
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;-
pro mlsoapi_events, url_object, product, $
                    start_date=start_date, $
                    end_date=end_date, $
                    instrument=instrument, $
                    base_url=base_url, $
                    api_version=api_version
  compile_opt strictarr

  events_info = mlso_data("events", product, $
                          n_data=n_data, $
                          start_date=start_date, $
                          end_date=end_date, $
                          instrument=instrument, $
                          base_url=base_url, $
                          url_object=url_object)
  events = events_info.events

  date_width = 19
  instrument_width = 10
  max_eventtype_width = 7
  quadrant_width = 10
  n_columns = 100L
  comment_width = n_columns - date_width - 1 - date_width - 1 $
    - instrument_width - 1 - max_eventtype_width - 1 - quadrant_width - 1
  fmt = string(date_width, $
               date_width, $
               instrument_width, $
               max_eventtype_width, $
               quadrant_width, $
               comment_width, $
               format='%%-%ds %%-%ds %%-%ds %%-%ds %%-%ds %%-%ds')

  print, 'Start time', 'End time', 'Instrument', 'Type', 'Quadrant', 'Comment', $
         format=fmt
  hyphen = (byte('-'))[0]
  print, string(bytarr(date_width) + hyphen), $
         string(bytarr(date_width) + hyphen), $
         string(bytarr(instrument_width) + hyphen), $
         string(bytarr(max_eventtype_width) + hyphen), $
         string(bytarr(quadrant_width) + hyphen), $
         string(bytarr(comment_width) + hyphen), $
         format='%s %s %s %s %s %s'

  for e = 0L, n_elements(events) - 1L do begin
    ev = events[e]
    comments = mg_strwrap(ev.comment, width=comment_width)
    print, ev.date_obs, ev.date_end, ev.instrument, ev.type, ev.quadrant, comments[0], $
           format=fmt
    for c = 1L, n_elements(comments) - 1L do begin
    print, '', '', '', '', '', comments[c], $
           format=fmt
    endfor
  endfor

  print, string(bytarr(date_width) + hyphen), $
         string(bytarr(date_width) + hyphen), $
         string(bytarr(instrument_width) + hyphen), $
         string(bytarr(max_eventtype_width) + hyphen), $
         string(bytarr(quadrant_width) + hyphen), $
         string(bytarr(comment_width) + hyphen), $
         format='%s %s %s %s %s %s'
  n_events = string(n_elements(events), format='%d events')
  print, n_events, $
         format='%-45s'
end


;+
; Print table of the available data for a given dataset and product. Data is
; filtered by keywords such as `start_date`, `end_date`, or `instrument` seen
; in.
;
; :Params:
;   url_object : in, required, type=IDLnetURL object
;     `IDLnetURL` to make requests of
;   dataset : in, required, type=string
;     dataset ID to list the files of
;   product : in, required, type=string
;     product ID to list the files of
;
; :Keywords:
;   wave_region : in, optional, type=string
;     wave region of files to return
;   start_date : in, optional, type=string
;     start date to begin looking for files from
;   end_date : in, optional, type=string
;     end date to end looking for files to
;   instrument : in, optional, type=string
;     filter datasets by instrument observed in
;   base_url : in, required, type=string
;     base URL for the MLSO API server
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;-
pro mlsoapi_data, url_object, dataset, product, $
                  start_date=start_date, $
                  end_date=end_date, $
                  instrument=instrument, $
                  base_url=base_url, $
                  api_version=api_version
  compile_opt strictarr

  if (dataset eq "events") then begin
    mlsoapi_events, url_object, product, $
                    start_date=start_date, $
                    end_date=end_date, $
                    instrument=instrument, $
                    base_url=base_url, $
                    api_version=api_version
  endif
end


;+
; Download available files for a given instrument and product. Files are
; filtered by keywords such as `wave_region`, `start_date`, and `end_date`.
;
; :Params:
;   url_object : in, required, type=IDLnetURL object
;     `IDLnetURL` to make requests of
;   instrument : in, required, type=string
;     instrument ID to list the files of
;   product : in, required, type=string
;     product ID to list the files of
;
; :Keywords:
;   wave_region : in, optional, type=string
;     wave region of files to return
;   start_date : in, optional, type=string
;     start date to begin looking for files from
;   end_date : in, optional, type=string
;     end date to end looking for files to
;   carrington_rotation : in, optional, type=integer
;     Carrington Rotation number of files to return
;   every : in, optional, type=string
;     time period to select 1 file from, e.g., "15minute" returns 1 file every
;     15 minutes; units are second, minute, hour, day, week, month, quarter,
;     year
;   event : in, optional, type=string
;     event type to download files during, currently only "cme"
;   base_url : in, required, type=string
;     base URL for the MLSO API server
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;   output_dir : in, optional, type=string, default='.'
;     location to place downloaded files, creates if it doesn't already exist
;-
pro mlsoapi_download_files, url_object, instrument, product, username, $
                            base_url=base_url, $
                            api_version=api_version, $
                            wave_region=wave_region, $
                            start_date=start_date, $
                            end_date=end_date, $
                            carrington_rotation=carrington_rotation, $
                            every=every, $
                            event=event, $
                            output_dir=output_dir, $
                            verbose=verbose
  compile_opt strictarr

  files_info = mlso_files(instrument, product, $
                          n_files=n_files, $
                          wave_region=wave_region, $
                          start_date=start_date, $
                          end_date=end_date, $
                          carrington_rotation=carrington_rotation, $
                          every=every, $
                          event=event, $
                          base_url=base_url, $
                          url_object=url_object)
  files = files_info.files

  if (n_files gt 0L && ~file_test(output_dir, /directory)) then begin
    file_mkdir, output_dir
  endif

  for f = 0L, n_files - 1L do begin
    file = files[f]
    mlso_download_file, file.filename, file.url, username, $
                        output_dir=output_dir, $
                        base_url=base_url, $
                        url_object=url_object, $
                        verbose=verbose
  endfor
end


;+
; Query the MLSO database for instruments, products, and files available. Files
; can optionally be downloaded if the email username passed via the `USERNAME`
; keyword has been registered with the HAO website at::
;
;   https://registration.hao.ucar.edu
;
; :Keywords:
;   instrument : in, required, type=string
;     instrument ID to find the products or files of
;   dataset : in, required, type=string
;     dataset ID to find the products or data of
;   product : in, required, type=string
;     product ID to find the files of
;   wave_region : in, optional, type=string
;     wave region of files to return
;   start_date : in, optional, type=string
;     start date to begin looking for files from
;   end_date : in, optional, type=string
;     end date to end looking for files to
;   carrington_rotation : in, optional, type=integer
;     Carrington Rotation number of files to return
;   every : in, optional, type=string
;     time period to select 1 file from, e.g., "15minute" returns 1 file every
;     15 minutes; units are second, minute, hour, day, week, month, quarter,
;     year
;   event : in, optional, type=string, default="all"
;     event type to download files during, currently only "cavity", "cme",
;     "jet", "loop", "surge", or "all"
;   filter_instrument : in, optional, type=string
;     filter datasets by instrument observed in
;   download : in, optional, type=boolean
;     set to download files found if both `instrument` and `product` are
;     specified
;   output_dir : in, optional, type=string, default='.'
;     location to place downloaded files, creates if it doesn't already exist
;   username : in, optional, type=string
;     username registered with HAO website, required if `/DOWNLOAD` set
;   local : in, optional, type=boolean
;     set to use localhost (http://127.0.0.1:5000) as the server URL
;   base_url : in, required, type=string, default="http://api.mlso.ucar.edu"
;     base URL for the MLSO API server
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;-
pro mlsoapi, instrument=instrument, $
             dataset=dataset, $
             product=product, $
             wave_region=wave_region, $
             start_date=start_date, $
             end_date=end_date, $
             carrington_rotation=carrington_rotation, $
             every=every, $
             event=event, $
             filter_instrument=filter_instrument, $
             download=download, $
             output_dir=output_dir, $
             username=username, $
             local=local, $
             base_url=base_url, $
             api_version=api_version, $
             verbose=verbose
  compile_opt strictarr

  _base_url = n_elements(base_url) gt 0 $
    ? base_url $
    : (keyword_set(local) ? 'http://127.0.0.1:5000' : 'http://api.mlso.ucar.edu')
  _api_version = n_elements(api_version) gt 0L ? api_version : 'v1'

  url_object = IDLnetURL()

  case 1 of
    (n_elements(instrument) eq 0L) && (n_elements(dataset) eq 0L) && (n_elements(product) eq 0L): begin
        mlsoapi_instruments, url_object, base_url=_base_url, api_version=_api_version
        print
        mlsoapi_datasets, url_object, base_url=_base_url, api_version=_api_version
      end
    ((n_elements(instrument) gt 0L) || (n_elements(dataset) gt 0L)) && (n_elements(product) eq 0L): begin
        mlsoapi_products, url_object, $
                          n_elements(instrument) gt 0L ? instrument : dataset, $
                          is_dataset=n_elements(instrument) eq 0L, $
                          base_url=_base_url, $
                          api_version=_api_version
      end
    (n_elements(instrument) eq 0L) && (n_elements(dataset) eq 0L) && (n_elements(product) gt 0L): begin
        print, 'must specify INSTRUMENT or DATASET if PRODUCT is specified'
      end
    else: begin
        if (n_elements(instrument) gt 0L) then begin
          if (keyword_set(download)) then begin
            mlsoapi_download_files, url_object, instrument, product, username, $
                                    start_date=start_date, $
                                    end_date=end_date, $
                                    carrington_rotation=carrington_rotation, $
                                    every=every, $
                                    event=event, $
                                    wave_region=wave_region, $
                                    output_dir=output_dir, $
                                    base_url=_base_url, $
                                    api_version=_api_version, $
                                    verbose=verbose
          endif else begin
            mlsoapi_files, url_object, instrument, product, $
                          start_date=start_date, $
                          end_date=end_date, $
                          carrington_rotation=carrington_rotation, $
                          every=every, $
                          event=event, $
                          wave_region=wave_region, $
                          base_url=_base_url, $
                          api_version=_api_version
          endelse
        endif else begin
          mlsoapi_data, url_object, dataset, product, $
                        start_date=start_date, $
                        end_date=end_date, $
                        instrument=filter_instrument, $
                        base_url=_base_url, $
                        api_version=_api_version
        endelse
      end
  endcase

  done:
  obj_destroy, url_object
end


; main-level example program

; NOTE: set this to an email registered at: https://registration.hao.ucar.edu
email = 'my.email@example.com'

mlsoapi

print
mlsoapi, instrument='ucomp'

print
mlsoapi, instrument='ucomp', product='l2', $
         wave_region='789', start_date='2025-01-01'

print
mlsoapi, instrument='ucomp', product='l2', $
         wave_region='789', start_date='2025-01-01', $
         username=email, /download, output_dir='data'

end
