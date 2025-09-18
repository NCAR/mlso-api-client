; mlsoapi.pro (and library routines mlso_instruments, mlso_products, mlso_files,
; and mlso_download_file) provides convenience routines to avoid the use of
; low-level libraries dealing with formulating the URLs in the webservice
; requests, making the requests, parsing JSON responses, etc.

;api_baseurl = 'http://127.0.0.1:5000'
;api_version = 'v1'

; basic querying for exploration

; List information about the instruments available such as ID to use in the API,
; the full name of the instruments, and dates of the available data.
mlsoapi, base_url=api_baseurl, api_version=api_version

print

; List information about the products available for the UCoMP instrument such as
; the product ID, title, and description.
mlsoapi, instrument='ucomp', base_url=api_baseurl, api_version=api_version

print

; List the files available for UCoMP instrument's level 2 product with wave
; region 789 after 2025-01-1.
mlsoapi, instrument='ucomp', product='l2', $
         wave_region='789', start_date='2025-03-23', $
         base_url=api_baseurl, api_version=api_version

; Download the above listed files into the "data" directory. The email username
; given here must be registered with the HAO website at:
;
;   https://registration.hao.ucar.edu

username = 'email@example.com'
mlsoapi, instrument='ucomp', product='l2', $
         wave_region='789', start_date='2025-03-23', $
         username=username, /download, output_dir='data', $
         base_url=api_baseurl, api_version=api_version

print


; API for programmatically retrieving results

; Retrieve information about the available instruments.
instruments_info = mlso_instruments(base_url=api_baseurl, api_version=api_version)
print, strjoin(instruments_info.id, ', '), format='MLSO instruments: %s'

; The fields available for each instrument:
help, instruments_info[0]

; Retrieve information about the products for UCoMP.
products_info = mlso_products('ucomp', base_url=api_baseurl, api_version=api_version)
print, strjoin(products_info.products.id, ', '), format='UCoMP products: %s'
help, products_info.products[0]

; Now find some UCoMP level 2 files in the 789 wave region, starting on
; 2025-03-23.
files_info = mlso_files('ucomp', 'l2', wave_region='789', $
                        start_date='2025-03-23', $
                        base_url=api_baseurl, api_version=api_version)
files = files_info.files
n_files = n_elements(files)
for f = 0L, n_files - 1L do begin
  print, f + 1, n_files, files[f].filename, format='%d/%d: %s'
  print, files[f].url, format='     %s'
endfor

; Download the files found above.
for f = 0L, n_elements(files_info.files) - 1L do begin
  file = files_info.files[f]
  mlso_download_file, file.filename, file.url, username, output_dir='data'
endfor

end
