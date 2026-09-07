                    <?php 
                        $msg = get_flashdata('msg');
                    if($msg!=''): ?>
                    <div class="alert alert-success">
                      <strong><?php echo $msg; ?></strong>
                    </div>
                    <?php endif; ?>

                    <div class="login-heading">
                        <h3><?php echo $this->settings['name']; ?></h3>
                        <p>Sign in to continue to the admin panel</p>
                    </div>

                    <form action="<?=base_url("login")?>" id="loginForm" method="post">
                        <div class="form-group">
                            <label class="control-label" for="username">Email</label>
                            <input type="text" placeholder="example@gmail.com" title="Please enter you email" required="" value="" name="username" id="username" class="form-control" autocomplete="username">
                            <span class="input-form-error"></span>
                        </div>
                        <div class="form-group">
                            <label class="control-label" for="password">Password</label>
                            <input type="password" title="Please enter your password" placeholder="••••••••" required="" value="" name="password" id="password" class="form-control" autocomplete="current-password">
                            <span class="input-form-error"></span>
                        </div>

                        <button type="submit" class="btn btn-success btn-block" name="btn_login">Login</button>
                    </form>
