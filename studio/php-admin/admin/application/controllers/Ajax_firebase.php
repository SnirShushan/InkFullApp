<?php 
defined('BASEPATH') OR exit('No direct script access allowed');
/*ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);*/
class ajax_firebase extends ci_controller
{
	public $settings = [];

    public function __construct()
    {
        parent::__construct();
       // $this->settings = $this->auth->get_settings();
        
        

        //$this->db->trans_start();

        //sesstion need refresh so do here
        //is_login(true); added in hook
    }
    
    public function index()
    {

    }

    /*--START--LOGIN--API----------------------------------*/
 

        public function sign_in(){
            $res = ['status'=>false,'msg'=>'','new_user'=>false];

            if( $this->auth->is_login() ){
                $res['msg']="Already login";
                echo json_encode($res);
                die();
            }

            if($this->input->post()){

                $config=[
                    array(
                        'field' => 'phone',
                        'label' => 'phone',
                        'rules' => 'required'
                    ),
                    array(
                        'field' => 'phone_code_id',
                        'label' => 'phone code',
                        'rules' => 'required'
                    ),
                    array(
                        'field' => 'method',
                        'label' => 'method',
                        'rules' => 'required'
                    ),
                ];

                $this->form_validation->set_rules($config);
                if ($this->form_validation->run()){

                    $this->load->model("firebase_model");

                    $method = $this->input->post('method',true);

                    $phone = $this->input->post('phone',true);
                    $phone_code_id = $this->input->post('phone_code_id',true);
                    $firebase_token = $this->input->post('firebase_token',true);


                    $fb = $this->firebase_model->check_login_user_token($firebase_token);

                    if( $fb['status'] ){
                        $valid_login = true;
                        $res['status'] = true;
                        $res['token']=$firebase_token;
                        $res['phone']=$phone;
                        $action_type="login";
                        if(!empty($this->input->post("action_type")))
                        {
                            $action_type=$this->input->post("action_type");
                            if($action_type=="register")
                            {
                                $res['email']=$this->input->post('email',true);
                            }else{
                                $this->user_model->update_by_phone($phone,["login_token"=>$firebase_token]);
                            }
                        }else{
                            $this->user_model->update_by_phone($phone,["login_token"=>$firebase_token]);
                        }
                        
                    }else{
                        $res['status'] = false;
                        $res['msg'] = "verification failed";
                    }

                }else{
                    $res['status']=false;
                    $res['msg'] = validation_errors();
                }
            }else{
                $res['msg']="Invalid";
            }

            echo json_encode($res);
        }



        public function user_exist(){
            $res = ['status'=>false,'msg'=>'' ];

            if($this->input->post()){
                $phone=$this->input->post("phone",TRUE);
                $row=$this->user_model->check_duplicate_phone($phone);
                if($row=="1")
                {
                    $res['status']=true;
                    
                }else{
                    $res['status']=false;
                    $res['msg']="Phone number not found. Please register";
                }
            }else{
                $res['msg']="Invalid";
            }

            echo json_encode($res);
        }

        public function user_exist_regi(){
            $res = ['status'=>false,'msg'=>'' ];
            $phone_exists=0;
            $email_exists=0;
            if($this->input->post()){
                $phone=$this->input->post("phone",TRUE);
                $email=$this->input->post("email",TRUE);
                $row=$this->user_model->check_duplicate_phone($phone);
                if($row=="1")
                {
                    $phone_exists=1;
                }else{
                    $phone_exists=0;
                }

                $row=$this->user_model->check_duplicate_email($email);
                if($row=="1")
                {
                    $email_exists=1;
                }else{
                    $email_exists=0;
                }

                if($email_exists===0 && $phone_exists===0)
                {
                    $res['status']=true;
                }else{
                    if($email_exists===1)
                    {
                        $res['msg'].=" Email Already exists.";
                    }
                    if($phone_exists===1)
                    {
                        $res['msg'].=" Phone Number Already exists.";
                    }
                }


            }else{
                $res['msg']="Invalid";
            }

            echo json_encode($res);
        }

    /*--END--LOGIN--API----------------------------------*/

 

} // class ends
