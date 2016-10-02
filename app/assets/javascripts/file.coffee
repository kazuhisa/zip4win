$ ->
  Dropzone.autoDiscover = false
  myDropzone = new Dropzone "#upload-dropzone",
    params:
      'zip_id': gon.zip_id
    init: ->
      @on 'success', (file, json) ->
        console.log("hogehoge")
