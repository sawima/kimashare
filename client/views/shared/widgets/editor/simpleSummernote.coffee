Template.simpleSummernote.rendered = () ->
	$('.simple_summernote').summernote({
		height:150
		toolbar: [
            ['style', ['bold', 'italic', 'underline', 'clear']],
            ['font', ['strikethrough']],
            ['fontsize', ['fontsize']],
            ['color', ['color']],
            ['para', ['ul', 'ol', 'paragraph']],
            ['height', ['height']]
            ['table', ['table']]
            ['insert', ['link']]
            ['fullscreen', ['fullscreen']]
            ['codeview', ['codeview']]
          ]
	})
