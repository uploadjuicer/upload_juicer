// Do something like this to use swfupload
// $(document).ready(function() {
//   $('.uploadify').uploadify();
// });

// Do something like this to drop in a missing image for images that didn't load (e.g., when waiting for transformed files to show up).
// You could also spin up a timeout function to periodically try to load the image.
// $(window).bind('load', function() {
//  $('img').each(function() {
//    if ((typeof this.naturalWidth != "undefined" && this.naturalWidth == 0) || this.readyState == 'uninitialized' ) {
//      $(this).attr('src', '/images/missing.gif');
//    }
//  });
// });

// Display upload errors
function notify(title, message) {
  alert(message);
}

// Display upload errors with a jqueryui dialog
// function notify(title, message, dialogClass) {
//   $('<p>' + message + '</p>').dialog({
//     resizable: false,
//     modal: true,
//     title: title,
//     width: 400,
//     buttons: {
//       Ok: function() {
//         $(this).dialog('close');
//       }
//     }
//   });
// }


var Uploader = {
  file_dialog_complete: function(numFilesSelected, numFilesQueued) {
    if (numFilesQueued > 0) {
      // Disable submission of the containing form while uploading
      this.customSettings.form.find('input[type=submit]').attr('disabled', true);
      $('#' + this.customSettings.upload_target).html('Uploading...');
      this.startUpload();
    }
  },
  upload_error: function(file, errorCode, message) {
    switch (errorCode) {
    case SWFUpload.UPLOAD_ERROR.UPLOAD_LIMIT_EXCEEDED:
      notify("Error", "Too many files selected");
      break;
    default:
      notify("Error", "An error occurred while sending " + file.name);
    }
  },
  upload_success: function(file, data)
  {
    uploadTarget = $('#' + this.customSettings.upload_target);
    idField = $(this.customSettings.id_selector);
    keyField = $(this.customSettings.s3_key_selector);
    $.post('/upload_juicer/uploads.json', {
      file_name: file.name, size: file.size, key: this.settings.post_params.key.replace(/\/\$\{filename\}/, '')
    }, function(data) {
      if (!data.upload.id) {
        alert("There was a problem with your upload");
      } else {
        idField.val(data.upload.id);
        keyField.val(data.upload.key);
        uploadTarget.html("Upload complete: " + data.upload.file_name);
      }
    }, 'json');
  },
  upload_complete: function(file)
  {
    // Enable submission of the containing form
    this.customSettings.form.find('input[type=submit]').attr('disabled', false);
  },
  file_queue_error: function(file, errorCode, message) {
    switch (errorCode) {
    case SWFUpload.QUEUE_ERROR.QUEUE_LIMIT_EXCEEDED:
      notify("Error", "Too many files selected");
      break;
    case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
      notify("Error", file.name + " is too big");
      break;
    case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
      notify("Error", file.name + " is empty");
      break;
    case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
      notify("Error", file.name + " is not an allowed file type");
      break;
    default:
      notify("Error", "An error occurred while sending " + file.name);
    }
  }
};

var swfu;
var swfu_file_size_limit = "10 MB";

$.fn.uploadify = function(options) {
  return this.each(function() {
    id = this.id;
    swfu = new SWFUpload($.extend({
      http_success : [ 200, 201, 204 ],     // FOR AWS

      // File Upload Settings
      file_size_limit: swfu_file_size_limit,
      file_types: "*.jpg;*.png;*.gif",
      file_types_description: "JPG Images; PNG Images; GIF Images",
    	file_queue_limit : 1,
    	file_post_name : "file", 				// FOR AWS

      file_dialog_complete_handler: Uploader.file_dialog_complete,
      file_queue_error_handler: Uploader.file_queue_error,
      upload_error_handler: Uploader.upload_error,
      upload_success_handler: Uploader.upload_success,
      upload_complete_handler: Uploader.upload_complete,

      // Button Settings
      button_image_url: "/images/swfupload/spyglass.png",
      button_placeholder_id: id,
      button_width: 180,
      button_height: 18,
      button_text: '<span class="button">Select Image</span>',
      button_text_style: '.button { font-family: Helvetica, Arial, sans-serif; font-size: 12pt; } .buttonSmall { font-size: 10pt; }',
      button_text_top_padding: 0,
      button_text_left_padding: 18,
      button_window_mode: SWFUpload.WINDOW_MODE.TRANSPARENT,
      button_cursor: SWFUpload.CURSOR.HAND,

      // Flash Settings
      flash_url: "/images/swfupload/swfupload.swf",
      flash9_url: "/images/swfupload/swfupload_fp9.swf",

      custom_settings: {
        form: $(this).parents('form'),
        upload_target: $(this).attr('rel') || "file_container",
        s3_key_selector: '#image_key',
        id_selector: '#image_id',
        thumbnail_height: $(this).attr('data-height') || 400,
        thumbnail_width: $(this).attr('data-width') || 400,
        thumbnail_quality: 100
      },

      // Debug Settings
      debug: false
    },
    options));
  });
};
