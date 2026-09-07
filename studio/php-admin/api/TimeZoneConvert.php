<?php 
/*
	$d = new TimeZoneConvert('2021-2-2 00:00:00','UTC');
	echo $d->toTimeZone('UTC +5:30');
*/
class TimeZoneConvert
{
	private $inDateTime = "";
	private $inTimeZone = "";

	private $utcInDateTime = "";

	public function __construct( $date='', $timezone='' )
	{
		if( $date != '' and $timezone != '' ){
			$this->setDateTime( $date, $timezone );
		}
	}

	public function setDateTime( $date, $timezone )
	{
		$this->inDateTime = $date;
		$this->inTimeZone = $timezone;

		//make input date in utc 

		//to utc date
		$offset_str_diff = "";
		$mo = $this->timeZoneMinutesOffset($timezone);
		if( $mo->minutes != 0 ){
			$offset_str_diff = ($mo->sign=='+'?'-':'+').$mo->minutes." minutes ";
		}

		//getting UTC Time 
		$this->utcInDateTime = date("Y-m-d H:i:s", strtotime(trim($this->inDateTime." $offset_str_diff")));
	}

	private function startWith($string,$startString)
	{
		return (substr($string, 0, strlen($startString)) === $startString);
	}

	private function timeZoneMinutesOffset( $timeZone )
	{
		$timeZoneUTC = $this->findTimeZoneOffsetUTC($timeZone);

		$timeZoneUTC = strtolower($timeZoneUTC);
		$timeZoneUTC = trim(str_replace("utc","",$timeZoneUTC));

		$sign = "";
		if($this->startWith( $timeZoneUTC ,"-")){
			$sign = "-";
			$timeZoneUTC = trim(str_replace("-","",$timeZoneUTC));
		}else{
			$sign = "+";
			$timeZoneUTC = trim(str_replace("+","",$timeZoneUTC));
		}

		$tmp = explode(":",$timeZoneUTC);

		$hours = intval($tmp[0]);
		$minutes = intval(isset($tmp[1])?$tmp[1]:0);
		$seconds = intval(isset($tmp[2])?$tmp[2]:0);

		$all_minutes = (( $hours * 60 ) + $minutes);

		return (object)[
			'sign' => $sign,
			'minutes' => $all_minutes
		];
	}

	private function findTimeZoneOffsetUTC($timeZone)
	{
		if( trim(strtolower($timeZone)) == "utc" ){
			return $timeZone;
		}

		if( $this->startWith(trim(strtolower($timeZone)),'+') or $this->startWith(trim(strtolower($timeZone)),'-') ){
			return $timeZone;
		}

		if( $this->startWith(trim(strtolower($timeZone)),'utc') ){
			return $timeZone;
		}

	    $timezoneIdentifiers = DateTimeZone::listIdentifiers();

	    $utcTime = new DateTime('now', new DateTimeZone('UTC'));
	 
	    $tempTimezones = array();
	    foreach ($timezoneIdentifiers as $timezoneIdentifier) {
	        $currentTimezone = new DateTimeZone($timezoneIdentifier);
	         $tempTimezones[] = array(
	            'offset' => (int)$currentTimezone->getOffset($utcTime),
	            'identifier' => $timezoneIdentifier
	        );
	    }

		$timezoneList = array();
	    foreach ($tempTimezones as $tz) {
	    	$tz['identifier'] = trim(strtolower($tz['identifier']));
			$sign = ($tz['offset'] > 0) ? '+' : '-';
			$offset = gmdate('H:i', abs($tz['offset']));
	        $timezoneList[$tz['identifier']] ="UTC $sign$offset";
	    }

	    if( isset($timezoneList[trim(strtolower($timeZone))]) ){
	    	$utcTimeZone = $timezoneList[trim(strtolower($timeZone))];
	    	return $utcTimeZone;
	    }

	    return false;
	}

	public function validTimeZone( $timeZone, $isUTCCheck = false )
	{
		if( trim(strtolower($timeZone)) == "utc" ){
			return true;
		}

		if( $this->startWith(trim(strtolower($timeZone)),'+') or $this->startWith(trim(strtolower($timeZone)),'-') ){

			$tmp = str_replace("+","",$timeZone);
			$tmp = str_replace("-","",$tmp);
			$tmp = trim($tmp);

			if( strlen($tmp) == 0 ){
				return false;
			}

			$tmp = explode(":",$tmp);
			if( count($tmp) == 2 ){
				return true;
			}

			return false;
		}

		if( $isUTCCheck ){
			return false;
		}

		$valid = $this->findTimeZoneOffsetUTC($timeZone);
		if( $valid ){
			return true;
		}else{
			return false;
		}
	}

	public function toTimeZone( $timeZone )
	{

		//to get offset of new timezone
		$new_offset_str_diff = "";
		$newT = $this->timeZoneMinutesOffset( $timeZone );
		if( $newT->minutes != 0 ){
			$new_offset_str_diff = $newT->sign.$newT->minutes." minutes ";
		}

		$utcDate = $this->utcInDateTime;
		$resultDate = date("Y-m-d H:i:s", strtotime(trim($utcDate." $new_offset_str_diff")));

		return $resultDate;
	}

}