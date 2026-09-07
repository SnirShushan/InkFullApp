
function image_preview(input){

  if (input.files && input.files[0]) {
    var reader = new FileReader();

    reader.onload = function (e) {
      img_obj.html("<img class='img img-thumb-preview' src='"+e.target.result+"' >");
    };

    var file =  input.files[0];

    var fileType = file["type"];
    var filesize =  file["size"];
    var ValidImageTypes = ["image/gif", "image/jpeg", "image/png" , "image/jpg" ];

    if ($.inArray(fileType, ValidImageTypes) < 0) {
      //$(input).val("");
      img_obj.html("");
      return false; //file type not matched
    }else{
      reader.readAsDataURL(input.files[0]);
      return true;
    }

  }else{
    img_obj.html("");
  }

}
