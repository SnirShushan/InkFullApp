<div class="portlet light bordered">
    <div class="portlet-body form">

        <div class="row">

            <?php

            foreach ($my_data as $document) {
                if ($document->exists()) {
            ?>
                    <div class="col-md-3">
                        <img src="<?= $document->data()['productImage'][0]; ?>" class="img-thumbnail">
                    </div>
            <?php
                }
            }
            ?>

        </div>
    </div><!-- panel body -->
</div>

<script type="text/javascript">
    document.addEventListener('DOMContentLoaded', function() {







    });
</script>