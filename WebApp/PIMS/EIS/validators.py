def validate_file_extension(value):
    import os
    # import magic
    from django.core.exceptions import ValidationError
    
    
    
    # valid_mime_types = ['application/pdf']
    # file_mime_type = magic.from_buffer(file.read(2048), mime=True)
    # if file_mime_type not in valid_mime_types:
    #     raise ValidationError('Unsupported file type.')
    
    ext = os.path.splitext(value.name)[1]  # [0] returns path+filename
    valid_extensions = ['.pdf']
    if not ext.lower() in valid_extensions:
        raise ValidationError('Unsupported file extension.')