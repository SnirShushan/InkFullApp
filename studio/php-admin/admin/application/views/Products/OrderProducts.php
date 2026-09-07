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
                    <?php  $list_parent_cat_ids=[]; $list_cat_sub_ids_all=[];  foreach ($list as $key =>$value) { $list_parent_cat_ids[]=$key; ?>
                        <div class="panel panel-default">
                            <div class="panel-heading">
                                <h4 class="panel-title">
                                    <a class="accordion-toggle accordion-toggle-styled collapsed" data-toggle="collapse" data-parent="#accordion3" href="#collapse_3_<?=$key?>"> <?=$value?> </a>
                                </h4>
                            </div>
                            <div id="collapse_3_<?=$key?>" class="panel-collapse collapse">
                                <div class="panel-body">
                                    <ul id="sortable_main_<?=$key?>"  class="sortable_cls_<?=$key?> sortable_main_<?=$key?>" >
                                     <?php $list_cat_sub_ids=[];  foreach ($sub_list[$key]['sub_list'] as $sc) {  $list_cat_sub_ids[]=$sc['id']; $list_cat_sub_ids_all[]=$sc['id']; ?>
                                        <li class="mt-list-item ui-state-default drag-cat-<?=$key?>" id="<?=$sc['id']?>" data-parent="<?=$key?>" data-cat="<?=$sc['id']?>"  seq="<?=$sc['seq']?>">
                                            <div class="list-item-content">
                                                <div class="panel panel-default">
                                                    <div class="panel-heading">
                                                        <h4 class="panel-title">
                                                            <a class="accordion-toggle accordion-toggle-styled collapsed" data-toggle="collapse" data-parent="#accordion3_1" href="#collapse_3_1_<?=$key?>_<?=$sc['id']?>"> <?=$sc['name']?> </a>
                                                        </h4>
                                                    </div>
                                                    <div id="collapse_3_1_<?=$key?>_<?=$sc['id']?>" class="panel-collapse collapse">
                                                        <div class="panel-body">

                                                            <ul id="sortable_<?=$sc['id']?>_<?=$key?>"  class="sortable_cls_<?=$sc['id']?> sortable_<?=$sc['id']?>_<?=$key?>" >
                                                                <?php  foreach ($sc['products'] as $p) { ?>
                                                                    <li class="mt-list-item ui-state-default" id="<?=$p['id']?>" data-parent="<?=$key?>" data-cat="<?=$sc['id']?>"  seq="<?=$p['seq']?>">
                                                                        <div class="list-item-content">
                                                                            <h3 class="uppercase">
                                                                                <?=$p['name']?>
                                                                            </h3>
                                                                        </div>
                                                                    </li>
                                                                <?php } ?>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </li>
                                        <?php } ?>
                                        </ul>
                                    
                                    <br>
                                    <button class="btn btn-success btn-block save_seq" data-sub_ids="<?=implode(",", $list_cat_sub_ids)?>"  type="button" data-key="<?=$key?>" id="save_seq_<?=$key?>">Save</button>
                                    <input type="hidden" name="seq_<?=$key?>" id="seq_<?=$key?>" />
                                </div><!-- panel-body -->
                            </div><!-- panel-collapse -->
                        </div><!--  panel-default -->
                    <?php } ?>
                    <input type="hidden" name="seq_cat_<?=$key?>" id="seq_cat_<?=$key?>" />
                </div>
            </div>
        </div>




	    
	</div><!-- panel body -->
</div>

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function()
{
    var arr_sub_ids_all=<?=json_encode($list_cat_sub_ids_all)?>;
    var list_parent_cat_ids=<?=json_encode($list_parent_cat_ids)?>;

    for(var k=0;k<=arr_sub_ids_all.length;k++)
    {

        $( ".sortable_cls_"+arr_sub_ids_all[k] ).sortable({
            update: function(event, ui) {              
            }
        });   
    }


    for(var k=0;k<=list_parent_cat_ids.length;k++)
    {

        $( ".sortable_main_"+list_parent_cat_ids[k] ).sortable({
            update: function(event, ui) {              
            }
        });   
    }


    for(var k=0;k<=arr_sub_ids_all.length;k++)
    {
        $( ".sortable_cls_"+arr_sub_ids_all[k]).disableSelection();
        
    }
    
    

  
    for(var k=0;k<=list_parent_cat_ids.length;k++)
    {
         $( ".sortable_main_"+list_parent_cat_ids[k]).disableSelection();
    }


   $(".save_seq").click(function(){
        var key=$(this).data("key");
        var main_arr=[];
        $(".drag-cat-"+key).each(function(idx){
            console.log(this);
            var sub_id=$(this).data("cat");
            console.log(sub_id);
            var itemOrder = $('.sortable_cls_'+sub_id).sortable("toArray");
            console.log(itemOrder);
            main_arr=main_arr.concat(itemOrder);
        });
        
        /*
        var sub_ids=$(this).data("sub_ids")+"";
          var arr_sub_ids=[];
        //console.log(sub_ids);
        var c=sub_ids.search(",");
        if(c)
        {
            var arr_sub_ids=sub_ids.split(",");    
        }
        var main_arr=[];
        for(var i=0;i<arr_sub_ids.length;i++)
        {

           
            var itemOrder = $('.sortable_cls_'+arr_sub_ids[i]).sortable("toArray");
            console.log(itemOrder);
            main_arr=main_arr.concat(itemOrder);
            //console.log(JSON.stringify(itemOrder))
        }*/
        //console.log(main_arr);
        //console.log(JSON.stringify(main_arr));
        //var arr_sub_ids=sub_ids.split(",");
        //console.log(arr_sub_ids);
        
        var re1=JSON.stringify(main_arr);
        //console.log("re1");
        //console.log(re1);


        var main_cat_arr=[];

        for(var k=0;k<list_parent_cat_ids.length;k++)
        {
             var itemOrder = $( ".sortable_main_"+list_parent_cat_ids[k]).sortable("toArray");
             //console.log(list_parent_cat_ids[k]);
             main_cat_arr=main_cat_arr.concat(itemOrder);
        }
         var main_cat_re1=JSON.stringify(main_cat_arr);
        


        $("#seq_"+key).val(re1);
        $("#seq_cat_"+key).val(main_cat_re1);
        var ele=$(this);
        
        ele.attr("disabled","disabled");
        $.ajax({
            url:'<?php echo base_url("Ajax_controller/save_product_seq");?>',
            data:{seq:re1,seq_cat:main_cat_re1},
            type:"POST",
            success:function(data){
                swal("Success", "Saved successfully", "success");
                ele.removeAttr("disabled");
            },
            error:function(data){
                swal("Cancelled", "Operation Cancelled", "error");
                ele.removeAttr("disabled");
            }
        });
   });

var $myGroup = $('#accordion3');
$myGroup.on('show.bs.collapse','.collapse', function() {
    //$myGroup.find('.collapse.in').collapse('hide');
});

   
});
</script>
