<?php 
defined('BASEPATH') OR exit('No direct script access allowed');

$lang['migration_none_found']	=	"לא נמצאו הגירות."; //No migrations were found.
$lang['migration_not_found']	=	"לא ניתן היה למצוא הגירה עם מספר הגרסה: %s."; //No migration could be found with the version number: %s.
$lang['migration_sequence_gap']	=	"יש פער ברצף ההעברה ליד מספר הגרסה: %s."; //There is a gap in the migration sequence near version number: %s.
$lang['migration_multiple_version']	=	"ישנן מספר הגירות עם אותו מספר גרסה: %s."; //There are multiple migrations with the same version number: %s.
$lang['migration_class_doesnt_exist']	=	'לא ניתן למצוא את מחלקת ההעברה " %s".'; //The migration class "%s" could not be found.
$lang['migration_missing_up_method']	=	'בשיעור ההעברה " %s" חסרה שיטת "למעלה".'; //The migration class "%s" is missing an "up" method.
$lang['migration_missing_down_method']	=	'בכיתה ההגירה " %s" חסרה שיטת "למטה".'; //The migration class "%s" is missing a "down" method.
$lang['migration_invalid_filename']	=	'להעברה " %s" יש שם קובץ לא חוקי.'; //Migration "%s" has an invalid filename.
