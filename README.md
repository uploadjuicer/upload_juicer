# Welcome!

This is a rather simple gem for working the the [Juicer
API](http://www.uploadjuicer.com) for resizing images. It's currently pretty
rough around the edges (no tests! ack!) but it works. :)

# The basics

## Submitting jobs

The Job class provides two class-level methods for you to interact with the
API. First, the `submit` method takes an API key, a source URL, and a array
of output hashes. This is POSTed to the API as JSON and a hash is returned to
you with the results of the API call. You'll get back a job id, the source URL
and the outputs you defined, and an indication of the status ("queued" or
"failed").

Here's an example request to create a job:

    UploadJuicer::Job.submit("your api key",
        "http://farm3.static.flickr.com/2084/2222523486_5e1894e314.jpg",
        [{"size" => "100x100>"}])

    => {"id" => "a string", "outputs" => [{"size" => "100x100>"}], "status" => "queued"}
    
You can specify your own destination URLs as S3 locations:

    UploadJuicer::Job.submit("your api key",
        "http://farm3.static.flickr.com/2084/2222523486_5e1894e314.jpg",
        [{"size" => "100x100>", "url" => "s3://mybucket/path/to/destfile.jpg"}])

    => {"id" => "a string", "outputs" => [{"size" => "100x100>", "url" => "s3://mybucket/path/to/destfile.jpg"}], "status" => "queued"}
    
When you specify output URLs, those URLs show up in the hash returned when
queuing the job. For this to work, you'll need to grant access to Juicer to
write to your bucket. You can find Juicer's S3 ID in the documentation at the
Juicer site.

Though size is the only required key in the outputs hashes, you can add other
keys (e.g., a label, or your own ids) to the hashes and they will be passed
back to you. This could be useful if you aren't specifying output URLs and you
want to associate some data with the URLs you'll get back.

## Querying jobs

You can use the id that was returned to you as the second argument (after your
API key) to the `info` method. The return hash would look exactly like the
hash you got back from `submit`, but hopefully the status will now be
"finished" rather than "queued" (or "failed").

# Using Juicer with Rails 3

The intended usage is to have your users upload files directly to S3 via
swfupload, create an UploadJuicer::Upload record via ajax once the upload is
complete, and then associate that UploadJuicer::Upload record and call the
Juicer API when the record your using is working with (e.g., a Project or a
Contact) is created or updated.

A Rails Engine and a generator is included with this gem to make it easy to
integrate Juicer with your Rails application. The engine provides an
UploadJuicer::Upload model, an UploadJuicer::Uploads controller, and a helper
to use in your app. The generator creates a migration, creates a configuration
file, and copies swfupload in place for you to use in your forms.

To use the generator, either specify your API key that you got from the Juicer
site with the --api-key option, or you specify that your API key will be
loaded in your Heroku environment (if you are using Juicer as a Heroku add-on)
with the --heroku option. After running the generator you'll need to run the
migration and edit the config/upload\_juicer.yml file to add your S3
credentials and specify which bucket you want to use for your uploads.

For swfupload to be able to upload to your bucket, you'll need to upload a
crossdomain.xml to the top-level of your bucket. A sample crossdomain.xml file
is placed in your public directory by the generator.

## Example 

Once you are all set up, here's an example of how you'd use the gem in a Rails
view and model:

### app/views/people/new.html.erb

    <%= form_for @person do |p| %>
      <%= p.hidden_field :image_key, :id => :image_key %>
      <%= p.hidden_field :image_id, :id => :image_id %>

      <p>
        <%= p.label :name %>
        <%= p.text_field :name %>
      </p>

      <div id="file_container"></div>
      <p id="upload_placeholder" class="uploadify"></p>

      <p><%= p.submit %></p>
    <% end %>

    <% content_for :head do %>
      <%= stylesheet_link_tag('swfupload.css') %>
    <% end %>

    <% content_for :foot do %>
      <%= javascript_include_tag('swfupload.js', 'uploader.js') %>
      <script type="text/javascript">
        $('#upload_placeholder').uploadify(<%= swfupload_params %>);
      </script>
    <% end %>

This view just has two fields, the name and the file that is being uploaded.
the reference javascripts are copied into your public directory by the
generator. Once the file is selected, the upload begins (and the form is
disabled). Once the file is finished uploading, an ajax request is made to the
UploadJuicer::Uploads controller to create an UploadJuicer::Upload record, the
form is enabled, and the image\_key and image\_id fields are populated with
the JSON response from the UploadJuicer::Uploads controller with info about
the UploadJuicer::Upload model that was just created. This info is used when
the form is submitted to associated the UploadJuicer::Upload with the Person.
The Uploads helper provides the `swfupload_params` method, which does all the
request signing, etc. that S3 requires.

### app/models/person.rb

    class Person < ActiveRecord::Base
      has_one :image, :class_name => 'UploadJuicer::Upload', :as => :uploadable

      after_save :process_image

      attr_accessor :image_key, :image_id

      def process_image
        return if @image_key.blank? || @image_id.blank?
        if self.image = UploadJuicer::Upload.first(:conditions => { :key => @image_key, :id => @image_id, :uploadable_id => nil })
          image.juice_upload(:avatar => { :size => '40x40>' }, :thumb => { :size => '100x100>' })
        end
      end
    end

This model simply associates the UploadJuicer::Upload that was created via the
AJAX call, then calls the `juice_upload` method with a hash of labels and size
info to pass on to the Juicer API. The UploadJuicer::Upload model creates
partitioned paths for the files in your S3 bucket like so:

    Original: http://s3.amazonaws.com/your_bucket/34j/e8r/9fu/file_name.jpg
    Avatar:   http://s3.amazonaws.com/your_bucket/34j/e8r/9fu/avatar/file_name.jpg
    Thumb:    http://s3.amazonaws.com/your_bucket/34j/e8r/9fu/thumb/file_name.jpg

### app/views/person/show.html.erb

    <h1><%= @person.name %></h1>
    <p>Avatar: <%= image_tag(@person.image.url(:avatar)) %></p>
    <p>Thumb: <%= image_tag(@person.image.url(:thumb)) %></p>
    <p>Full image: <%= image_tag(@person.image.url) %></p>
    
This view shows how to get the publicly-readable S3 URLs from the
UploadJuicer::Upload record associated with the Person.
