
    <?php $msg = get_flashdata('msg'); 
    if($msg!=''): ?>
      <div class="alert alert-success">
        <strong><?php echo $msg ?></strong>
      </div>
    <?php endif; ?>

    <?php $Error = get_flashdata('Error'); 
    if($Error!=''): ?>
    <div class="alert alert-danger">
      <strong><?php echo $Error; ?></strong>
    </div>
    <?php endif; ?>


     <style type="text/css">
        .well-primary {
        color: rgb(255, 255, 255);
        background-color: rgb(66, 139, 202);
        border-color: rgb(53, 126, 189);
        }
        .selected_color
        {
              border: solid 2px rgb(255,0,0);
        }
        .theambutton
        {
          margin: 3px;
        }

     </style>


    <div class="row">
        <div class="col-md-12">
            <div class="panel-group" id="accordion">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a data-toggle="collapse" data-parent="#accordion" href="#collapseTwo"><i class="fa fa-cog" aria-hidden="true"></i>

                            </span> General Settings</a>
                        </h4>
                    </div>
                    <div id="collapseTwo" class="panel-collapse collapse in">
                        <div class="panel-body">
                            <div class="row">
                              <form method="post" enctype="multipart/form-data">
                                <div class="col-md-4">
                                    <div class="form-group">
                                        <h4>App Logo</h4>
                                    </div>
                                </div>
                                 <div class="col-md-4">
                                    <div class="form-group">
                                      <?php 
                                      $main_url=base_url()."assets/pages/img/transparency.png";
                                      echo "<img class='center' id='currunt_logo' style='background: url(".$main_url."); background-size: 100px 100px;' width='100px' src=".base_url().'./assets/upload/'.$Setting['app_logo'].">";
                                      ?>
                                        <div id="input_file_uplode"><input type="file" name="logo" class="form-control" required /></div>
                                    </div>
                                </div>
                                <div class="col-md-4">
                                    <div class="form-group">
                                      <a class="btn <?=$this->settings['danger_color'];?>" id="remove_logo" href="javascript:void(0)">X</a>
                                      <input type="submit" value="Upload Logo" id="submit_logo_uplode" class="btn <?=$this->settings['success_color'];?>" name="logo_save">
                                    </div>
                                </div>
                              </form>
                                
                            </div>
                            <hr>
                            <div class="row">
                                <form method="post" enctype="multipart/form-data">
                                  <div class="col-md-4">
                                      <div class="form-group">
                                          <h4>Favicon</h4>
                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group">
                                        <?php 
                                        echo "<img class='center' id='currunt_logo_fev' style='background: #757575;' width='30px' src=".base_url().'./assets/upload/'.$Setting['favicon'].">";
                                        ?>
                                          <div id="input_file_uplode_fev"><input type="file" name="fevlogo" class="form-control" required /></div>
                                      </div>
                                  </div>
                                  <div class="col-md-4">
                                      <div class="form-group">
                                        <a class="btn <?=$this->settings['danger_color'];?>" id="remove_logo_fev" href="javascript:void(0)">X</a>
                                        <input type="submit" value="Upload Logo" id="submit_logo_uplode_fev" class="btn <?=$this->settings['success_color'];?>" name="logo_save_fev">
                                      </div>
                                  </div>
                                </form>
                                
                            </div>
                            <hr>
                            <div class="row">
                                <form method="post">
                                  <div class="col-md-4">
                                      <div class="form-group">
                                          <h4>App Name</h4>
                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group">
                                          <input type="text" name="app_name" value="<?=$Setting['name'];?>" class="form-control" required/>
                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group">
                                          <input type="submit" value="Save" name="submit_appname" class="btn <?=$this->settings['success_color'];?>" disabled>
                                      </div>
                                  </div>
                                </form>
                                
                            </div>
                              <hr>

                            <div class="row">
                                <form method="post">
                                  <div class="col-md-4">
                                      <div class="form-group">
                                          <h4>Footer Text</h4>
                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group">
                                          <input type="text" name="footer_text" value="<?=$Setting['footer_text'];?>" class="form-control" required/>
                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group">
                                          <input type="submit" value="Save" name="submit_footer" class="btn <?=$this->settings['success_color'];?>" disabled>
                                      </div>
                                  </div>
                                </form>
                            </div>
                            <hr>
                            <?php
                            $direction=$this->settings['layout'];
                            ?>
                            
<?php
/*
                            <div class="row">
                                <form method="post">
                                  <div class="col-md-4">
                                      <div class="form-group">
                                          <h4>Theme Direction</h4>
                                      </div>
                                  </div>
                                   <div class="col-md-2">
                                        <div class="form-group" id="checkbox1">
                                          <label><input type="radio" group="direction" class="radio_direction" value="1" name="direction" <?=($direction=="layout/default")?"checked":"";?> > LTF </label> 
                                        </div>
                                  </div>
                                  <div class="col-md-2">
                                        <div class="form-group" id="checkbox2">
                                          <label><input type="radio" group="direction" class="radio_direction" value="2" name="direction" <?=($direction=="layout/ltf_default")?"checked":"";?>> RTF </label>
                                        </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group">
                                          <input type="submit" value="Save" name="theme_direction" class="btn <?=$this->settings['success_color'];?>" disabled>
                                      </div>
                                  </div>
                                </form>
                            </div>
                            <hr>
*/
?>

                            <div class="bg-default bg-font-default margin-bottom-10" style="padding: 10px; font-weight: bold; color: #000!importrnt;">Layout Change </div>
                            <hr>
                            <div class="row" style="vertical-align: middle;">
                                <form method="post">
                                  <input type="hidden" name="theam_color" value="1" id="color_name">
                                  <div class="col-md-4">
                                      <div class="form-group">
                                          <h4 style="padding-top: 25px;">Theme Color </h4>
                                      </div>
                                  </div>
                                  <?php 
                                  $img ='<img src="'.base_url().'assets/layouts/layout/img/right.png">';
                                  
                                  ?>
                                   <div class="col-md-4">
                                      <div class="form-group">
                                        <table>
                                          <tr>
                                            <td>
                                            <a href="JavaScript:void(0)" class="theambutton color1" data-id="1"><div href="#" style="text-align: center; vartical-aline:middle; width: 50px; height: 50px; margin: 8px; background: #333438;">
                                              <?php
                                              if($this->settings['theam_color']=='default')
                                                {
                                                  echo $img;
                                                }
                                                ?>       
                                            </div></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="theambutton color2" data-id="2"><div href="#" style="text-align: center; vartical-aline:middle; width: 50px; height: 50px; margin: 8px; background: #2b3643;">
                                              <?php
                                              if($this->settings['theam_color']=='darkblue')
                                                {
                                                  echo $img;
                                                }
                                                ?>       

                                            </div></span></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="theambutton color3" data-id="3"><div href="#" style="text-align: center; vartical-aline:middle; width: 50px; height: 50px; margin: 8px; background: #2D5F8B;">
                                               <?php
                                              if($this->settings['theam_color']=='blue')
                                                {
                                                  echo $img;
                                                }
                                                ?>
                                            </div></span></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="theambutton color4" data-id="4"><div href="#" style="text-align: center; vartical-aline:middle; width: 50px; height: 50px; margin: 8px; background: #697380;">
                                              <?php
                                              if($this->settings['theam_color']=='grey')
                                                {
                                                  echo $img;
                                                }
                                              ?>
                                              
                                            </div></span></a>
                                            </td>
                                            <td>
                                           <!--  <a href="JavaScript:void(0)" class="theambutton color5" data-id="5"><div href="#" style="width: 50px; height: 50px; margin: 8px; background: #F1F1F1;"></div></span></a> -->
                                            <a href="JavaScript:void(0)" class="theambutton color6" data-id="6"><div href="#" style="text-align: center; width: 50px; height: 50px; margin: 8px; background: #bb2828;">
                                              <?php
                                              if($this->settings['theam_color']=='custom')
                                                {
                                                  echo $img;
                                                }
                                              ?>                                              
                                              
                                            </div></span></a>
                                            </td>
                                          </tr>
                                        </table>

                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group"> 
                                          <div style="padding-top: 30px;">
                                          <input type="submit" name="submit_theam_color" class="btn <?=$this->settings['success_color'];?>" value="Save" disabled>
                                          </div>
                                      </div>
                                  </div>
                                </form>
                                
                            </div>
                            <hr>
                            <div class="row" style="vertical-align: middle;">
                                <form method="post">
                                  <input type="hidden" name="button_color" value="1" id="success_color_name">
                                  <div class="col-md-4">
                                      <div class="form-group">
                                          <h4>Success Button Color</h4>
                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group">
                                        <table>
                                          <tr>
                                            <td>
                                            <a href="JavaScript:void(0)" class="successbutton success_color1" data-id="1"><div href="#" class="bg-green-jungle" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #26C281;">
                                              <?php
                                              if($this->settings['success_color']=='green-jungle')
                                                {
                                                  echo $img;
                                                }
                                              ?>   
                                            </div></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="successbutton success_color2" data-id="2"><div href="#" class="bg-yellow-gold" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #E87E04;">
                                              <?php
                                              if($this->settings['success_color']=='yellow-gold')
                                                {
                                                  echo $img;
                                                }
                                              ?>                                               
                                            </div></span></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="successbutton success_color3" data-id="3"><div href="#" class="bg-purple" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #8E44AD;">
                                              <?php
                                              if($this->settings['success_color']=='purple')
                                                {
                                                  echo $img;
                                                }
                                              ?>                                               
                                            </div></span></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="successbutton success_color4" data-id="4"><div href="#" class="bg-blue" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #3598dc;">
                                              <?php
                                              if($this->settings['success_color']=='blue')
                                                {
                                                  echo $img;
                                                }
                                              ?>                                               
                                            </div></span></a>
                                            </td>
                                            <td>
                                           <!--  <a href="JavaScript:void(0)" class="successbutton success_color5" data-id="5"><div href="#" class="#" style="text-align:center; width: 50px; height: 50px; margin: 8px;"></div></span></a> -->
                                            <a href="JavaScript:void(0)" class="successbutton success_color6" data-id="6"><div href="#" class="bg-green-haze" style="text-align:center; width: 50px; height: 50px; margin: 8px;  background: #44b6ae;">
                                              <?php
                                              if($this->settings['success_color']=='green-haze')
                                                {
                                                  echo $img;
                                                }
                                              ?>                                               
                                            </div></span></a>
                                            </td>
                                          </tr>
                                        </table>

                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group"> 
                                          <div style="padding-top: 8px;">
                                          <input type="submit" name="submit_sucsess_color" class="btn <?=$this->settings['success_color'];?>" value="Save" disabled>
                                          </div>
                                      </div>
                                  </div>
                                </form>
                                
                            </div>
                            <hr>
                            <div class="row" style="vertical-align: middle;">
                                <form method="post">
                                  <input type="hidden" name="danger_button_color" value="1" id="danger_button_color">
                                  <div class="col-md-4">
                                      <div class="form-group">
                                          <h4>Danger Button Color</h4>
                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group">
                                        <table>
                                          <tr>
                                            <td>
                                            <a href="JavaScript:void(0)" class="dangerbutton danger_color1" data-id="1"><div href="#" class="bg-red" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #e7505a;">
                                               <?php
                                              if($this->settings['danger_color']=='red')
                                                {
                                                  echo $img;
                                                }
                                              ?>
                                            </div></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="dangerbutton danger_color2" data-id="2"><div href="#" class="bg-red-thunderbird" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #D91E18;">
                                            <?php
                                              if($this->settings['danger_color']=='red-thunderbird')
                                                {
                                                  echo $img;
                                                }
                                              ?>
                                            </div></span></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="dangerbutton danger_color3" data-id="3"><div href="#" class="bg-red-mint" style="text-align:center; width: 50px; height: 50px; margin: 8px;  background: #e43a45;">
                                            <?php
                                              if($this->settings['danger_color']=='red-mint')
                                                {
                                                  echo $img;
                                                }
                                              ?>
                                            </div></span></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="dangerbutton danger_color4" data-id="4"><div href="#" class="bg-red-haze" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #f36a5a;">
                                            <?php
                                              if($this->settings['danger_color']=='red-haze')
                                                {
                                                  echo $img;
                                                }
                                              ?>
                                            </div></span></a>
                                            </td>
                                            <td>
                                           <!--  <a href="JavaScript:void(0)" class="dangerbutton danger_color5" data-id="5"><div href="#" class="#" style="text-align:center; width: 50px; height: 50px; margin: 8px;">
                                            </div></span></a> -->
                                            <a href="JavaScript:void(0)" class="dangerbutton danger_color6" data-id="6"><div href="#" class="bg-red-soft" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #d05454;">
                                            <?php
                                              if($this->settings['danger_color']=='red-soft')
                                                {
                                                  echo $img;
                                                }
                                              ?>
                                            </div></span></a>
                                            </td>
                                          </tr>
                                        </table>

                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group"> 
                                          <div style="padding-top: 8px;">
                                          <input type="submit" name="submit_denger_color" class="btn <?=$this->settings['success_color'];?>" value="Save" disabled>
                                          </div>
                                      </div>
                                  </div>
                                </form>
                                
                            </div>
                            <hr>
                            <div class="row" style="vertical-align: middle;">
                                <form method="post">
                                  <input type="hidden" name="warning_button_color" value="1" id="warning_button_color">
                                  <div class="col-md-4">
                                      <div class="form-group">
                                          <h4>Warning Button Color</h4>
                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group">
                                        <table>
                                          <tr>
                                            <td>
                                            <a href="JavaScript:void(0)" class="warningbutton warning_color1" data-id="1"><div href="#" class="yellow-crusta" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #f3c200;">
                                               <?php
                                              if($this->settings['warning_button_color']=='yellow-crusta')
                                                {
                                                  echo $img;
                                                }
                                              ?>
                                            </div></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="warningbutton warning_color2" data-id="2"><div href="#" class="yellow-soft" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #c8d046;">
                                            <?php
                                              if($this->settings['warning_button_color']=='yellow-soft')
                                                {
                                                  echo $img;
                                                }
                                              ?>
                                            </div></span></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="warningbutton warning_color3" data-id="3"><div href="#" class="yellow-casablanca" style="text-align:center; width: 50px; height: 50px; margin: 8px;  background: #f2784b;">
                                            <?php
                                              if($this->settings['warning_button_color']=='yellow-casablanca')
                                                {
                                                  echo $img;
                                                }
                                              ?>
                                            </div></span></a>
                                            </td>
                                            <td>
                                            <a href="JavaScript:void(0)" class="warningbutton warning_color4" data-id="4"><div href="#" class="grey-salt" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #bfcad1;">
                                            <?php
                                              if($this->settings['warning_button_color']=='grey-salt')
                                                {
                                                  echo $img;
                                                }
                                              ?>
                                            </div></span></a>
                                            </td>
                                            <td>
                                           <!--  <a href="JavaScript:void(0)" class="dangerbutton danger_color5" data-id="5"><div href="#" class="#" style="text-align:center; width: 50px; height: 50px; margin: 8px;">
                                            </div></span></a> -->
                                            <a href="JavaScript:void(0)" class="warningbutton warning_color6" data-id="6"><div href="#" class="grey-mint" style="text-align:center; width: 50px; height: 50px; margin: 8px; background: #555;">
                                            <?php
                                              if($this->settings['warning_button_color']=='grey-mint')
                                                {
                                                  echo $img;
                                                }
                                              ?>
                                            </div></span></a>
                                            </td>
                                          </tr>
                                        </table>

                                      </div>
                                  </div>
                                   <div class="col-md-4">
                                      <div class="form-group"> 
                                          <div style="padding-top: 8px;">
                                          <input type="submit" name="submit_warning_color" class="btn <?=$this->settings['success_color'];?>" value="Save" disabled>
                                          </div>
                                      </div>
                                  </div>
                                </form>
                                
                            </div>
                            <!-- <div class="row">
                               <div class="col-md-12">
                                <a href="<?=base_url();?>Log/view_logs?key=admin" class="btn dark pull-right" target="_blank"> Show Log </a>

                              </div>
                              
                            </div> -->
                              
                        </div>
                    </div>
                </div>
                <div class="panel panel-default">
    
                    
                </div>
            </div>
        </div>
    </div>
</div>

         </div>
         <!-- panel body -->
      </div>
      <!-- panel-->
      <!-- END SAMPLE FORM PORTLET-->
   </div>
</div>
<!-- row -->
<script type="text/javascript">
   document.addEventListener('DOMContentLoaded', function()
   {
    $("input[name=app_name]").keyup(function()
      {
        $("input[name=submit_appname]").removeAttr("disabled");
      });
    $("input[name=footer_text]").keyup(function()
      {
        $("input[name=submit_footer]").removeAttr("disabled");
      });
    $("#remove_logo").click(function(){
      console.log("remove_logo");
      $("#currunt_logo").hide();
      $("#remove_logo").hide();
      $("#input_file_uplode").show();
      $("#submit_logo_uplode").show();
    });
      $("#input_file_uplode").hide();
      $("#submit_logo_uplode").hide();


      $("#remove_logo_fev").click(function(){
      console.log("remove_logo");
      $("#currunt_logo_fev").hide();
      $("#remove_logo_fev").hide();
      $("#input_file_uplode_fev").show();
      $("#submit_logo_uplode_fev").show();
    });
      $("#input_file_uplode_fev").hide();
      $("#submit_logo_uplode_fev").hide();


    //input_file_uplode_fev
      $(".theambutton").click(function(){
        var ele=$(this);
        var id=ele.data("id");
        var selected="color"+id;
        $("input[name=submit_theam_color]").removeAttr("disabled");
        $("#color_name").val(id);
        $(".theambutton div").attr('class', '');
        $("."+selected+" div").addClass("selected_color");
      });
      $(".successbutton").click(function(){
        var ele=$(this);
        var id=ele.data("id");
        var selected="success_color"+id;
        $("input[name=submit_sucsess_color]").removeAttr("disabled");
        $("#success_color_name").val(id);
        $(".successbutton div").attr('class', '');
        $("."+selected+" div").addClass("selected_color");
      });
      $(".dangerbutton").click(function(){
        var ele=$(this);
        var id=ele.data("id");
        var selected="danger_color"+id;
        $("input[name=submit_denger_color]").removeAttr("disabled");
        $("#danger_button_color").val(id);
        $(".dangerbutton div").attr('class', '');
        $("."+selected+" div").addClass("selected_color");
      });
      $(".warningbutton").click(function(){
        var ele=$(this);
        var id=ele.data("id");
        var selected="warning_color"+id;
        $("input[name=submit_warning_color]").removeAttr("disabled");
        $("#warning_button_color").val(id);
        $(".warningbutton div").attr('class', '');
        $("."+selected+" div").addClass("selected_color");
      });
      $(".radio_direction").click(function(){
        var ele=$(this);
        var val=ele.val();
        // console.log(val);
        $("input[name=theme_direction]").removeAttr("disabled");
      });
      
      //danger_button_color
      $(document).on("click",".save_data",function()
     {
      var ele=$(this);
      ele.attr("disabled", 'disabled');
          $.ajax({
               url:"<?=base_url("ajax_controller/update_role");?>",
               type: "POST",
               data:$("#role_data").serialize(),
               dataType : "json",
               success:function(data){
                console.log(data);
                if(data.status=1)
                {
                  location.reload();
                }
             },
               error:function(data){ 
                   console.log(data);
               }
           });//ajax
      });
    });
  
</script>