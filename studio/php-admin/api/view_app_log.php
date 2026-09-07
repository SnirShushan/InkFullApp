<?php 
global $output_type;
$output_type=0;
include "header.php";
get_header(['title'=>"Log "]);
$filename=$_REQUEST['file'];
$res=file_get_contents(__DIR__."/errors/app_log/".$filename);
$obj=json_decode($res);
?>

<div class="container">
    <div class="row">
        <div class="col-md-12 ">
            <!-- Button trigger modal -->
            <center>
                <h3><?php echo $filename; ?></h3>
            </center>
            <div class="row">
                <div class="col">
                </div>
            </div>
            <table class="table table-sm" id="tbl_data">
                <thead>
                    <tr>
                        <th scope="col">Date</th>
                        <th scope="col">Type</th>
                        <th scope="col">Message</th>
                        <th scope="col"></th>
                    </tr>
                </thead>
                <tbody>
                <tbody id="container_row">
                    <?php
                    $bg="";$i=1;
                        foreach($obj as $value)
                        {

                            if(empty($value->title))
                            {
                                $value->title="";
                            }
                        ?>

                    <tr <?=$bg?> class="">
                        <th <?=$bg?> scope="row"><?php echo $value->date; ?></th>
                        <td <?=$bg?>> <?php echo $value->title;  ?></td>
                        <td <?=$bg?>>
                            <?php if(!empty($value->data))
                            {
                                $allow="0";
                                if(!is_object($value->data) && !is_array($value->data))
                                { 
                                    $allow="1";
                                    if(strlen($value->data)>25)
                                    {
                                        $value->data=[$value->data];   
                                        $allow="0";
                                    } 
                                }

                                if($allow=="1")
                                { 
                                echo $value->data;
                                }else{ 
                                echo "<a href='javascript:void(0);'  class='view_more' data-toggle='modal' data-target='#view_container_$i'  data-id='$i' >View Data</a>";?>
                            <!-- Modal -->
                            <div class="modal fade" id="view_container_<?php echo $i; ?>" tabindex="-1" role="dialog"
                                aria-labelledby="exampleModalScrollableTitle" aria-hidden="true">
                                <div class="modal-dialog modal-lg modal-dialog-scrollable" role="document">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="exampleModalLabel">Data</h5>
                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                <span aria-hidden="true">&times;</span>
                                            </button>
                                        </div>
                                        <div class="modal-body">
                                            <?php $rdn_id=rand(); ?>
                                            <div id="code_<?php echo $rdn_id; ?>">

                                            </div>
                                            <script type="text/javascript">
                                            $('#code_<?php echo $rdn_id; ?>').jsonViewer(
                                                <?php echo json_encode($value->data); ?>, {
                                                    collapsed: false,
                                                    withQuotes: true,
                                                    withLinks: false
                                                });
                                            </script>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-secondary"
                                                data-dismiss="modal">Close</button>

                                        </div>
                                    </div>
                                </div>
                            </div>
                            <?php
                                
                                
                                }
                            }   ?>
                        </td>

                    </tr>
                    <?php  $i++;} ?>
                </tbody>


            </table>
        </div><!-- col-md-9-->
    </div><!-- row -->




</div><!-- container -->
<?php include "footer.php"; ?>