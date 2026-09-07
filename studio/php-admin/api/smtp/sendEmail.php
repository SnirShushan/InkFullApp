<?php

include 'class.phpmailer.php';
  $mail = new PHPMailer;
  $mail->IsSMTP(); // telling the class to use SMTP
  $mail->Host = "162.243.43.18"; // SMTP server
  $mail->SMTPDebug = 2;
  $mail->SMTPAuth = false;
  $mail->Host = "localhost";
  $mail->IsHTML(true);
  $mail->SetFrom('info@smart-webtech.com', 'new application submitted');
  $mail->AddReplyTo("info@smart-webtech.com","First Last");
  $mail->Subject = "your subject";
  $mail->MsgHTML("Test");
  //$file_to_attach = 'export_file/export.xlsx';
  //$mail->AddAttachment( $file_to_attach , 'export.xlsx' );
  $mail->AddAddress('nilesh@smart-webtech.com');
 if (!$mail->Send()) {
    /* Error */
    echo 'Message not Sent! ';
  } else {
    /* Success */
    echo 'Sent Successfully! <b> Check your Mail</b>';
  }





 ?>