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
; Print table of the available products for an instrument.
;
; :Params:
;   url_object : in, required, type=IDLnetURL object
;     `IDLnetURL` to make requests of
;   instrument : in, required, type=string
;     instrument ID to list the products of
;
; :Keywords:
;   base_url : in, required, type=string
;     base URL for the MLSO API server
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;-
pro mlsoapi_products, url_object, instrument, base_url=base_url, api_version=api_version
  compile_opt strictarr

  products_info = mlso_products(instrument, $
                                base_url=base_url, $
                                url_object=url_object, $
                                n_products=n_products)
  products = products_info.products

  fmt = '%-13s %-22s %s'
  print, 'ID', 'Title', 'Description', format=fmt
  hyphen = (byte('-'))[0]
  print, string(bytarr(13) + hyphen), $
         string(bytarr(22) + hyphen), $
         string(bytarr(55) + hyphen), format=fmt
  for p = 0L, n_products - 1L do begin
    product = products[p]
    print, product.id, product.title, product.description, format=fmt
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
                   carrington_rotation=carrington_rotation
  compile_opt strictarr

  files_info = mlso_files(instrument, product, $
                          n_files=n_files, $
                          wave_region=wave_region, $
                          start_date=start_date, $
                          end_date=end_date, $
                          carrington_rotation=carrington_rotation, $
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
                            output_dir=output_dir
  compile_opt strictarr

  files_info = mlso_files(instrument, product, $
                          n_files=n_files, $
                          wave_region=wave_region, $
                          start_date=start_date, $
                          end_date=end_date, $
                          carrington_rotation=carrington_rotation, $
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
                        url_object=url_object
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
;     instrument ID to find the files of
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
;   download : in, optional, type=boolean
;     set to download files found if both `instrument` and `product` are
;     specified
;   output_dir : in, optional, type=string, default='.'
;     location to place downloaded files, creates if it doesn't already exist
;   username : in, optional, type=string
;     username registered with HAO website, required if `/DOWNLOAD` set
;   base_url : in, required, type=string, default="http://api.mlso.ucar.edu"
;     base URL for the MLSO API server
;   api_version : in, optional, type=string, default="v1"
;     version of the API to use
;-
pro mlsoapi, instrument=instrument, $
             product=product, $
             wave_region=wave_region, $
             start_date=start_date, $
             end_date=end_date, $
             carrington_rotation=carrington_rotation, $
             download=download, $
             output_dir=output_dir, $
             username=username, $
             base_url=base_url, $
             api_version=api_version
  compile_opt strictarr

  _base_url = n_elements(base_url) gt 0 ? base_url : 'http://api.mlso.ucar.edu'
  _api_version = n_elements(api_version) gt 0L ? api_version : 'v1'

  url_object = IDLnetURL()

  case 1 of
    (n_elements(instrument) eq 0L) && (n_elements(product) eq 0L): begin
        mlsoapi_instruments, url_object, base_url=_base_url, api_version=_api_version
      end
    (n_elements(instrument) gt 0L) && (n_elements(product) eq 0L): begin
        mlsoapi_products, url_object, instrument, base_url=_base_url, api_version=_api_version
      end
    (n_elements(instrument) eq 0L) && (n_elements(product) gt 0L): begin
        print, 'must specify INSTRUMENT if PRODUCT is specified'
      end
    else: begin
        if (keyword_set(download)) then begin
          mlsoapi_download_files, url_object, instrument, product, username, $
                                  base_url=_base_url, $
                                  api_version=_api_version, $
                                  wave_region=wave_region, $
                                  start_date=start_date, $
                                  end_date=end_date, $
                                  carrington_rotation=carrington_rotation, $
                                  output_dir=output_dir
        endif else begin
          mlsoapi_files, url_object, instrument, product, $
                         base_url=_base_url, $
                         api_version=_api_version, $
                         wave_region=wave_region, $
                         start_date=start_date, $
                         carrington_rotation=carrington_rotation, $
                         end_date=end_date
        endelse
      end
  endcase

  done:
  obj_destroy, url_object
end


; main-level example program

;base_url = 'http://127.0.0.1:5000'

mlsoapi, base_url=base_url

print

mlsoapi, instrument='ucomp', base_url=base_url

print

mlsoapi, instrument='ucomp', product='l2', $
         wave_region='789', start_date='2025-01-01', $
         base_url=base_url

mlsoapi, instrument='ucomp', product='l2', $
         wave_region='789', start_date='2025-01-01', $
         username='mgalloy@ucar.edu', /download, output_dir='data', $
         base_url=base_url

end
