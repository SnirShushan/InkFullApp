<?php 
defined('BASEPATH') OR exit('No direct script access allowed');

$lang['email_must_be_array']	=	'יש להעביר את שיטת אימות הדוא"ל כמערך.'; //The email validation method must be passed an array.
$lang['email_invalid_address']	=	'כתובת דוא"ל לא חוקית: %s' //Invalid email address: %s
$lang['email_attachment_missing']	=	'אין אפשרות לאתר את הקובץ המצורף לדוא"ל הבא: %s'; //Unable to locate the following email attachment: %s
$lang['email_attachment_unreadable']	=	"לא ניתן לפתוח קובץ מצורף זה: %s"; //Unable to open this attachment: %s
$lang['email_no_from']	=	'לא ניתן לשלוח דואר ללא כותרת "מאת".'; //Cannot send mail with no "From" header.
$lang['email_no_recipients']	=	"עליכם לכלול נמענים: אל, עותק או עותק מוסתר"; //You must include recipients: To, Cc, or Bcc
$lang['email_send_failure_phpmail']	=  'לא ניתן לשלוח דוא"ל באמצעות דואר PHP (). ייתכן שהשרת שלך לא מוגדר למשלוח דואר בשיטה זו.'; //Unable to send email using PHP mail(). Your server might not be configured to send mail using this method.
$lang['email_send_failure_sendmail']	=	'לא ניתן לשלוח דוא"ל באמצעות PHP Sendmail. ייתכן שהשרת שלך לא מוגדר למשלוח דואר בשיטה זו.'; //Unable to send email using PHP Sendmail. Your server might not be configured to send mail using this method.
$lang['email_send_failure_smtp']	=	'לא ניתן לשלוח דוא"ל באמצעות PHP SMTP. ייתכן שהשרת שלך לא מוגדר למשלוח דואר בשיטה זו.'; //Unable to send email using PHP SMTP. Your server might not be configured to send mail using this method.
$lang['email_sent']	=	"ההודעה שלך נשלחה בהצלחה באמצעות הפרוטוקול הבא: %s"; //Your message has been successfully sent using the following protocol: %s
$lang['email_no_socket']	=	"לא ניתן לפתוח שקע ל- Sendmail. אנא בדוק הגדרות."; //Unable to open a socket to Sendmail. Please check settings.
$lang['email_no_hostname']	=	"לא ציינת שם מארח של SMTP."; //You did not specify a SMTP hostname.
$lang['email_smtp_error']	=	"אירעה שגיאת SMTP הבאה: %s"; //The following SMTP error was encountered: %s
$lang['email_no_smtp_unpw']	=	"שגיאה: עליך להקצות שם משתמש וסיסמא של SMTP."; //Error: You must assign a SMTP username and password.
$lang['email_failed_smtp_login']	=	"שליחת הפקודה AUTH LOGIN נכשלה. שגיאה: %s"; //Failed to send AUTH LOGIN command. Error: %s
$lang['email_smtp_auth_un']	=	"אימות שם המשתמש נכשל. שגיאה: %s"; //Failed to authenticate username. Error: %s
$lang['email_smtp_auth_pw']	=	"אימות הסיסמה נכשל. שגיאה: %s"; //Failed to authenticate password. Error: %s
$lang['email_smtp_data_failure']	=	"לא ניתן לשלוח נתונים: %s"; //Unable to send data: %s
$lang['email_exit_status']	=	"קוד סטטוס יציאה: %s"; //Exit status code: %s
