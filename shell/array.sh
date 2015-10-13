#**************************************************************************
# Output array size
# @param $1 array name
#**************************************************************************
function array_size()
{
  [ $# -ne 1 ] && return $FAILURE

  local _size_array=""
  eval _size_array='("${'$1'[@]}")'

  echo ${#_size_array[*]}

  return $SUCCESS
}

#**************************************************************************
# Apend elements to the end of the array 
# @param $1 array name
# @param $2 elements to append
#**************************************************************************
function array_push()
{
  [ $# -ne 2 ] && return $FAILURE
  eval $1='("${'$1'[@]}" "$2")'

  return $SUCCESS
}

#**************************************************************************
# Retrieve the value from the beginning of the array
# (after removal, shifts each elements)
# @param $1 array name
#**************************************************************************
function array_pop()
{
  [ $# -ne 1 ] && return $FAILURE

  local _pop_array=""
  eval '_pop_array=("${'$1'[@]}")'

  [ `ArraySize "$1"` -eq 0 ] && return $FAILURE

  echo "${_pop_array[0]}"
  unset _pop_array[0]

  eval $1='("${_pop_array[@]}")'

  return $SUCCESS
}

#**************************************************************************
# $B;XDj$7$?J8;zNs$N3F9T$rMWAG$H$9$kG[Ns$r:n@.$9$k!#(B
# @param $1 $BG[NsL>(B
# @param $2 $BMWAG$H$J$kJ8;zNs(B
#**************************************************************************
function ArraySetLine()
{
  [ $# -ne 2 ] && return $FAILURE

  local _array_set_line=""

  IFS=$'\n'
  _array_set_line=($2)
  IFS="$IFS_BAK"

  eval $1='("${_array_set_line[@]}")'

  return $SUCCESS
}

#**************************************************************************
# Sort the elements of an array
# @param $1 array name
#**************************************************************************
function array_sort()
{
  [ $# -ne 1 ] && return $FAILURE

  local _sort_array=""
  eval _sort_array='("${'$1'[@]}")'

  IFS=$'\n'
  _sort_array=(`echo "${_sort_array[*]}" | sort $_ARRAY_SORT_OPT`)
  IFS="$IFS_BAK"

  eval $1='("${_sort_array[@]}")'

  return $SUCCESS
}


#**************************************************************************
# Remove duplicate elements of the array
# @param $1 array name
#**************************************************************************
function array_uniq()
{
  [ $# -ne 1 ] && return $FAILURE

  local _uniq_array=""
  eval _uniq_array='("${'$1'[@]}")'

  IFS=$'\n'
  #_uniq_array=(`echo "${_uniq_array[*]}" | uniq $_ARRAY_UNIQ_OPT`)
  _uniq_array=(`echo "${_uniq_array[*]}" | awk '!colname[$1]++{print $1}'`)
  IFS=$IFS_BAK

  eval $1='("${_uniq_array[@]}")'

  return $SUCCESS
}


#**************************************************************************
# To search for a string that you specify from the array
# @param $1 string
# @param $2 array name
#**************************************************************************
function array_search()
{
  [ $# -ne 2 ] && return $FAILURE

  local _search_array=""
  eval _search_array='("${'$2'[@]}")'

  { array_join '\n' _search_array; } | grep -w "${1}" >/dev/null 2>&1 || return $FAILURE

  return $SUCCESS
}


#**************************************************************************
# $BG[Ns$NA4MWAG$r;XDj$7$?J8;zNs$r6h@Z$j$H$7$F7k9g$7$FI8=`=PNO$X=PNO$9$k!#(B
# Output and join specified string as kugiri
# @param $1 $BJ8;zNs(B
# @param $2 $BG[NsL>(B
#**************************************************************************
function array_join()
{
  [ $# -ne 2 ] && return $FAILURE

  local _join_array=""
  eval _join_array='("${'$2'[@]}")'

  local _size=`ArraySize _join_array`

  for _item in "${_join_array[@]}"
  do
    echo -n "${_item}"
    [ $_size -gt 1 ] && echo -ne "$1"
    _size=`expr $_size - 1`
  done

  echo -e ""

  return $SUCCESS
}


#**************************************************************************
# $B%U%!%$%k$+$i(B1$B9TFI$_9~$_(B,$BJQ?t$K@_Dj$9$k!#(B
# @param $1 $BJQ?tL>(B
# @param $2 $B%U%!%$%kL>(B
# @return $B@_Dj@.8y;~$O(B0,$B%Q%i%a!<%?%(%i!<$*$h$SFI$_9~$_9T%*!<%P!<$O(B2$B$rJV$9!#(B
#**************************************************************************
function GetLine()
{
  [ $# -ne 2 -o ! -f "$2" -o ! -r "$2" ] && return $FAILURE

  local _GL_CKSUM=`cksum "$2" | Field 1`

  local _cnt=`GetVarByName "_GL_CNT_${_GL_CKSUM}"`
  [ `IsEmpty "$_cnt"` = $TRUE ] && _cnt=1

  [ $_cnt -gt `wc -l "$2" | Field 1` ] && return $FAILURE

  eval $1='`sed -n "${_cnt}p" "$2"`'

  _cnt=`expr $_cnt + 1`
  SetVarByName "_GL_CNT_${_GL_CKSUM}" $_cnt

  return $SUCCESS
}


#**************************************************************************
# $BG[Ns$NA4MWAG$r%D%j!<7A<0$GI=<($9$k!#(B
# @param $1 $BG[NsL>(B
# @return $BI=<(@.8y;~$O(B0,$BG[Ns$NMWAG$J$7$*$h$S%Q%i%a!<%?%(%i!<$O(B2$B$rJV$9!#(B
#**************************************************************************
function print_r()
{
  [ $# -ne 1 ] && return $FAILURE

  local _print_r_array=""
  eval _print_r_array='("${'$1'[@]}")'

  local _CKSTR="IS_USED_VARIABLE"
  local _SIZE=`ArraySize _print_r_array`

  [ ! "$_SIZE" -gt 0 ] && return $FAILURE

  local _cnt=0
  local _i=0

  echo "${1}[@]"
  echo " |"

  local _item=""
  local _ckitem=""
  while [ $_cnt -lt $_SIZE ]
  do
    _item=`eval echo '"${'$1'[${_i}]}"'`
    _ckitem=`eval echo '"${'$1'[${_i}]-$_CKSTR}"'`
    if [ "$_item" = "$_CKSTR" ]; then
      eval echo '" |-[${_i}] = [${'$1'[$_i]}"]'
      _cnt=`expr $_cnt + 1`
    else
      if [ "$_ckitem" != "$_CKSTR" ]; then
        eval echo '" |-[${_i}] = [${'$1'[$_i]}"]'
        _cnt=`expr $_cnt + 1`
      fi
    fi

    _i=`expr $_i + 1`
  done

  return $SUCCESS
}

