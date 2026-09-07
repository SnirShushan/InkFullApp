<style type="text/css">
    .ui-state-default{
        cursor: all-scroll;
    }
</style>
<div class="portlet light bordered">
	
	<div class="portlet-body form">
	
     


        <div class="mt-element-list">
            <div class="mt-list-container list-simple ext-1 group">
                <div class="panel-collapse collapse in" id="completed-simple">
                    <ul id="sortable1"  >
                        <?php foreach ($list as $key =>$value) { ?>
                            <li class="mt-list-item ui-state-default" id="<?php echo $key; ?>">
                                <div class="list-item-content">
                                    <h3 class="uppercase">
                                        <?php echo $value; ?>
                                    </h3>
                                </div>
                            </li>
                        <?php } ?>

                    </ul>
                    <br>
                    <button class="btn btn-success btn-block" type="button" id="save_seq">Save</button>
                    <input type="hidden" name="seq" id="seq" />
                </div><!-- panel-collapse -->
            </div><!-- mt-list-container -->
        </div><!-- mt-element-list -->

	    
	</div><!-- panel body -->
</div>

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function()
{
    $( "#sortable1" ).sortable({
        update: function(event, ui) { 
             
        }
    });
    $( "#sortable1" ).disableSelection();

   $("#save_seq").click(function(){
        var itemOrder = $('#sortable1').sortable("toArray");
        console.log(itemOrder);
        console.log(JSON.stringify(itemOrder));
        var re1=JSON.stringify(itemOrder);
        $("#seq").val(re1);
        var ele=$(this);
        ele.attr("disabled","disabled");
        $.ajax({
            url:'<?php echo base_url("Ajax_controller/save_seq");?>',
            data:{seq:re1},
            type:"POST",
            success:function(data){
                swal("Success", "Saved successfully", "success");
                ele.removeAttr("disabled");
            },
            error:function(data){
                swal("Cancelled", "Operation Cancelled", "error");
                ele.removeAttr("disabled");
            }
        })
      

   });
   
});
</script>
