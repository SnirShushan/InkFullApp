<?php 
defined('BASEPATH') OR exit('No direct script access allowed');

$lang['db_invalid_connection_str']	=	"לא ניתן לקבוע את הגדרות מסד הנתונים בהתבסס על מחרוזת החיבור שהגשת."; //Unable to determine the database settings based on the connection string you submitted.
$lang['db_unable_to_connect']	=	"לא ניתן להתחבר לשרת מסד הנתונים שלך באמצעות ההגדרות שסופקו."; //Unable to connect to your database server using the provided settings.
$lang['db_unable_to_select']	=	"לא ניתן לבחור את מסד הנתונים שצוין: %s"; //Unable to select the specified database: %s
$lang['db_unable_to_create']	=	"לא ניתן ליצור את מסד הנתונים שצוין: %s"; //Unable to create the specified database: %s
$lang['db_invalid_query']	=	"השאילתה ששלחת אינה חוקית."; //The query you submitted is not valid.
$lang['db_must_set_table']	=	"עליך להגדיר את טבלת מסד הנתונים שתשתמש בה עם השאילתה שלך."; //You must set the database table to be used with your query.
$lang['db_must_use_set']	=	'עליך להשתמש בשיטת "הגדר" כדי לעדכן ערך.'; //You must use the "set" method to update an entry.
$lang['db_must_use_index']	=	"עליך לציין אינדקס להתאמה לעדכוני אצווה."; //You must specify an index to match on for batch updates.
$lang['db_batch_missing_index']	=	"בשורה אחת או יותר שנשלחו לעדכון אצווה חסר האינדקס שצוין."; //One or more rows submitted for batch updating is missing the specified index.
$lang['db_must_use_where']	=	'אסור לעדכן אלא אם כן הם מכילים סעיף "איפה".'; //Updates are not allowed unless they contain a "where" clause.
$lang['db_del_must_use_where']	=	'מחיקות אינן מורשות אלא אם הן מכילות סעיף "איפה" או "כמו".'; //Deletes are not allowed unless they contain a "where" or "like" clause.
$lang['db_field_param_missing']	=	"כדי לאחזר שדות נדרש שם הטבלה כפרמטר."; //To fetch fields requires the name of the table as a parameter.
$lang['db_unsupported_function']	=	"תכונה זו אינה זמינה עבור מסד הנתונים בו אתה משתמש."; //This feature is not available for the database you are using.
$lang['db_transaction_failure']	=	"כשל בעסקה: ביצוע החזרת הכוח."; //Transaction failure: Rollback performed.
$lang['db_unable_to_drop']	=	"לא ניתן להוריד את מסד הנתונים שצוין."; //Unable to drop the specified database.
$lang['db_unsupported_feature']	=	"תכונה לא נתמכת של פלטפורמת מסד הנתונים בה אתה משתמש."; //Unsupported feature of the database platform you are using.
$lang['db_unsupported_compression']	=	"פורמט דחיסת הקבצים שבחרת אינו נתמך על ידי השרת שלך."; //The file compression format you chose is not supported by your server.
$lang['db_filepath_error']	=	"לא ניתן לכתוב נתונים לנתיב הקובץ ששלחת."; //Unable to write data to the file path you have submitted.
$lang['db_invalid_cache_path']	=	"נתיב המטמון ששלחת אינו תקף או ניתן לכתיבה."; //The cache path you submitted is not valid or writable.
$lang['db_table_name_required']	=	"לשם פעולה זו נדרש שם טבלה."; //A table name is required for that operation.
$lang['db_column_name_required']	=	"לשם העמודה נדרש שם עמודה."; //A column name is required for that operation.
$lang['db_column_definition_required']	=	"נדרשת הגדרת עמודה עבור פעולה זו."; //A column definition is required for that operation.
$lang['db_unable_to_set_charset']	=	"לא ניתן להגדיר ערכת תווים של חיבור לקוח: %s"; //Unable to set client connection character set: %s
$lang['db_error_heading']	=	"שגיאת מסד נתונים התרחשה"; //A Database Error Occurred
