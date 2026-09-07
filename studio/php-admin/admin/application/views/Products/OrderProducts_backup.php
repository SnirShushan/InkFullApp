<style type="text/css">
    .ui-state-default{
        cursor: all-scroll;
    }
</style>
<div class="portlet light bordered">
	
	<div class="portlet-body form">
	
        <div class="panel-group accordion" id="accordion3">
            <div class="mt-element-list">
                <div class="mt-list-container list-simple ext-1 group">
                    <?php foreach ($list as $key =>$value) { ?>
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4 class="panel-title">
                                    <a class="accordion-toggle accordion-toggle-styled collapsed" data-toggle="collapse" data-parent="#accordion3" href="#collapse_3_<?=$key?>"> <?=$value?> </a>
                                </h4>
                            </div>
                            <div id="collapse_3_<?=$key?>" class="panel-collapse collapse">
                                <div class="panel-body">
                                    <ul id="sortable_<?=$key?>"  class="sortable_cls" >
                                        <?php  foreach ($list_p[$key] as $p) { ?>
                                            <li class="mt-list-item ui-state-default" id="<?=$p['id']?>"  seq="<?=$p['seq']?>">
                                                <div class="list-item-content">
                                                    <h3 class="uppercase">
                                                        <?=$p['name']?>
                                                    </h3>
                                                </div>
                                            </li>
                                        <?php } ?>

                                    </ul>
                                    <br>
                                    <button class="btn btn-success btn-block save_seq"  type="button" data-key="<?=$key?>" id="save_seq_<?=$key?>">Save</button>
                                    <input type="hidden" name="seq_<?=$key?>" id="seq_<?=$key?>" />
                                </div><!-- panel-body -->
                            </div><!-- panel-collapse -->
                        </div><!--  panel-default -->
                    <?php } ?>
                </div>
            </div>
        </div>




	    
	</div><!-- panel body -->
</div>

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function()
{
    $( ".sortable_cls" ).sortable({
        update: function(event, ui) { 
             
        }
    });
    
    $('.sortable_cls').disableSelection();

  


   $(".save_seq").click(function(){
        var key=$(this).data("key");
        var itemOrder = $('#sortable_'+key).sortable("toArray");
        console.log(itemOrder);
        console.log(JSON.stringify(itemOrder));
        var re1=JSON.stringify(itemOrder);
        $("#seq_"+key).val(re1);
        var ele=$(this);
        ele.attr("disabled","disabled");
        $.ajax({
            url:'<?php echo base_url("Ajax_controller/save_product_seq");?>',
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

var $myGroup = $('#accordion3');
$myGroup.on('show.bs.collapse','.collapse', function() {
    $myGroup.find('.collapse.in').collapse('hide');
});

   
});
</script>
