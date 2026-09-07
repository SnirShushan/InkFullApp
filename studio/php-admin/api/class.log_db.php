<?php
    class Db_core
    {
        private $sqlite;
        private $mode;

        function __construct( $filename, $mode = SQLITE3_ASSOC )
        {
            $this->mode = $mode;
            $this->sqlite = new SQLite3($filename);
        }

        function escape( $var )
        {
            return $this->sqlite->escapeString( $var );
        }

        function sanitize( $str_arr )
        {
            if( is_array( $str_arr ) )
            {
                $data = '';
                foreach( $str_arr AS $key => $val )
                {
                    $data[$key] = $this->escape( $val );
                }
                return $data;
            }
            return $this->escape( $str_arr );
        }

        function query( $query )
        {
            $res = $this->sqlite->query( $query );
            if ( !$res )
            {
                throw new Exception( $this->sqlite->lastErrorMsg() );
            }
            return $res;
        }

        function truncate( $table_name )
        {
            $this->query( "delete from ". $table_name );
            $this->query( "delete from sqlite_sequence where name = '". $table_name ."'" );
        }

        function sqlite_insert_id()
        {
            return $this->sqlite->lastInsertRowID();
        }

        function insert( $table_name, $in_data = array() )
        {
            if( !empty( $in_data ) && !empty( $table_name ) )
            {
                $cols = $vals = '';

                foreach( $in_data AS $key => $val )
                {
                    $cols .= $key .", ";
                    $vals .= "'". $val ."', ";
                }

                $query = "INSERT INTO ". $table_name ."(". trim( $cols, ', ') .") VALUES(". trim( $vals, ', ' ) .") ";
                return $this->query( $query );
            } 
            else 
            {
                return FALSE;
            }
        }

        function update( $table_name, $in_data = array(), $condition = '' )
        {
            if( !empty( $in_data ) && !empty( $table_name ) && !empty( $condition ) )
            {
                $str = '';
                foreach( $in_data AS $key => $val )
                {
                    $str .= $key ." = '". $val ."', ";
                }
            
                echo $query = "UPDATE ". $table_name ." SET ". trim( $str, ', ' ) ." WHERE ". $condition;
                return $this->query( $query );
            } 
            else 
            {
                return FALSE;
            }
        }

        function row_array( $query )
        {
            $res = $this->query( $query );
            $row = $res->fetchArray( $this->mode );
            return $row;
        }

        function fetch_array( $query )
        {
            $rows = array();
            if( $res = $this->query( $query ) ){
                while($row = $res->fetchArray($this->mode)){
                    $rows[] = $row;
                }
            }
            return $rows;
        }

        function fetch_row( $table_name, $condition = 1, $column = '*' )
        {
            $qry = "SELECT ". $column ." FROM ". $table_name ." WHERE ". $condition;
            $row = $this->row_array( $qry );
            return $row;
        }

        function fetch_rows( $table_name, $condition = 1, $column = '*' )
        {
            $qry = "SELECT ". $column ." FROM ". $table_name ." WHERE ". $condition;
            $row = $this->fetch_array( $qry );
            return $row;
        }

        /*function queryOne( $query )
        {
            $res = $this->sqlite->querySingle( $query );
            return $res;
        }*/

        function __destruct()
        {
            @$this->sqlite->close();
        }
    }
    
 
?>